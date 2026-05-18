IMAGE=293385631482.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/record-spec-tools/unstable:1.0-SNAPSHOT
RUN=docker run --rm -v .:/data ${IMAGE}

SCHEMA_BASE = sample_data/build/schema
SRC = sample_data/src
SQL = sample_data/sql
VAL = build/validation
TPL = sample_data/templates
TTL_BASE = build/data
SHACL_BASE = build/shacl
SCHEMA_FILE = ontology/schema/fdri.recordspec.yaml
RAW_SOURCE_BUCKET := $(shell awk '$$1==ENVIRON["GITHUB_REF_NAME"] {print $$4}' branch.map)
RAW_SOURCE_BUCKET := $(or ${RAW_SOURCE_BUCKET},fdri-dummy-ingested)
PROCESSED_SOURCE_BUCKET := $(shell awk '$$1==ENVIRON["GITHUB_REF_NAME"] {print $$5}' branch.map)
PROCESSED_SOURCE_BUCKET := $(or ${PROCESSED_SOURCE_BUCKET},fdri-dummy-processed)
MAPPER = mapper -g RAW_SOURCE_BUCKET=${RAW_SOURCE_BUCKET} -g PROCESSED_SOURCE_BUCKET=${PROCESSED_SOURCE_BUCKET}
GRIDMAP = gridded-mapper

RECORDS = \
	Variable \
	Activity \
	GeospatialFeatureOfInterest \
	EnvironmentalMonitoringPlatform \
	EnvironmentalMonitoringSensor \
	EnvironmentalMonitoringSite \
	ExternalDataProcessingConfiguration \
	InternalDataProcessingConfiguration \
	ConfigurationItem \
	StaticDeployment \
	TimeSeriesDataset \
	TimeSeriesDefinition

SAMPLES += $(TTL_BASE)/alt_data_config.ttl
SAMPLES += $(TTL_BASE)/ANNOTATION_PROPERTIES.ttl
SAMPLES += $(TTL_BASE)/CONFIGURATION_PROPERTIES.ttl
SAMPLES += $(TTL_BASE)/COSMOS_TS_ID_DEPENDENCIES_LINES.ttl
SAMPLES += $(TTL_BASE)/COSMOS_FLAG_SCHEMES.ttl
SAMPLES += $(TTL_BASE)/cosmos_ts_parameters.ttl
SAMPLES += $(TTL_BASE)/CORRECTION_CONFIGS_LINES.ttl
SAMPLES += $(TTL_BASE)/CORRECTION_METHOD_PARAMS.ttl
SAMPLES += $(TTL_BASE)/CORRECTION_METHODS.ttl
SAMPLES += $(TTL_BASE)/CORRECTION_PARAMS.ttl
SAMPLES += $(TTL_BASE)/FACILITY_USAGE_ROLES.ttl
SAMPLES += $(TTL_BASE)/FLAG_TYPES_LINES.ttl
SAMPLES += $(TTL_BASE)/CORE_FLAG_SCHEME.ttl
SAMPLES += $(TTL_BASE)/infill_config.ttl
SAMPLES += $(TTL_BASE)/INSTRUMENTATION.ttl
SAMPLES += $(TTL_BASE)/instrumentation_parameters.ttl
SAMPLES += $(TTL_BASE)/LAND_COVER_LCM_CLASSES.ttl
SAMPLES += $(TTL_BASE)/landCoverLcm.ttl
SAMPLES += $(TTL_BASE)/landCoverObservations.ttl
SAMPLES += $(TTL_BASE)/MEASURES.ttl
SAMPLES += $(TTL_BASE)/METHODS.ttl
SAMPLES += $(TTL_BASE)/METHOD_PARAMS.ttl
SAMPLES += $(TTL_BASE)/PARAMS.ttl
SAMPLES += $(TTL_BASE)/PARAMETERS_IDS.ttl
# SAMPLES += $(TTL_BASE)/phenocam_mask_config.ttl
SAMPLES += $(TTL_BASE)/PROCEDURE_TYPES.ttl
SAMPLES += $(TTL_BASE)/processingLevels.ttl
SAMPLES += $(TTL_BASE)/QC_CONFIGS.ttl
SAMPLES += $(TTL_BASE)/sensor_deployments.ttl
SAMPLES += $(TTL_BASE)/sensor_faults.ttl
SAMPLES += $(TTL_BASE)/sensor_firmware_configurations.ttl
SAMPLES += $(TTL_BASE)/SITE_CALIBRATION_INFO.ttl
SAMPLES += $(TTL_BASE)/site_slots.ttl
SAMPLES += $(TTL_BASE)/SITES.ttl
SAMPLES += $(TTL_BASE)/siteVariance.ttl
SAMPLES += $(TTL_BASE)/STATISTICS.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_IDS_COSMOS.ttl
SAMPLES += $(TTL_BASE)/timeseries_flags_cosmos.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_DEFS_FDRI.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_IDS_FDRI.ttl
SAMPLES += $(TTL_BASE)/timeseries_measures_fdri.ttl
SAMPLES += $(TTL_BASE)/UNITS.ttl
# Stop-gap temporal extents
SAMPLES += $(TTL_BASE)/ts_temporal.ttl

# NRFA
SAMPLES += $(TTL_BASE)/NRFA_SITES.ttl

# FDRI SAMPLES
# SAMPLES += $(TTL_BASE)/fdri_sites.ttl - replaced by AMS_sites_ext.ttl
SAMPLES += $(TTL_BASE)/fdri_site_assets.ttl
SAMPLES += $(TTL_BASE)/fdri_measure_ext.ttl
SAMPLES += $(TTL_BASE)/fdri_asset_loc_history.ttl
SAMPLES += $(TTL_BASE)/FDRI_QC_CONFIGS.ttl
SAMPLES += $(TTL_BASE)/FDRI_FLAG_SCHEMES.ttl

# Gauging Data Samples
SAMPLES += $(TTL_BASE)/ea_manual_sites.ttl
SAMPLES += $(TTL_BASE)/ea_manual_metadata.ttl
SAMPLES += $(TTL_BASE)/flowstick_surveys.ttl
SAMPLES += $(TTL_BASE)/rca_sites.ttl
SAMPLES += $(TTL_BASE)/rca_surveys.ttl
SAMPLES += $(TTL_BASE)/sontek_surveys.ttl

# Gridded Data Samples
SAMPLES += $(TTL_BASE)/chess-met_dtr.ttl
SAMPLES += $(TTL_BASE)/chess-met_huss.ttl
SAMPLES += $(TTL_BASE)/chess-met_precip.ttl
SAMPLES += $(TTL_BASE)/chess-met_psurf.ttl
SAMPLES += $(TTL_BASE)/chess-met_rlds.ttl
SAMPLES += $(TTL_BASE)/chess-met_rsds.ttl
SAMPLES += $(TTL_BASE)/chess-met_sfcWind.ttl
SAMPLES += $(TTL_BASE)/chess-met_tas.ttl
SAMPLES += $(TTL_BASE)/chess-pe_pet.ttl
SAMPLES += $(TTL_BASE)/chess-pe_peti.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_dtr.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_pr.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_rsds.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_tasmax.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_hurs.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_psurf.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_sfcWind.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_tasmin.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_huss.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_rlds.ttl
SAMPLES += $(TTL_BASE)/chess-scape_rcp85_15_tas.ttl
SAMPLES += $(TTL_BASE)/GEAR-daily.ttl
SAMPLES += $(TTL_BASE)/GEAR-hrly.ttl

# NMDB Samples
SAMPLES += $(TTL_BASE)/NMDB_SITES.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_DEFS_NMDB.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_IDS_NMDB.ttl
SAMPLES += $(TTL_BASE)/timeseries_measures_nmdb.ttl

# AMS Samples
SAMPLES += $(TTL_BASE)/AMS_sites_ext.ttl
SAMPLES += $(TTL_BASE)/AMS_asset_ext.ttl
SAMPLES += $(TTL_BASE)/AMS_site_deployments.ttl
SAMPLES += $(TTL_BASE)/AMS_station_deployments.ttl
SAMPLES += $(TTL_BASE)/AMS_issue_log_ext.ttl

# Flux Samples
SAMPLES += $(TTL_BASE)/flux_sites.ttl
SAMPLES += $(TTL_BASE)/flux_datasets.ttl
SAMPLES += $(TTL_BASE)/flux_processing_configs.ttl

SCHEMAS = $(RECORDS:%=build/schema/%.schema.json)

CONTEXTS = $(RECORDS:%=build/context/%.context.jsonld)

REPORTS = $(SAMPLES:$(TTL_BASE)/%.ttl=$(VAL)/%.ttl)

default: data

data: validate reports full_validation
all: validate schemas contexts reports full_validation

pull:
	docker pull $(IMAGE)

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: $(SAMPLES)
reports: $(REPORTS)
full_validation: $(VAL)/full_report.ttl
	grep -q -E "conforms\s+true" $^

validate: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd validate $^

build/schema/%.schema.json: $(SCHEMA_FILE) | build/schema
	$(RUN) record-spec-cmd json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

build/context/%.context.jsonld: $(SCHEMA_FILE) | build/context
	$(RUN) record-spec-cmd json-ld -r $(*F) -o $@ $^

$(SHACL_BASE)/fdri_shacl.ttl: $(SCHEMA_FILE) | $(SHACL_BASE)
	$(RUN) record-spec-cmd shacl --closed -o $@ $^

$(SHACL_BASE)/fdri_shacl_with_refs.ttl: $(SCHEMA_FILE) | $(SHACL_BASE)
	$(RUN) record-spec-cmd shacl --with-reference-type-validation -o $@ $^

clean:
	rm -f $(SCHEMA_BASE)/*.schema.json
	rm -f $(SCHEMA_BASE)/*.context.jsonld
	rm -rf build

build:
	mkdir -p build

build/schema:
	mkdir -p build/schema

build/context:
	mkdir -p build/context

build/validation:
	mkdir -p build/validation

build/shacl:
	mkdir -p build/shacl

build/data:
	mkdir -p build/data

build/instrumentation_parameters.csv: $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/SITE_INSTRUMENTATION.csv $(SRC)/MEASURES.csv $(SQL)/instrumentation_parameters.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/instrumentation_parameters.sql"

build/landCoverLcm.csv: $(SRC)/LAND_COVER_LCM.csv $(SQL)/landCoverLcm.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/landCoverLcm.sql"

build/landCoverObservations.csv: $(SRC)/LAND_COVER_OBSERVED.csv $(SQL)/landCoverObservations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/landCoverObservations.sql"

build/phenocam_mask_config.csv: $(SRC)/PHENOCAM_MASKS.csv $(SQL)/phenocam_mask_config.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/phenocam_mask_config.sql"

build/sensor_deployments.csv: $(SRC)/SITE_INSTRUMENTATION.csv $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/MEASURES.csv $(SQL)/sensor_deployments.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_deployments.sql"

build/site_slots.csv: $(SRC)/SITE_INSTRUMENTATION.csv $(SRC)/SENSOR_SLOT_IDS.csv $(SQL)/site_slots.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/site_slots.sql"

build/sensor_faults.csv: $(SRC)/SENSOR_FAULTS.csv $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/SITE_INSTRUMENTATION.csv $(SQL)/sensor_faults.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_faults.sql"

build/sensor_firmware_configurations.csv: $(SRC)/Firmware_history.csv $(SQL)/sensor_firmware_configurations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_firmware_configurations.sql"

build/siteVariance.csv: $(SRC)/SITES.csv $(SQL)/siteLayout.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/siteLayout.sql"

build/timeseries_measures_cosmos.csv: $(SRC)/TIMESERIES_DEFS_COSMOS.csv $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SQL)/timeseries_measures_cosmos.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/timeseries_measures_cosmos.sql"

build/timeseries_measures_fdri.csv: $(SRC)/TIMESERIES_DEFS_FDRI.csv $(SRC)/TIMESERIES_IDS_FDRI.csv $(SQL)/timeseries_measures_fdri.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/timeseries_measures_fdri.sql"

build/timeseries_measures_nmdb.csv: $(SRC)/TIMESERIES_DEFS_NMDB.csv $(SRC)/TIMESERIES_IDS_NMDB.csv $(SQL)/timeseries_measures_nmdb.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/timeseries_measures_nmdb.sql"

build/COSMOS_TS_ID_DEPENDENCIES_LINES.json: $(SRC)/COSMOS_TS_ID_DEPENDENCIES.json $(SQL)/ts_id_dependencies.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/ts_id_dependencies.jq < $(SRC)/COSMOS_TS_ID_DEPENDENCIES.json > $@"

build/cosmos_ts_parameters.csv: $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/MEASURES.csv $(SQL)/cosmos_ts_parameters.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/cosmos_ts_parameters.sql"

build/CORRECTION_CONFIGS_LINES.json: $(SRC)/CORRECTION_CONFIGS.json $(SQL)/CORRECTION_CONFIGS_LINES.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/CORRECTION_CONFIGS_LINES.jq < $(SRC)/CORRECTION_CONFIGS.json > $@"

build/fdri_site_assets.csv: $(SRC)/fdri_sites.csv $(SRC)/fdri_asset.csv $(SQL)/fdri_site_assets.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/fdri_site_assets.sql"

build/fdri_measure_ext.csv: $(SRC)/fdri_measure.csv $(SRC)/intervalDuration.csv $(SQL)/fdri_measure_ext.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/fdri_measure_ext.sql"

build/fdri_asset_loc_history.csv: $(SRC)/fdri_sites.csv $(SRC)/fdri_loc_history.csv $(SQL)/fdri_asset_loc_history.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/fdri_asset_loc_history.sql"

build/flowstick_surveys.csv: $(SRC)/nivu_flowstick/metadata.parquet $(SQL)/flowstick_surveys.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/flowstick_surveys.sql"

build/rca_sites.csv: $(SRC)/rca_excel/sites.parquet $(SQL)/rca_sites.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/rca_sites.sql"

build/rca_surveys.csv: $(SRC)/rca_excel/metadata.parquet $(SQL)/rca_surveys.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/rca_surveys.sql"

build/sontek_surveys.csv: $(SRC)/sontek/metadata.parquet $(SQL)/sontek_surveys.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sontek_surveys.sql"

build/ts_temporal.csv: $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/TIMESERIES_TEMPORAL_EXTENTS_COSMOS.csv $(SQL)/ts_temporal.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/ts_temporal.sql"

build/AMS_sites_ext.csv: $(SRC)/AMS_mill_site.csv $(SQL)/AMS_sites_ext.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/AMS_sites_ext.sql"

build/AMS_station_deployments.csv: build/AMS_sites_ext.csv build/AMS_asset_ext.csv $(SRC)/AMS_mill_asset_location_history.csv $(SQL)/AMS_station_deployments.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/AMS_station_deployments.sql"

build/AMS_site_deployments.csv: build/AMS_sites_ext.csv build/AMS_asset_ext.csv $(SRC)/AMS_mill_asset_location_history.csv $(SQL)/AMS_site_deployments.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/AMS_site_deployments.sql"

build/AMS_issue_log_ext.csv: $(SRC)/AMS_issue_log.csv $(SRC)/AMS_issue_log_notes.csv build/AMS_sites_ext.csv $(SQL)/AMS_issue_log_ext.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/AMS_issue_log_ext.sql"

build/AMS_asset_ext.csv: $(SRC)/AMS_mill_assets.csv build/AMS_sites_ext.csv $(SQL)/AMS_asset_ext.sql
	$(RUN) /bin/bash -c "duckdb < $(SQL)/AMS_asset_ext.sql"

build/FLAG_TYPES_LINES.json: $(SRC)/flag_types.json $(SQL)/array_to_lines.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/array_to_lines.jq < $(SRC)/flag_types.json > $@"

build/CORE_FLAG_SCHEME_LINES.json: $(SRC)/CORE_flag_scheme.json | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/array_to_lines.jq < $(SRC)/CORE_flag_scheme.json > $@"

$(TTL_BASE)/CORE_FLAG_SCHEME.ttl: $(TPL)/namespaces.yaml $(TPL)/flag_scheme.yaml build/CORE_FLAG_SCHEME_LINES.json | build/data
	$(MAPPER) $(TPL)/flag_scheme.yaml build/CORE_FLAG_SCHEME_LINES.json $@

build/COSMOS_FLAG_SCHEMES_LINES.json: $(SRC)/COSMOS_flag_schemes.json $(SQL)/array_to_lines.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/array_to_lines.jq < $(SRC)/COSMOS_flag_schemes.json > $@"

$(TTL_BASE)/COSMOS_FLAG_SCHEMES.ttl: $(TPL)/namespaces.yaml $(TPL)/flag_scheme.yaml build/COSMOS_FLAG_SCHEMES_LINES.json | build/data
	$(MAPPER) $(TPL)/flag_scheme.yaml build/COSMOS_FLAG_SCHEMES_LINES.json $@

build/FDRI_FLAG_SCHEMES_LINES.json: $(SRC)/FDRI_flag_schemes.json $(SQL)/array_to_lines.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/array_to_lines.jq < $(SRC)/FDRI_flag_schemes.json > $@"

$(TTL_BASE)/FDRI_FLAG_SCHEMES.ttl: $(TPL)/namespaces.yaml $(TPL)/flag_scheme.yaml build/FDRI_FLAG_SCHEMES_LINES.json | build/data
	$(MAPPER) $(TPL)/flag_scheme.yaml build/FDRI_FLAG_SCHEMES_LINES.json $@

build/timeseries_flags_cosmos.csv: $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/COSMOS_flag_definitions.csv $(SQL)/timeseries_flags_cosmos.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/timeseries_flags_cosmos.sql"

# Flux

build/flux_sites.json: $(SRC)/flux/sites.json | build
	$(RUN) /bin/bash -c "jq -c "\".sites[]\"" < $(SRC)/flux/sites.json > $@"

build/flux_datasets.json: $(SRC)/flux/datasets.json | build
	$(RUN) /bin/bash -c "jq -c "\".datasets[]\"" < $(SRC)/flux/datasets.json > $@"

build/flux_processing_configs.json: $(SRC)/flux/processing_configs.json $(SQL)/flux_processing_configs.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/flux_processing_configs.jq < $(SRC)/flux/processing_configs.json > $@"

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml $(SRC)/%.csv | build/data
	$(MAPPER) $(TPL)/$*.yaml $(SRC)/$*.csv $@

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml $(SRC)/%.json | build/data
	$(MAPPER) $(TPL)/$*.yaml $(SRC)/$*.json $@

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml build/%.csv | build/data
	$(MAPPER) $(TPL)/$*.yaml build/$*.csv $@

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml build/%.json | build/data
	$(MAPPER) $(TPL)/$*.yaml build/$*.json $@

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/gridded_metadata.yaml $(SRC)/gridded/%.cdl | build/data
	$(GRIDMAP) --type cdl --base-url http://fdri.ceh.ac.uk/id/dataset/$* --output $@ $(TPL)/gridded_metadata.yaml $(SRC)/gridded/$*.cdl

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/gridded_metadata.yaml $(SRC)/gridded/%.zarr.json | build/data
	$(GRIDMAP) --type zarr-meta --base-url http://fdri.ceh.ac.uk/id/dataset/$* --output $@ $(TPL)/gridded_metadata.yaml $(SRC)/gridded/$*.zarr.json

$(TTL_BASE)/FDRI_QC_CONFIGS.ttl: $(TPL)/namespaces.yaml $(TPL)/QC_CONFIGS.yaml $(SRC)/FDRI_QC_CONFIGS.csv | build/data
	$(MAPPER) $(TPL)/QC_CONFIGS.yaml $(SRC)/FDRI_QC_CONFIGS.csv $@

$(VAL)/%.ttl: $(TTL_BASE)/%.ttl $(SHACL_BASE)/fdri_shacl.ttl  | build/validation
	$(RUN) /bin/bash -c "shacl v -d $(TTL_BASE)/$*.ttl -s $(SHACL_BASE)/fdri_shacl.ttl > $@"

ontology/build/fdri-metadata.rdfs.ttl:
	make -C ontology build/fdri-metadata.rdfs.ttl

$(VAL)/data.nt: $(SAMPLES) ontology/owl/fdri-metadata.ttl ontology/build/fdri-metadata.rdfs.ttl | build/validation
	$(RUN) riot --output=nt $^ > $@

$(VAL)/full_report.ttl: $(VAL)/data.nt $(SHACL_BASE)/fdri_shacl_with_refs.ttl | build/validation
	$(RUN) shacl v -d $(VAL)/data.nt -s $(SHACL_BASE)/fdri_shacl_with_refs.ttl > $@
