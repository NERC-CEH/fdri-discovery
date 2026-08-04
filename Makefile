MAKEFLAGS += -j 4
IMAGE=293385631482.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/record-spec-tools/unstable:1.0-SNAPSHOT
RUN=docker run --rm -v .:/data ${IMAGE}

SCHEMA_BASE = sample_data/build/schema
SRC = sample_data/src
SQL = sample_data/sql
VAL = build/validation
TPL = sample_data/templates
# TTL_BASE: The build directory for the output of the template processor
TTL_BASE = build/data
# ANNOTATED_BASE: The build directory for the output of the template processor with provenance annotations
ANNOTATED_BASE = build/annotated
SHACL_BASE = build/shacl
SCHEMA_FILE = ontology/schema/fdri.recordspec.yaml
RAW_SOURCE_BUCKET := $(shell awk '$$1==ENVIRON["GITHUB_REF_NAME"] {print $$4}' branch.map)
RAW_SOURCE_BUCKET := $(or ${RAW_SOURCE_BUCKET},fdri-dummy-ingested)
PROCESSED_SOURCE_BUCKET := $(shell awk '$$1==ENVIRON["GITHUB_REF_NAME"] {print $$5}' branch.map)
PROCESSED_SOURCE_BUCKET := $(or ${PROCESSED_SOURCE_BUCKET},fdri-dummy-processed)
MAPPER = mapper -g RAW_SOURCE_BUCKET=${RAW_SOURCE_BUCKET} -g PROCESSED_SOURCE_BUCKET=${PROCESSED_SOURCE_BUCKET}
GRIDMAP = gridded-mapper
ACTIVITY_ID := $(shell uuidgen)

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

SAMPLES += $(TTL_BASE)/AGGREGATION.ttl
SAMPLES += $(TTL_BASE)/ANNOTATION_PROPERTIES.ttl
SAMPLES += $(TTL_BASE)/CONFIGURATION_PROPERTIES.ttl
SAMPLES += $(TTL_BASE)/CONFIGURATION_TYPES.ttl
SAMPLES += $(TTL_BASE)/COSMOS_FLAG_SCHEMES.ttl
SAMPLES += $(TTL_BASE)/cosmos_ts_parameters.ttl
SAMPLES += $(TTL_BASE)/CORRECTION_METHOD_PARAMS.ttl
SAMPLES += $(TTL_BASE)/CORRECTION_PARAMS.ttl
SAMPLES += $(TTL_BASE)/FACILITY_GROUP_TYPES.ttl
SAMPLES += $(TTL_BASE)/FACILITY_USAGE_ROLES.ttl
SAMPLES += $(TTL_BASE)/FLAG_TYPES_LINES.ttl
SAMPLES += $(TTL_BASE)/FORMATS.ttl
SAMPLES += $(TTL_BASE)/CORE_FLAG_SCHEME.ttl
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
SAMPLES += $(TTL_BASE)/sensor_deployments.ttl
SAMPLES += $(TTL_BASE)/sensor_faults.ttl
SAMPLES += $(TTL_BASE)/sensor_firmware_configurations.ttl
SAMPLES += $(TTL_BASE)/SITE_CALIBRATION_INFO.ttl
SAMPLES += $(TTL_BASE)/SITES_COSMOS.ttl
SAMPLES += $(TTL_BASE)/VWC_THRESHOLDS_COSMOS.ttl
SAMPLES += $(TTL_BASE)/siteVariance.ttl
SAMPLES += $(TTL_BASE)/TIME_ANCHOR.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_IDS_COSMOS.ttl
SAMPLES += $(TTL_BASE)/timeseries_flags_cosmos.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_IDS_FDRI.ttl
SAMPLES += $(TTL_BASE)/UNITS.ttl

# Stop-gap temporal extents
SAMPLES += $(TTL_BASE)/ts_temporal.ttl

# COSMOS processing configurations
SAMPLES += $(TTL_BASE)/processing_configurations_cosmos.ttl
SAMPLES += $(TTL_BASE)/processing_plans_cosmos.ttl

# NRFA
SAMPLES += $(TTL_BASE)/SITES_NRFA.ttl

# FDRI SAMPLES
SAMPLES += $(TTL_BASE)/SITES_FDRI.ttl
SAMPLES += $(TTL_BASE)/fdri_site_assets.ttl
# SAMPLES += $(TTL_BASE)/fdri_measure_ext.ttl
SAMPLES += $(TTL_BASE)/fdri_asset_loc_history.ttl
SAMPLES += $(TTL_BASE)/FDRI_FLAG_SCHEMES.ttl
SAMPLES += $(TTL_BASE)/fdri_ts_parameters.ttl
SAMPLES += $(TTL_BASE)/processing_configurations_fdri.ttl
SAMPLES += $(TTL_BASE)/processing_plans_fdri.ttl

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
SAMPLES += $(TTL_BASE)/SITES_NMDB.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_IDS_NMDB.ttl
SAMPLES += $(TTL_BASE)/NMDB_FLAG_SCHEMES.ttl
SAMPLES += $(TTL_BASE)/timeseries_flags_nmdb.ttl
SAMPLES += $(TTL_BASE)/processing_configurations_nmdb.ttl
SAMPLES += $(TTL_BASE)/processing_plans_nmdb.ttl
SAMPLES += $(TTL_BASE)/nmdb_ts_parameters.ttl

# Flux Samples
SAMPLES += $(TTL_BASE)/flux_sites.ttl
SAMPLES += $(TTL_BASE)/flux_datasets.ttl
SAMPLES += $(TTL_BASE)/processing_configurations_flux.ttl
SAMPLES += $(TTL_BASE)/processing_plans_flux.ttl

SCHEMAS = $(RECORDS:%=build/schema/%.schema.json)

CONTEXTS = $(RECORDS:%=build/context/%.context.jsonld)

REPORTS = $(SAMPLES:$(TTL_BASE)/%.ttl=$(VAL)/%.ttl)

ANNOTATED = $(SAMPLES:$(TTL_BASE)/%.ttl=$(ANNOTATED_BASE)/%.ttl)

CLEANUP_SCRIPT = build/cleanup.ru

default: data

data: build/activity-start.ttl .WAIT validate reports full_validation .WAIT build/data/activity-$(ACTIVITY_ID).ttl

all: build/activity-start.ttl .WAIT validate schemas contexts reports full_validation .WAIT $(ANNOTATED) build/annotated/activity-$(ACTIVITY_ID).ttl

pull:
	docker pull $(IMAGE)

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: build/activity-start.ttl .WAIT $(SAMPLES) .WAIT build/data/activity-$(ACTIVITY_ID).ttl
reports: $(REPORTS)

annotated: build/activity-start.ttl .WAIT $(ANNOTATED) .WAIT build/annotated/activity-$(ACTIVITY_ID).ttl

publish: annotated $(CLEANUP_SCRIPT)
	./publish.sh

publish-local: annotated $(CLEANUP_SCRIPT)
	./publish-local.sh

build/cleanup.ru: | build
	sed -e 's/{activity}/http:\/\/fdri.ceh.ac.uk\/id\/activity\/$(ACTIVITY_ID)/g' sample_data/cleanup.ru.tpl > $@

build/activity-start.ttl: build/data
	./activity-start.sh $(ACTIVITY_ID) > $@

build/activity-end.ttl: build/data
	./activity-end.sh $(ACTIVITY_ID) > $@

build/data/activity-$(ACTIVITY_ID).ttl: build/activity-start.ttl build/activity-end.ttl | build/annotated
	cat $^ > $@

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

build/annotated:
	mkdir -p build/annotated

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

build/sensor_faults.csv: $(SRC)/SENSOR_FAULTS.csv $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/SITE_INSTRUMENTATION.csv $(SQL)/sensor_faults.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_faults.sql"

build/sensor_firmware_configurations.csv: $(SRC)/Firmware_history.csv $(SQL)/sensor_firmware_configurations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_firmware_configurations.sql"

build/siteVariance.csv: $(SRC)/SITES_COSMOS.csv $(SQL)/siteLayout.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/siteLayout.sql"

build/cosmos_ts_parameters.csv: $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/MEASURES.csv $(SQL)/cosmos_ts_parameters.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/cosmos_ts_parameters.sql"

build/fdri_site_assets.csv: $(SRC)/SITES_FDRI.csv $(SRC)/fdri_asset.csv $(SQL)/fdri_site_assets.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/fdri_site_assets.sql"

build/fdri_ts_parameters.csv: $(SRC)/TIMESERIES_IDS_FDRI.csv $(SRC)/MEASURES.csv $(SQL)/fdri_ts_parameters.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/fdri_ts_parameters.sql"

build/fdri_measure_ext.csv: $(SRC)/fdri_measure.csv $(SRC)/intervalDuration.csv $(SQL)/fdri_measure_ext.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/fdri_measure_ext.sql"

build/fdri_asset_loc_history.csv: $(SRC)/SITES_FDRI.csv $(SRC)/fdri_loc_history.csv $(SQL)/fdri_asset_loc_history.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/fdri_asset_loc_history.sql"

build/ts_temporal.csv: $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/TIMESERIES_TEMPORAL_EXTENTS_COSMOS.csv $(SQL)/ts_temporal.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/ts_temporal.sql"

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

build/NMDB_FLAG_SCHEMES_LINES.json: $(SRC)/NMDB_flag_schemes.json $(SQL)/array_to_lines.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/array_to_lines.jq < $(SRC)/NMDB_flag_schemes.json > $@"

$(TTL_BASE)/NMDB_FLAG_SCHEMES.ttl: $(TPL)/namespaces.yaml $(TPL)/flag_scheme.yaml build/NMDB_FLAG_SCHEMES_LINES.json | build/data
	$(MAPPER) $(TPL)/flag_scheme.yaml build/NMDB_FLAG_SCHEMES_LINES.json $@

build/timeseries_flags_cosmos.csv: $(SRC)/TIMESERIES_IDS_COSMOS.csv $(SRC)/COSMOS_flag_definitions.csv $(SQL)/timeseries_flags_cosmos.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/timeseries_flags_cosmos.sql"

build/timeseries_flags_fdri.csv: $(SRC)/TIMESERIES_IDS_FDRI.csv $(SRC)/FDRI_flag_definitions.csv $(SQL)/timeseries_flags_fdri.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/timeseries_flags_fdri.sql"

build/timeseries_flags_nmdb.csv: $(SRC)/TIMESERIES_IDS_NMDB.csv $(SRC)/NMDB_flag_definitions.csv $(SQL)/timeseries_flags_nmdb.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/timeseries_flags_nmdb.sql"

build/processing_configurations_cosmos.json: $(SRC)/processing_configurations_cosmos.json $(SQL)/processing_configurations.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/processing_configurations.jq < $(SRC)/processing_configurations_cosmos.json > $@"

$(TTL_BASE)/processing_configurations_cosmos.ttl: $(TPL)/namespaces.yaml $(TPL)/processing_configurations.yaml build/processing_configurations_cosmos.json | build/data
	$(MAPPER) $(TPL)/processing_configurations.yaml build/processing_configurations_cosmos.json $@

build/processing_plans_cosmos.json: $(SRC)/processing_plans_cosmos.json $(SQL)/processing_plans.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/processing_plans.jq < $(SRC)/processing_plans_cosmos.json > $@"

$(TTL_BASE)/processing_plans_cosmos.ttl: $(TPL)/namespaces.yaml $(TPL)/processing_plans.yaml build/processing_plans_cosmos.json | build/data
	$(MAPPER) $(TPL)/processing_plans.yaml build/processing_plans_cosmos.json $@

build/processing_configurations_nmdb.json: $(SRC)/processing_configurations_nmdb.json $(SQL)/processing_configurations.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/processing_configurations.jq < $(SRC)/processing_configurations_nmdb.json > $@"

$(TTL_BASE)/processing_configurations_nmdb.ttl: $(TPL)/namespaces.yaml $(TPL)/processing_configurations.yaml build/processing_configurations_nmdb.json | build/data
	$(MAPPER) $(TPL)/processing_configurations.yaml build/processing_configurations_nmdb.json $@

build/processing_plans_nmdb.json: $(SRC)/processing_plans_nmdb.json $(SQL)/processing_plans.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/processing_plans.jq < $(SRC)/processing_plans_nmdb.json > $@"

$(TTL_BASE)/processing_plans_nmdb.ttl: $(TPL)/namespaces.yaml $(TPL)/processing_plans.yaml build/processing_plans_nmdb.json | build/data
	$(MAPPER) $(TPL)/processing_plans.yaml build/processing_plans_nmdb.json $@

build/nmdb_ts_parameters.csv: $(SRC)/TIMESERIES_IDS_NMDB.csv $(SRC)/MEASURES.csv $(SQL)/nmdb_ts_parameters.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/nmdb_ts_parameters.sql"

# FDRI

build/processing_configurations_fdri.json: $(SRC)/processing_configurations_fdri.json $(SQL)/processing_configurations.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/processing_configurations.jq < $(SRC)/processing_configurations_fdri.json > $@"

$(TTL_BASE)/processing_configurations_fdri.ttl: $(TPL)/namespaces.yaml $(TPL)/processing_configurations.yaml build/processing_configurations_fdri.json | build/data
	$(MAPPER) $(TPL)/processing_configurations.yaml build/processing_configurations_fdri.json $@

build/processing_plans_fdri.json: $(SRC)/processing_plans_fdri.json $(SQL)/processing_plans.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/processing_plans.jq < $(SRC)/processing_plans_fdri.json > $@"

$(TTL_BASE)/processing_plans_fdri.ttl: $(TPL)/namespaces.yaml $(TPL)/processing_plans.yaml build/processing_plans_fdri.json | build/data
	$(MAPPER) $(TPL)/processing_plans.yaml build/processing_plans_fdri.json $@

# Flux

build/flux_sites.json: $(SRC)/flux/sites.json | build
	$(RUN) /bin/bash -c "jq -c "\".sites[]\"" < $(SRC)/flux/sites.json > $@"

build/flux_datasets.json: $(SRC)/flux/datasets.json | build
	$(RUN) /bin/bash -c "jq -c "\".datasets[]\"" < $(SRC)/flux/datasets.json > $@"

build/processing_configurations_flux.json: $(SRC)/processing_configurations_flux.json $(SQL)/processing_configurations.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/processing_configurations.jq < $(SRC)/processing_configurations_flux.json > $@"

$(TTL_BASE)/processing_configurations_flux.ttl: $(TPL)/namespaces.yaml $(TPL)/processing_configurations.yaml build/processing_configurations_flux.json | build/data
	$(MAPPER) $(TPL)/processing_configurations.yaml build/processing_configurations_flux.json $@

build/processing_plans_flux.json: $(SRC)/processing_plans_flux.json $(SQL)/processing_plans.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/processing_plans.jq < $(SRC)/processing_plans_flux.json > $@"

$(TTL_BASE)/processing_plans_flux.ttl: $(TPL)/namespaces.yaml $(TPL)/processing_plans.yaml build/processing_plans_flux.json | build/data
	$(MAPPER) $(TPL)/processing_plans.yaml build/processing_plans_flux.json $@

# Common name-based processing targets

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

$(VAL)/%.ttl: $(TTL_BASE)/%.ttl $(SHACL_BASE)/fdri_shacl.ttl  | build/validation
	$(RUN) /bin/bash -c "shacl v -d $(TTL_BASE)/$*.ttl -s $(SHACL_BASE)/fdri_shacl.ttl > $@"

# Build the RDFS schema for the FDRI ontology

ontology/build/fdri-metadata.rdfs.ttl:
	make -C ontology build/fdri-metadata.rdfs.ttl

# Full validation report

$(VAL)/data.nt: $(SAMPLES) ontology/owl/fdri-metadata.ttl ontology/build/fdri-metadata.rdfs.ttl | build/validation
	$(RUN) riot --output=nt $^ > $@

$(VAL)/full_report.ttl: $(VAL)/data.nt $(SHACL_BASE)/fdri_shacl_with_refs.ttl | build/validation
	$(RUN) shacl v -d $(VAL)/data.nt -s $(SHACL_BASE)/fdri_shacl_with_refs.ttl > $@

# Annotate TTL files with activity provenance
$(ANNOTATED_BASE)/%.ttl: $(TTL_BASE)/%.ttl | build/annotated
	cp $^ $@
	echo "<http://fdri.ceh.ac.uk/graph/$(^F:build/%=%)> <http://fdri.ceh.ac.uk/vocab/metadata/wasModifiedBy> <http://fdri.ceh.ac.uk/id/activity/${ACTIVITY_ID}> ." >> $@
