# Runbook: FDRI Ontology Update

> **NOTE** This document is currently a proposal/discussion document rather than a validated and adopted runbook.

## Overview and current status

An update to the FDRI Ontology will impact a number of dependent systems and so the roll-out of a new version of the ontology needs to be managed so as to minimise any disruption.

The onotology is currently a dependency for the following systems / aspects of the FDRI project environment:

| System | GH Repo | Nature of Dependency | Impact of change |
|--------|---------|----------------------|------------------|
FDRI data | fdri-discover repository | Used for validation of data processing outputs | Data mapping configurations must be updated to ensure outputs are valid against the updated model |
FDRI metadata API | dri-metadata-api | API endpoints expose properties defined in the model | The API has its own model schema which is derived from the FDRI ontology. Endpoint configurations depend on this schema and may need to be updated.
| TBD | OTHER REPOS | 

The current context of operation is that there is a single development environment. This limits the options for reducing disruption. Currently the FDRI ontology is stored in the same repository as the data mapping tools ([fdri-discovery](https://github.com/NERC-CEH/fdri-discovery)), although there is currently an open [ticket to move the model to its own repository](https://github.com/NERC-CEH/fdri-discovery/issues/160).

## Ontology Artefacts

The ontology is currently maintained in two parallel forms:

* An OWL model for presentation of the ontology to the wider RDF/Linked Data community.
* A recordspec schema which can be used directly or indirectly in toolchains for validation and API generation

From the recordspec schema we currently produce:

* SHACL files for RDF data validation.
* A modelspec schema to drive the API
* JSON schemas and JSON-LD context files for validating the RDF data as JSON-LD

The SHACL files are used in the fdri-discovery repo to ensure that the outputs of the RDF mappers conform to the model. Currently the validation is inspected manually at the time when the RDF mappers are updated. SHACL validation failures do not currently cause the data processing to fail.

The modelspec schema is used to drive the API in the dri-metadata-api repository. This file is currently manually generated and copied into the repository.

The JSON schemas and JSON-LD context files are currently only used to validate some hand-crafted sample data files in the fdri-discovery repo. These artefacts could probably be removed with little to no impact.

## Proposal

The following pre-requisite steps should be completed:

1. Move the model to a separate repository (https://github.com/NERC-CEH/fdri-discovery/issues/160)
2. Update the processes for release of a model version
   1. Ensure a changelog of model updates is maintained, in particular noting breaking changes to the model which may affect its use by dependent projects.
   2. Generate a release package in GitHub when the repository is tagged with a release version tag. The release package should contain the source OWL and recordspec files as well as the generated SHACL, JSON Schemas, JSON-LD contexts, and modelspec files.
   3. Update processes in downstream repositories to make use of a release artefact or to include the model repository as a git submodule (at the discretion of the repository owner). Submodules should be pinned to a commit that has been tagged as a release in the model repository.

TBD: Downstream steps. This will require input from downstream repo owners, and maybe form part of their dependency update runbook.