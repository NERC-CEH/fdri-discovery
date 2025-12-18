# Runbook: FDRI Ontology Update

> **NOTE** This document is currently a proposal/discussion document rather than a validated and adopted runbook.

## Overview and current status

An update to the FDRI Ontology will impact a number of dependent systems and so the roll-out of a new version of the ontology needs to be managed so as to minimise any disruption.

The onotology is currently a dependency for the following systems / aspects of the FDRI project environment:

| System | GH Repo | Nature of Dependency | Impact of change |
|--------|---------|----------------------|------------------|
FDRI data | [fdri-discovery](https://github.com/NERC-CEH/fdri-discovery) | Used for validation of data processing outputs | Data mapping configurations must be updated to ensure outputs are valid against the updated model |
FDRI metadata API | [dri-metadata-api](https://github.com/NERC-CEH/dri-metadata-api) | API endpoints expose properties defined in the model | The API has its own model schema which is derived from the FDRI ontology. Endpoint configurations depend on this schema and may need to be updated.
| | [dri-timeseries-processor](https://github.com/NERC-CEH/dri-timeseries-processor)
| | [dri-data-api](https://github.com/NERC-CEH/dri-data-api)
| | [dri-ingestion](https://github.com/NERC-CEH/dri-ingestion) | Looks up data in the metadata API | Indirect dependency via dri-metadata-api
| | [dri-metadata-ingest-config](https://github.com/NERC-CEH/dri-metadata-ingest-config) | Data produced should conform to the recordspec schema | A change to the model may require changes to one or more mapping templates in the ingester. NOTE: There is currently no schema validation performed on the output of the ingester.
| TBD | OTHER REPOS | 

The current context of operation is that there is a staging environment and a staging-dev environment.
The staging-dev environment only hosts a podium data store, fuseki consumer, metadata ingester, and metadata API.


## Ontology Artefacts

The ontology is currently maintained in two parallel forms:

* An OWL model for presentation of the ontology to the wider RDF/Linked Data community.
* A recordspec schema which can be used directly or indirectly in toolchains for validation and API generation

From the recordspec schema we currently produce:

* SHACL files for RDF data validation.
* A modelspec schema to drive the API
* JSON schemas and JSON-LD context files for validating the RDF data as JSON-LD

The SHACL files are used in the `fdri-discovery` repo to ensure that the outputs of the RDF mappers conform to the model. Currently the validation is inspected manually at the time when the RDF mappers are updated. SHACL validation failures do not currently cause the data processing to fail.

The modelspec schema is used to drive the API in the `dri-metadata-api` repository. This file is currently manually generated and copied into the repository.

The JSON schemas and JSON-LD context files are currently only used to validate some hand-crafted sample data files in the fdri-discovery repo. These artefacts could probably be removed with little to no impact.

## Model Update Categories

Model changes can be divided into two broad categories. 

Non-breaking changes are changes that extend the model or modify the model in such a way that all existing data remains valid and that the JSON representation of the data remains unchanged. Non-breaking changes include changes that introduce new types or properties to the model, extend the set of allowed values for some properties, or that make previously required properties optional.

Breaking changes are changes that either result in some existing data becoming invalid or which change the JSON representation of the data in a way that would impact users of the Metadata API. Breaking changes include the removal or renaming of existing properties that are currently in use; the renaming or removal of classes that are currently in use; making previously optional properties required, or changing a single-valued property into a multi-valued property or vice-versa.

## Model Update Roll-out

A model update that contains only non-breaking changes should be safe to roll-out to the staging environment for verification before being rolled out to the production environment. However it is possible (or perhaps even likely) that the non-breaking changes have been made to allow for new features in downstream systems or to support new types of data, in which case the model roll-out could be initially made to the staging-dev environment and remain in that environment until the updates to the downstream systems are completed.

A model update that contains breaking changes should be first rolled out to the staging-dev environment so that the downstream impact of the changes can be addressed before then rolling out the model update and the updated downstream dependencies to the staging environment for verification.


## Proposal

1. Ensure a changelog of model updates is maintained. The changelong should note both breaking and non-breaking changes. Where applicable the changelog entry should refer to any GitHub ticket(s) related to the change so that downstream users can better understand the context of and motivation for the change.
2. Generate a release package in GitHub when the repository is tagged with a release version tag. The release package should contain the source OWL and recordspec files as well as the generated SHACL, JSON Schemas, JSON-LD contexts, and modelspec files.
3. Update processes in downstream repositories to make use of a release artefact or to include the model repository as a git submodule (at the discretion of the repository owner). Submodules should be pinned to a commit that has been tagged as a release in the model repository.
4. Extend the staging-dev environment to host the other downstream services that depend on the model. Breaking model changes may cause failures in downstream services, and it should be possible to address those failures and update the services in the staging-dev environment
