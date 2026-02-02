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
