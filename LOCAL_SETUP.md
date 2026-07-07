# Running the Metadata Service Locally

This guide explains how to stand up the full FDRI metadata stack on your own machine: generate the RDF (`.ttl`)
sample data, load it into a triplestore, and serve it through the metadata API.

## Architecture

The data flows through four stages:

1. **Source data** - raw CSV / JSON / CDL files in `sample_data/`.
2. **TTL generation** - The `make` command converts the source data into Turtle RDF files in `build/data/`, using
   the `record-spec-tools` Docker image plus the `mapper` / `gridded-mapper` tools.
3. **Triplestore** - `docker compose up` starts Apache Jena Fuseki on `:3030`, and a loader (`publish-local.sh`)
   publishes the TTL files into it.
4. **API** - the `dri-metadata-api` Spring Boot app runs on `:8080` and answers queries against Fuseki.

## Prerequisites

* **Docker** + **Docker Compose v2** (`docker compose version` ≥ 2.x).
* **The mapper tools** (`mapper`, `gridded-mapper`) on your `PATH` - only needed to *generate* the TTL files. They come
  from the **`dri-gridded-mapper`** repo (a
  `uv`-managed Python project, requires Python ≥ 3.12):

  ```sh
  git clone https://github.com/NERC-CEH/dri-gridded-mapper.git
  cd dri-gridded-mapper
  uv sync                      # creates .venv with `mapper` + `gridded-mapper`
  source .venv/bin/activate    # put them on PATH for the make run
  ```

  (Everything else the `make` build needs - `duckdb`, `jq`, `record-spec-cmd`, `riot`, `shacl` - runs inside a Docker
  image automatically, so you don't install
  those yourself.)

## Repository layout

The compose file expects the API repo to be cloned **next to** this one:

```
source/repos/fdri/
├── fdri-discovery/      ← this repo (TTL generation + docker-compose.yml)
├── dri-metadata-api/    ← the Spring Boot API   (git clone alongside)
└── dri-gridded-mapper/  ← provides `mapper` + `gridded-mapper`
```

```sh
cd source/repos/fdri  # or wherever your repositories are
git clone https://github.com/NERC-CEH/dri-metadata-api.git
```

> The `api` service mounts `../dri-metadata-api:/workspace`, so the path location relative to fdri-discovery matters!

## Step 1 - Generate the TTL files

From the `fdri-discovery` repo root, with the mapper venv active:

```sh
make all
```

This writes `.ttl` files into `build/data/` and runs some validation.

> This can take up to 20 minutes if building from scratch!

### Pointing at a real environment's source buckets (optional)

By default the generated data uses placeholder S3 bucket names (`fdri-dummy-ingested` / `fdri-dummy-processed`) in the
`sourceBucket` field. This is baked into the TTL at generation time — the API does **not** rewrite it.

The Makefile picks the bucket names from `branch.map` keyed on the `GITHUB_REF_NAME` environment variable (this is how
CI builds the data for each deployment). To generate data with the real `staging` (or `production`) bucket names, 
set that variable when running `make`:

```sh
GITHUB_REF_NAME=staging make all
```

For `staging` this produces `ukceh-dri-staging-ingested` / `ukceh-dri-staging-processed`; `production` gives the
`ukceh-dri-production-*` names. Anything not listed in `branch.map` falls back to the `fdri-dummy-*` placeholders.

## Step 2 - Get latest dri-metadata-api changes (optional)

In case of updates to the dri-metadata-api repository, navigate to your clone and do a fresh pull:

```sh
cd source/repos/fdri/dri-metadata-api  # or wherever your repository is
git pull
```


## Step 3 - Run the docker compose to set up local metadata API

From the `fdri-discovery` repo root:

```sh
docker compose up -d
```

This starts, in order:

1. **`fuseki`** - Apache Jena Fuseki triplestore (`secoresearch/fuseki`) on `:3030`, with write operations enabled.
2. **`loader`** - a one-shot container that runs `publish-local.sh` against the Fuseki container, dropping any existing
   data and publishing every
   `build/data/*.ttl` file (plus the ontology and dependency rules). It exits when done.

> This can take up to 5-10 minutes

3. **`api`** - the metadata API (`maven spring-boot:run` against the `dri-metadata-api` source) on `:8080`, started once
   the loader succeeds.

The first run is slow because Maven downloads the dependency tree (cached in `~/.m2` for subsequent runs).

> **Important:** the loader does a `DROP ALL` first, so re-running it always gives you a clean reload of whatever is
> currently in `build/data/`.

## Verifying it works

```sh
# Triplestore has data (named-graph triple count):
curl -s -G http://localhost:3030/ds/sparql \
  --data-urlencode 'query=SELECT (COUNT(*) AS ?n) WHERE { GRAPH ?g { ?s ?p ?o } }' \
  -H 'Accept: text/csv'

# API serves it:
curl -s 'http://localhost:8080/id/dataset?_limit=3' -H 'Accept: application/json'
```

## Useful URLs

| URL                                        | What                              |
|--------------------------------------------|-----------------------------------|
| http://localhost:8080/                     | API web UI / HTML browser         |
| http://localhost:8080/id/dataset?_limit=10 | Example list endpoint (JSON/HTML) |
| http://localhost:3030/                     | Fuseki admin UI                   |
| http://localhost:3030/ds/sparql            | Raw SPARQL query endpoint         |

## Common docker operations

```sh
# Run in the background
docker compose up -d

# Tail logs
docker compose logs -f api
docker compose logs -f fuseki

# Reload data after regenerating TTL files (make samples), without a full restart
docker compose up loader

# Stop everything
docker compose down

# Full reset - REQUIRED if you change Fuseki's read/write settings
docker compose down -v
```
