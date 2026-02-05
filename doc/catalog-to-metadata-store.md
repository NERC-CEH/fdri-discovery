# EIDC Catalog / Metadata Store Data Integration

## Goals of this integration

  1. Retrieve core reference data that is managed in the catalog for use in the metadata store. This will include site, network and programme metadata. It may also include geospatial regions such as catchments.
  1. Create, and maintain links between metadata store dataset records and the EIDC catalog dataset record(s) that they are part of.
  1. Provide metadata to the FDRI data publishing process to enable support creating/updating EIDC catalog dataset records.

NOTE: it is assumed that the FDRI data publishing process that creates/updates records on the EIDC catalog is outside the scope of this integration and will be implemented by a separate "data publishing" service which would make use of the data in the Metadata Store in order to construct a package of data and metadata to submit to EIDC. For this reason, this document does not cover the details of publishing data to the EIDC catalog.

## Linking Datasets

To support the publication of data from FDRI to the EIDC, the metadata store needs to hold information about each EIDC dataset published by FDRI and link the EIDC dataset to the FDRI dataset(s) which provide the data that comprise the EIDC dataset.

An "FDRI dataset" in this context may be a single variable time-series dataset such as the time-series of air temperature at a specific FDRI site. An "EIDC dataset" will typically comprise many such individual time-series (e.g. a dataset of all meteorological observations across all FDRI sites).

### Option 1 - Mastered in FDRI Metadata Store
It is assumed that the content of EIDC datasets published by FDRI are *only* published/updated by FDRI. It is also assumed that the FDRI system is the "master" for all metadata that appears on an EIDC dataset published by FDRI and that changes to the metadata shall not be made directly through the EIDC catalog editing functionality. 

The FDRI ontology already has a class (`fdri:ObservationDatasetSeries`) that represents a collection of observation datasets (such as time-series datasets). This class can be extended to support recording information about the EIDC publication status of the series and hold the EIDC catalog record identifier once a record is created. The metadata to be provided to the EIDC catalog can be recorded as properties of the `fdri:ObservationDatasetSeries`. This includes all of the core DCAT metadata that the EIDC catalog requires. The service that packages data for release to EIDC can then make use of the metadata stored against the `fdri:ObservationDatasetSeries` as well as any detailed metadata stored against each series member in order to construct the metadata package for the EIDC catalog.

### Option 2 - Mastered in EIDC Catalog

In this option, the initial creating of dataset record is managed through the EIDC catalog interface. Once this record has been created, a `fdri:ObservationDatasetSeries` can be created in the Metadata Store that includes a link to the associated EIDC catalog record. The `fdri:ObservationDatasetSeries` would be used to group together all of the individual datasets that make up the content of the dataset published to the EIDC catalog.


### Open Questions / To Discuss

**How will the more detailed metadata and provenance data maintained by the Metadata Store be reflected in the the EIDC catalogue?** This question requires some additional specification of the EIDC catalogue structure for FDRI - in particular what descriptive metadata around observed properties and data provenance are to be surfaced in the EIDC catalog and what fields are to be used to capture this metadata in the EIDC catalog.

**How will the relation between datasets and entities such as sites, people, and organisations by managed?** Depending on the final approach for the integration of reference data from the EIDC catalog it is possible that the Metadata Store may use on identifier for a site, the EIDC use a different one. Some of the proposals for integration of reference data (below) propose maintaining a link between those identifiers which could be used to present reference data to the EIDC catalog using EIDC identifiers when they are available. However, there remains the question of whether all such reference data will be in the EIDC/public vocabulary server. In particular reference data about organisations and individuals used for attribution of datasets.
It may make sense for the FDRI metadata store to capture this attribution metadata against each dataset series that is to be published, or it may make sense for some default set of attribution properties to be specified at a programme level and simply reused for all published dataset series from that programme.


## Linking Reference Data

Reference data from the catalog includes site (facility), network and programme data.
The current ingest uses locally generated identifiers under the http://fdri.ceh.ac.uk/id/ namespace, with a fairly transparent suffix e.g. site/cosmos-bunny
The catalog records (on the staging catalog) use https://catalogue.staging.eds.ceh.ac.uk/id/ as the namespace and a GUID string as the suffix (e.g. https://catalogue.staging.eds.ceh.ac.uk/id/4cdd7d0b-6797-419a-b13d-aa59b5bf2b40).

There are three options for how to deal with this.

1) Keep both sets of site metadata, and link them together (e.g. with an owl:sameAs property). This keeps the records distinct but is not so cleanly surfaced to downstream users of APIs such as the combined API. It also implies that the records could get out of sync (e.g. when a site is closed, that would have to be updated in the source CSV files for the metadata service as well as updated in the catalogue).

2) Prefer the catalogue record - this would require a means to link existing metadata to the catalog record for the facility. Ingest data and the associated templates would need to be updated either to use the catalog record identifiers directly, to use a hard-coded mapping of short identifier (e.g. cosmos-bunny) to catalogue record identifier, or to use the reconciliation feature of the rdf-mapper to lookup the mappings "on the fly" during the ingest process. This retains the notion of the catalog record being the "master" data any changes to the metadata for a facility is easily updated simply by reimporting the RDF from the catalogue. The downside of this approach is some additional development effort in the ingestion process and that some code that may be relying on being able to generate identifiers from short-codes will break, so there is a not-insignificant amount of development work required.

3) Prefer the existing metadata service record but enhance with metadata from the catalog. This approach would record a link from the metadata service record to the catalog record (e.g. using owl:sameAs) but rather than directly import the catalog metadata, an ingest process would add catalog metadata properties to the existing metadata service record. This might include things like the site geometry, current site operational status / operational date ranges etc. We might have to decide on a property-by-property basis which items of data flow from the catalog to the metadata store and in the case of conflicts which one wins. As the existing metadata store identifier scheme would remain in place the amount of impact on data processing pipelines and other downstream users would be more limited than in (2). Changes in metadata in the catalog would selectively flow through to the metadata store, and we can decide how much or how little of that data flows through. However, as with (1) this means that the principal reference to the site in all dataset metadata etc. would be the metadata store identifier and not the catalog identifier for the site.

It should also be noted that if opting for (2) there is also the problem that the current catalog implementation does not preserve the URIs of catalog records between environments, so when the data moves to the public catalogue, the identifiers for sites etc. will change. Using a dynamic reconciliation approach to linking other metadata records to the catalogue reference data should be able to cope with this, but using static lookup tables/mapping files would mean additional work in migrating from staging to production.

If opting for (3) then the experience for a user of the API would be that a reference to a site in the API should resolve to site details in the API. One of the links in the site details in the API would be a link to the EIDC catalogue record for the site. 

### Recommendation: Option 3

On balance, option (3) best supports both the internal FDRI data processing pipelines, the needs of API users to be able to retrieve site information from the same API as the data, and the needs of downstream users to be able to track back to the canonical site metadata in the EIDC catalogue.