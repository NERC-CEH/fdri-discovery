IMAGE=293385631482.dkr.ecr.eu-west-1.amazonaws.com/epimorphics/record-spec-tools/unstable:1.0-SNAPSHOT
RUN=docker run --rm -v .:/data ${IMAGE}

SCHEMA_BASE = sample_data/build/schema
SRC = sample_data/src
SQL = sample_data/sql
VAL = build/validation
TPL = sample_data/templates
TTL_BASE = build/data
SHACL_BASE = build/shacl
SCHEMA_FILE = sample_data/schema/fdri.recordspec.yaml
MAPPER = mapper

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
SAMPLES += $(TTL_BASE)/CORRECTION_FACTORS.ttl
SAMPLES += $(TTL_BASE)/CORRECTION_METHODS.ttl
SAMPLES += $(TTL_BASE)/infill_config.ttl
SAMPLES += $(TTL_BASE)/INSTRUMENTATION.ttl
SAMPLES += $(TTL_BASE)/instrumentation_parameters.ttl
SAMPLES += $(TTL_BASE)/LAND_COVER_LCM_CLASSES.ttl
SAMPLES += $(TTL_BASE)/landCoverLcm.ttl
SAMPLES += $(TTL_BASE)/landCoverObservations.ttl
SAMPLES += $(TTL_BASE)/PARAMETER_RANGES_QC.ttl
SAMPLES += $(TTL_BASE)/PARAMETERS_IDS.ttl
# SAMPLES += $(TTL_BASE)/phenocam_mask_config.ttl
SAMPLES += $(TTL_BASE)/processingLevels.ttl
SAMPLES += $(TTL_BASE)/sensor_calibrations.ttl
SAMPLES += $(TTL_BASE)/sensor_deployments.ttl
SAMPLES += $(TTL_BASE)/sensor_faults.ttl
SAMPLES += $(TTL_BASE)/sensor_firmware_configurations.ttl
SAMPLES += $(TTL_BASE)/SITES.ttl
SAMPLES += $(TTL_BASE)/siteVariance.ttl
SAMPLES += $(TTL_BASE)/STATISTICS.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_DEFS.ttl
SAMPLES += $(TTL_BASE)/TIMESERIES_IDS.ttl
SAMPLES += $(TTL_BASE)/time_series_measures.ttl
SAMPLES += $(TTL_BASE)/tsdef_dependencies.ttl
SAMPLES += $(TTL_BASE)/tsdef_methods.ttl
SAMPLES += $(TTL_BASE)/UNITS.ttl

SCHEMAS = $(RECORDS:%=build/schema/%.schema.json)

CONTEXTS = $(RECORDS:%=build/context/%.context.jsonld)

REPORTS = $(SAMPLES:$(TTL_BASE)/%.ttl=$(VAL)/%.ttl)

data: validate reports full_validation
all: validate schemas contexts reports full_validation

pull:
	docker pull $(IMAGE)

schemas: $(SCHEMAS)
contexts: $(CONTEXTS)
samples: $(SAMPLES)
reports: $(REPORTS)
full_validation: $(VAL)/full_report.ttl

validate: $(SCHEMA_FILE)
	$(RUN) record-spec-cmd validate $^

build/schema/%.schema.json: $(SCHEMA_FILE) | build/schema
	$(RUN) record-spec-cmd json-schema --allow-jsonld-context --allow-json-schema-ref --with-optional-type --no-additional-properties -r $(*F) -o $@ $^

build/context/%.context.jsonld: $(SCHEMA_FILE) | build/context
	$(RUN) record-spec-cmd json-ld -r $(*F) -o $@ $^

$(SHACL_BASE)/fdri_shacl.ttl: $(SCHEMA_FILE) | $(SHACL_BASE)
	$(RUN) record-spec-cmd shacl -o $@ $^

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

build/instrumentation_parameters.csv: $(SRC)/TIMESERIES_IDS.csv $(SRC)/SENSOR_SLOT_IDS.csv $(SQL)/instrumentation_parameters.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/instrumentation_parameters.sql"

build/landCoverLcm.csv: $(SRC)/LAND_COVER_LCM.csv $(SQL)/landCoverLcm.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/landCoverLcm.sql"

build/landCoverObservations.csv: $(SRC)/LAND_COVER_OBSERVED.csv $(SQL)/landCoverObservations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/landCoverObservations.sql"

build/phenocam_mask_config.csv: $(SRC)/PHENOCAM_MASKS.csv $(SQL)/phenocam_mask_config.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/phenocam_mask_config.sql"

build/sensor_calibrations.csv: $(SRC)/calib_factors_nr01_anem.csv $(SRC)/SENSOR_SLOT_IDS.csv  $(SRC)/SITE_INSTRUMENTATION.csv $(SRC)/TIMESERIES_DEFS.csv $(SRC)/TIMESERIES_IDS.csv $(SQL)/sensor_calibrations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_calibrations.sql"

build/sensor_deployments.csv: $(SRC)/SITE_INSTRUMENTATION.csv $(SRC)/SENSOR_SLOT_IDS.csv $(SRC)/TIMESERIES_IDS.csv $(SQL)/sensor_deployments.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_deployments.sql"

build/sensor_faults.csv: $(SRC)/SENSOR_FAULTS.csv $(SRC)/TIMESERIES_DEFS.csv build/sensor_deployments.csv $(SQL)/sensor_faults.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_faults.sql"

build/sensor_firmware_configurations.csv: $(SRC)/Firmware_history.csv $(SQL)/sensor_firmware_configurations.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/sensor_firmware_configurations.sql"

build/siteVariance.csv: $(SRC)/SITES.csv $(SQL)/siteLayout.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/siteLayout.sql"

build/time_series_measures.csv: $(SRC)/TIMESERIES_DEFS.csv $(SRC)/TIMESERIES_IDS.csv $(SQL)/time_series_measures.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/time_series_measures.sql"

build/tsdef_dependencies.csv: build/TIMESERIES_DEF_DEPENDENCIES_LINES.json $(SQL)/tsdef_dependencies.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/tsdef_dependencies.sql"

build/tsdef_methods.csv: build/TIMESERIES_DEF_DEPENDENCIES_LINES.json $(SQL)/tsdef_methods.sql | build
	$(RUN) /bin/bash -c "duckdb < $(SQL)/tsdef_methods.sql"

build/TIMESERIES_DEF_DEPENDENCIES_LINES.json: $(SRC)/TIMESERIES_DEF_DEPENDENCIES.json $(SQL)/TIMESERIES_DEF_DEPENDENCIES_LINES.jq | build
	$(RUN) /bin/bash -c "jq -c -f $(SQL)/TIMESERIES_DEF_DEPENDENCIES_LINES.jq < $(SRC)/TIMESERIES_DEF_DEPENDENCIES.json > $@"

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml $(SRC)/%.csv | build/data
	$(MAPPER) $(TPL)/$*.yaml $(SRC)/$*.csv $@

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml $(SRC)/%.json | build/data
	$(MAPPER) $(TPL)/$*.yaml $(SRC)/$*.json $@

$(TTL_BASE)/%.ttl: $(TPL)/namespaces.yaml $(TPL)/%.yaml build/%.csv | build/data
	$(MAPPER) $(TPL)/$*.yaml build/$*.csv $@

$(VAL)/%.ttl: $(TTL_BASE)/%.ttl $(SHACL_BASE)/fdri_shacl.ttl  | build/validation
	$(RUN) /bin/bash -c "shacl v -d $(TTL_BASE)/$*.ttl -s $(SHACL_BASE)/fdri_shacl.ttl > $@"

$(VAL)/data.nt: $(SAMPLES) ontology/owl/fdri-metadata.ttl | build/validation 
	$(RUN) riot --output=nt $^ > $@

$(VAL)/full_report.ttl: $(VAL)/data.nt $(SHACL_BASE)/fdri_shacl_with_refs.ttl | build/validation
	$(RUN) shacl v -d $(VAL)/data.nt -s $(SHACL_BASE)/fdri_shacl_with_refs.ttl > $@
