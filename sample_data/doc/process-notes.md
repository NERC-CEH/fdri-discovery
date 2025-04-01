# Notes on sample data processing

Currently, data loading for the metadata service is implemented a GH action (in this repo) transforming checked-in CSV files to graph updates.

We plan to move to a state where updates can be applied incrementally from different source data services. 

In preparation for that, these notes identify the different data sources currently represented in the store and how the future update process might work. Very much work in progress and will change as we clarify the details of these data feeds.

# Summary table

| Data | Source | Update type | Notes and processing issues |
|---|---|---|---|
| Site reference | EIDC catalogue? | Bulk replace (by network?) | Are the full annotations included? |
| Site reference CVs[1]  | Vocab server? | Bulk replace (by CV) | If the annotations like soil and bedrock are, or can be made, controlled terms |
| Land Cover base % | EIDC/separate reference data | Incremental series update[2] | |
| Land Cover observations | Field reporting - asset management? | Incremental  series update |  |
| Land Cover classes | Vocab server | Bulk replace (by CV) | |
| Sensor types | Asset management? Static reference data? | Bulk replace | Either include variable mapping or have separate mapping file[3] |
| Sensor deployments | Asset management | Incremental series update  | |
| Sensor faults | Asset management | Incremental addition | Include sensor ID so can link directly. Assume all supplied data is relevant and don't limit to deployed sensors? |
| Sensor config changes (firmware) | Asset management | Incremental series updates[2] | Do cleansing/validation separately? |
| Processing levels CV | Vocab server | Bulk replace (by CV) | If we continue to track processing levels |
| Correction methods CV | Vocab server | Bulk replace (by CV) | |
| Correction factors for data pipeline | Data pipeline config? | Update API? [4] | |
| Parameter ranges for data pipeline QC | Data pipeline config? | Update API? | |
| Variable to instrument mapping (3) | ? Where is this managed? | Bulk replace? | Cleaner data to avoid preprocessing? |
| Variable (COP) definitions | NERC + local vocab servers | Bulk replace by CV | |
| Statistics CV | NERC or local vocab servers | Bulk replace by CV | |
| Time series definitions | ? Managed in the metadata store? | Update API? | Separate out S3 annotations? |
| S3 storage annotations for time series | Data pipeline config? | Update API? | |
| Time series datasets | ? Managed in the metadata store? | Update API? | Should  this be automatically derived from above and site instrumentation (as present)? Or should there explicit configuration of which datasets are active at a site? |

[1]: We use "CV" as  an abbreviation for Controlled Vocabulary, represented as a SKOS ConceptScheme. Many of these are currently inferred from the source data during ingest but are expected to eventually come from a vocabulary server.

[2]: Incremental update in many cases involves updating a time-qualified series of values (time-bound annotations or other resources such as deployments) which requires us to close the interval for the existing value, create the new time bound value and update the `hasCurrentValue` link. This is a non-monotonic process, so to do this incrementally will either require the ingester to check against existing data or mean generating a post ingest SPARQL Update to fix up the bounds. There may also be a requirement to be able to replace existing values (to fix errors) rather than add to the series. A general update API pattern for this is needed.

[3]: It would be helpful to clarify how the sensor to variable mapping will be managed. Will this be part of the asset management system, some separate configuration management or mastered in the metadata store?

[4]: For data which will be regarded as mastered in the metadata store itself then will want a CRUD style API which gives the option of fine grain updates but is able to support batch updates.

# Detailed description of current data ingest

Note: In the current processing, the overall pattern is that each processed source dataset `src/X.csv` is mapped to a `build/X.ttl` file via a transform template file `templates/X.yaml`. So the names given below are the `X` in those file names.

In many cases some preprocessing is performed by a SQL (duckdb) script. These can normalise values, simplify the transformation step or perform joins. Some of this preprocessing may be simplified in future with improvements to source data and/or extensions to the mapping tool. These are highlighted in the sections below.
 
## Sites, Network and related

### `SITES`

**What:** Core reference data on monitoring sites including geo location, description and layout.

**Preprocessing:** Sites with non-standard layout are separated out for processing by a separate template which adds a `siteVariance` property to those sites. 

**Alt-preprocessing?:** Preprocessing might be avoided by extending the mapper to support inline conditionals.

**Generates:** `EnvironmentalMonitoringSite`s with annotations and associated `GeospatialFeatureOfInterest`. Variables used in the site annotations (`site-soil-type`, `site-public` etc). Other one-off reference terms (COSMOS Programme and monitoring network). Inferred CV for COSMOS regions, soil classification and bedrock classification.

**Future source:** Presume that site reference information will be mastered in the data catalog and imported from there. Testing of this process is planned. To be confirmed whether that reference data covers all the annotations here.

> [!NOTE]
> The annotations such as soil type, bedrock classification appear to be free text. Current ingest builds local CVs for these. Ideally in FDRI such annotations would be controlled at source and the CVs managed in a vocabulary server - is that reasonable? In the interim maybe move these to separate graphs as preparation.

**Update requirements:** Relatively static data so bulk replacement is fine. May want to move to separate graphs for the CVs (if used), site data from catalog and any additional site reference annotations sourced from elsewhere.

### `LAND_COVER_LCM_CLASSES`

**What:** Labels for landcover classes used in landCoverLcm

**Generates:** LandCover CV

**Future source:** Vocabulary server

**Update requirements:** Replace whole CV graph when updated.

### `landCoverLcm`

**What:** Landcover class and area by site and year, with percentages for different types, uses landcover class codes from `LAND_COVER_LCM_CLASSES`. Data is derived from the LC maps and not routinely updated.

**Preprocessing:** Convert cover from % to (rounded) fraction, map year to a date. 

**Alt-preprocessing?:** Extend mapper to support functional transforms like this.

**Generates:** Time bounded annotations on given landcover ratio for each site. Together with definition for the ratio variable.

**Future source:** Is this included site reference data in the catalogue or a separate part of onboarding new sites? 

**Update requirements:** Presume that new LC maps will be issued at some point so the (time-bounded) annotations will need updating, as well as onboarding new sites. So need incremental update supporting closing off the interval for existing value and updating `hasCurrentValue`.

### `landCoverObservations`

**What:** The footprint of land cover at site from direct observation. Single value per site, and includes records of changes. Uses text labels rather than Landcover classes.

**Preprocessing:** Determine end date for observation rows where there's a newer observation. Map text labels to landcover class codes.

**Alt-preprocessing?:** If supplied incrementally end dates could be set as replacement data arrives. Reconciliation (of labels to codes) is supported in the mapper if suitable endpoint can be provided.

**Generates:** Time-bounded annotations on sites giving observed land cover, themselves annotated with source and comments. Together with definitions for the annotation variables.

**Future source:** ? Presume some field reporting system would be used to report new site observations that would arrive over time.

**Update requirements:** Incremental, non-monotonic updates. If we assume access to current metadata state then the update can check if the observation is different from the existing one and if so close the date for the previous observation and start a new one. Assign each update a separate graph timestamped so it can be backed out if there's a data problem.

## Deployments and sensors

### `INSTRUMENTATION`

**What:** List of sensor types used.

**Generates:** `EnvironmentalMonitoringSystemType` definitions with name and comment (as scope note).

**Future source:** Reference data set on sensor types? From asset system or vocab server?

**Update requirements:** Bulk replacement?

### `instrumentation_parameters` from `TIMESERIES_IDS` and `SENSOR_SLOT_IDS`

**What:** Mapping from variable to instrument type

**Preprocessing:** Join on slot ID to give a table of instrument type and variable id

**Generates:** `EnvironmentalMonitoringSystemType` concepts in a scheme with `fdri:observes` links to observed properties.

**Future source:** Reference data on variable configuration including sensor types. Where mastered?

**Update requirements:** Bulk replacement

### `sensor_deployments` from `SITE_INSTRUMENTATION`, `SENSOR_SLOT_IDS` and `TIMESERIES_IDS`

**What:** `SITE_INSTRUMENTATION` gives history of sensor deployments at sites with sensor slot id and serial number. `SENSOR_SLOT_IDS` maps a sensor slot to an instrument type id. `TIMESERIES_ID` maps a site to a sensor slot and a variable.

**Preprocessing:** Join first two on sensor slot id and then join to time series on site and sensor slot id.

**Generates:** `EnvironmentalMonitoringSensor` and `Deployment` information.

**Future source:** Presume deployment information would be extracted from the future asset management system.

**Update requirements:** Incremental record updates as deployments change.

### `sensor_faults` from `SENSOR_FAULTS`, `TIMESERIES_DEFS` and `sensor_deployments`

**What:** `SENSOR_FAULTS` gives list of time periods of faults on specific sensors with comments, includes the affected variables (could be multiple `;`-separated affected variables per fault). `TIMESERIES_DEFS` is used to limit the results to only variables which have an existing definition.

**Preprocessing:** Splits faults to single row per variable and then checks fault for match to a deployed sensor with overlapping time periods. To test that, we need mapping from variable to sensor from the `sensor_deployments` intermediate.

**Generates:** `Fault` records with descriptions for sensor (or station if sensor not known) with link to affected varaibles.

**Future source:** Presume faults will be reported via the asset management system but there may be a delay so faults may still refer to a prior deployment. Preferable if the fault information includes a sensor ID so these can be linked directly instead of indirectly via variable.

**_Question for CEH:_**  Will the asset management system know about the variables affected or will there need to be separate processing to create those links?

**Update requirements:** Incremental fault additions, assume sensor ID is included in the update (and if not fault applies to site) and variable(s) explicit in update. May need to check if fault with matching timestamp exists to make updates idempotent.

**_Question for CEH:_** Could these fault records have an ID to avoid duplicate updates?

> [!NOTE]
> Currently fault reports are only included if they refer to sensors known to be deployed. In future may wish to change this and record faults with no `affectedFacility` link; later we may learn about a deployment of that sensor (during the relevant period) and need to fix up the link.

### `sensor_firmware_configurations` from `Firmware_history`

**What:** Time bounded records of firmware versions for instrument id. Note that these might also refer to sensors that are not (currently) deployed. E.g. when a sensor is removed from the field, updated in a lab and then redeployed at a later date.

**Preprocessing:** Cleansing to handle missing start dates and end dates (if two entries for same instrument have different start dates but no end date assume first started was ended when newer one was started). Format dates to ISO.

**Alt preprocessing:** The data formatting could be moved to the transformer. For future support might want to validate data to just reject entries with no start date?

**Generates:** `ConfigurationValueSeries` for the sensor, with `TimeBoundPropertyValue` for each entry, and sets current value.

**Future source:** Assume incremental record updates from asset management system for new firmware versions. Or might be bulk export. Or might need to support both (incremental normally but allowance for bulk re-sync).

**Update requirements:** If bulk export then process as now, replacing whole history. If incremental then check if version has actually changed and if so close off current value and set new current value. Maintaining the current value is non-monotonic so need a SPARQL Update or check against current data.

### `sensor_calibrations` from `calib_factors_nr01_anem`, `SITE_INSTRUMENTATION`, `SENSOR_SLOT_IDS`, `TIMESERIES_DEFS` and `TIMESERIES_IDS`

**WHAT:** Records of the sensor calibration corrections that apply to time series values.

**Preprocessing:** Reformat date/time strings. Join TIMESERIES_DEFS on variable then TIMESERIES_ID on TIMESERIES_DEF and SITE. Join SENSOR_SLOT_IDS and then SITE_INSTRUMENTATION filtering by the date range of the correction to select the sensor instance that the calibration applies to

**Generates:** `CalibrationActivity` representing the action of sensor calibration that gives rise to the correction factor; `InternalDataProcessingConfiguration` with a `ConfigurationItem` which represents the correction factor derived from the calibration.

**Future source:** Assume that calibration activities and their outcomes in terms of calibration factors to be applied to data are managed in the asset management system. Or might be bulk export. Or might need to support both (incremental normally but allowance for bulk re-sync). A future source could provide a more direct mapping between the correction factor and the affected sensor and leave the metadata store to infer the affected time series based on deployment records for the sensor.

## Processing pipeline

### `CORRECTION_METHODS`

**What:** Definitions for the correction methods use to apply the correction factors.

**Generates:** CV for correction methods.

**Future source:** Vocabulary server?

**Update requirements:** Replace whole graph when CV updated.

### `CORRECTION_FACTORS`

**What:** Time bounded correction factors by site and time series.

**Generates:** `InternalDataProcessingConfiguration` for the timeseries, `ConfigurationItem`s for each entry with interval, observation interval affected and link to correction method and dummy plan. Each item is linked as `hasCurrentConfiguration` to the `InternalDataProcessingConfiguration`.

**Future source:** ?? Will the metadata service be the master for these?

**Update requirements:** ?? General CRUD API?

### `PARAMETER_RANGES_QC`
**What:** Legal ranges for observarions by time series.

**Generates:** `InternalDataProcessingConfiguration` with `ConfigurationItem` for each range. One-off definitions for the parameter and config type.

**Future source:** ??  Will the metadata service be the master for these?

**Update requirements:** ?? General CRUD API?

> [!NOTE]
> The representation of this may change to be by time series definition and site.

> [!NOTE]
> For this and the prior data there are the one-off definitions of parameters and config types generated. Might shift these to being in a pre-prepared base load if we support CRUD rather then bulk replacement.

### `processingLevels`

**What:** Labels and ids for the processing levels

**Generates:** CV for processing levels

**Future source:** Vocab server

**Update requirements:** Bulk update on CV change

### Time Series Derivations

**What:** Provides the derivation process, sources, method, and parameters for the processing of derived time series.

**Pre-processing**: Conversion from singleton JSON object to JSON lines to aid pre-processing in duckdb. The converted
JSON is then loaded into duckdb and transformed into a pair of tables: one mapping the derived TSDEF to its dependency TSDEFs,
the other providing the derivation, method and additional arguments for the TSDEF.

**Generates**: TimeSeriesPlan associated with the derived TSDEF, specifying dependencies and the processing configuration.

**Future source:** Assume incrementally updated as new derived TSDEFs are defined and/or when the processing for a derived TSDEF is modified.

**Update requirements:** Update API to create new plans or update the sources and configuration for existing plans

## Datasets and variables

### `STATISTICS`

**What:** Id, label and definition for statistic (MEAN_PREC, INST etc).

**Generates:** CV for statistics

**Future source:** Vocab server

**Update requirements:** Bulk update on CV change

### `TIMESERIES_DEFS`

**What:** Definitions of time series with id, label, parameter, statistic, unit, processing level

**Generates:** `TimeSeriesDefinition` for all timeseries datasets (which are then common across individual series)

**Future source:** ?? Managed in metadata store?

**Update requirements:** Update API to manage definitions and related configurations?

### `TIMESERIES_IDS`

**What:** Definition of all time timeseries datasets for each site with time series definition, variable, sensor slot, processing level, and S3 source location information.

**Generates:** `TimeSeriesDatasets` collected into a series for each site and a series for each site/variable (across processing levels).

**Future source:** ?? Managed in metadata store?

**Update requirements:** Update API if managed in metadata store.

## Data not currently represented

Processing activities.

