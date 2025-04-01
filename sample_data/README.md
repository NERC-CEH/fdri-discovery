# Fine-grained Metadata Store Samples

This directory contain sample schema and data files showing how resources might be represented in the fine-grained metadata store.


The Makefile contained in this directory can be used to build the schema files used to validate the sample data JSON files. The process uses a Docker image that runs some proprietary Epimorphics code.

The `schema` directory contains the schema definition for the Fine-grained Metadata Store. This definition reflects a subset of the full OWL ontology with a focus on ensuring that minimal metadata standards are adhered to and on minimizing the number of types of record that developers have to deal with.

The `id` directory is the root of the set of sample resources. Each sample record can be found in a separate JSON file. We have used JSON (actually JSON-LD) as a common format to bridge the gap from Linked Data to a more developer-friendly representation of the metadata.

To build the sample data, the [rdf-mapper](https://github.com/NERC-CEH/rdf-mapper) tool must be installed locally. The Makefile is
written to assume that the command to invoke the mapper tool is `mapper`, but this can be changed by overriding the `MAPPER` variable
when running `make`.