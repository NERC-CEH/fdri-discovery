# EIDC Catalog / Metadata Store Data Integation

## Goals of this integration

  1. Retrieve core reference data that is managed in the catalog for use in the metadata store. This will include site, network and programme metadata. It may also include geospatial regions such as catchments.
  1. Create, and maintain links between metadata store dataset records and the EIDC catalog dataset record(s) that they are part of.
  1. Provide metadata to the FDRI processing environment to enable support creating/updating EIDC catalog dataset records.

NOTE: it is assumed that the process of publishing data to the EIDC catalog is outside the scope of this integration and would instead be implemented by a separate "data publishing" service which would make use of the data in the Metadata Store in order to construct a package of data and metadata to submit to EIDC.

## Linking Datasets

In order to support the publication of data from FDRI to the EIDC, it is necessary for the metadata store to hold information about each EIDC dataset published by FDRI and link the EIDC dataset to the FDRI dataset(s) which provide the data that comprise the EIDC dataset.

It is assumed that the content of EIDC datasets published by FDRI are *only* published/updated by FDRI. It is also assumed that the FDRI system is the "master" for all metadata that appears on an EIDC dataset published by FDRI and that changes to the metadata shall not be made directly through the EIDC catalog editing functionality. 

In the Metadata Store, there is a separate dataset for each site+observed property pair. In the EIDC many of these datasets may be combined into a single catalog record providing access to the underlying data as separate files.

The FDRI ontology already has a class (`fdri:ObservationDatasetSeries`) that represents a collection of observation datasets (such as time-series datasets). This class can be extended to support recording information about the EIDC publication status of the series. The metadata to be provided to the EIDC catalog can be recorded as properties of the `fdri:ObservationDatasetSeries`. This includes all of the core DCAT metadata that the EIDC catalog requires. The service that packages data for release to EIDC can then make use of the metadata stored against the `fdri:ObservationDatasetSeries` as well as any detailed metadata stored against each series member in order to construct the metadata package for the EIDC catalog.

## Linking Reference Data

Reference data from the catalog includes site (facility), network and programme data.
The current ingest uses locally generated identifiers under the http://fdri.ceh.ac.uk/id/ namespace, with a fairly transparent suffix e.g. site/cosmos-bunny
The catalog records (on the staging catalog) use https://catalogue.staging.eds.ceh.ac.uk/id/ as the namespace and a GUID string as the suffix (e.g. https://catalogue.staging.eds.ceh.ac.uk/id/4cdd7d0b-6797-419a-b13d-aa59b5bf2b40).

There are three options for how to deal with this.

1) Keep both sets of site metadata, and link them together (e.g. with an owl:sameAs property). This keeps the records distinct but is not so cleanly surfaced to downstream users of APIs such as the combined API. It also implies that the records could get out of sync (e.g. when a site is closed, that would have to be updated in the source CSV files for the metadata service as well as updated in the catalogue).

2) Prefer the catalogue record - this would require a means to link existing metadata to the catalog record for the facility. Ingest data and the associated templates would need to be updated either to use the catalog record identifiers directly, to use a hard-coded mapping of short identifier (e.g. cosmos-bunny) to catalogue record identifier, or to use the reconciliation feature of the rdf mapper to lookup the mappings "on the fly" during the ingest process. This retains the notion of the catalog record being the "master" data any changes to the metadata for a facility is easily updated simply by reimporting the RDF from the catalogue. The downside of this approach is some additional development effort in the ingestion process and that some code that may be relying on being able to generate identifiers from short-codes will break, so there is a not-insignificant amount of development work required.

3) Prefer the existing metadata service record but enhance with metadata from the catalog. This approach would record a link from the metadata service record to the catalog record (e.g. using owl:sameAs) but rather than directly import the catalog metadata, an ingest process would add catalog metadata properties to the exisiting metadata service record. This might include things like more detailed geometries, current site operational status etc. We might have to decide on a property-by-property basis which items of data flow from the catalog to the metadata store and in the case of conflicts which one wins. As the existing metadata store identifier scheme would remain in place the amount of impact on data processing pipelines and other downstream users would be more limited than in (2). Changes in metadata in the catalog would selectively flow through to the metadata store, and we can decide how much or how little of that data flows through. However, as with (1) this means that the principal reference to the site in all dataset metadata etc. would be the metadata store identifier and not the catalog identifier for the site.

It should also be noted that if opting for (2) there is also the problem that the current catalog implementation does not perserve the URIs of catalog records between environments, so when the data moves to the public catalogue, the identifiers for sites etc. will change. Using a dynamic reconciliation approach to linking other metadata records to the cataolgue reference data should be able to cope with this, but using static lookup tables/mapping files would mean additional work in migrating from staging to production.
