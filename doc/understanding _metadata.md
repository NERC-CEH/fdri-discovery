This document details what is contained in the various files inside this repository, the formatting of the files' contents, and how the files are interconnected to build the data dependency graph and metadata.

In particular, this document shows how files should be updated to deal with a new method/parameter/argument etc required in the metadata, and how these files are linked to the dri-timeseries-processor. 

**Note:** As this repository is a work in progress, there may be some inconsistencies in e.g. naming conventions. 

# `COSMOS_TS_ID_DEPENDENCIES.json`
A JSON file where each dataset is listed as a top level key, together with their dependencies (other datasets that they depend on), and the processing step required to obtain that dataset from it's dependencies. 

The names of the datasets (keys) are formatted as follows:

`"{network}-{site}-{variable}-{resolution}-{status}"`

```bash
Example:

`"COSMOS-ALIC1-ALBEDO-30MIN-PROCESSED"`

```

The dataset names (keys) can be formed from the following options:
- network: `COSMOS`, `FDRI`, `AMS`, `NMDB`, `NRFA`, `EA`, etc.
- site: site from the given network. See `SITES.csv` for a list of 51 COSMOS sites, and similarly `NMDB_SITES.csv`, `NRFA_SITES.csv`, `fdri_sites.csv`, `AMS_sites.csv`, etc.
- variable: e.g. `G1`, `G2`, `G`, `SWIN`, `SWOUT`, `LWIN`, `LWOUT`, `PA`, `PE`, `WS`, `WD`, etc.
- resolution: `30MIN`, `1HOUR`, `1DAY`
- status: `RAW`, `PROCESSED`


The value for each dataset key is a nested dictionary. At the top level, keys and values of this nested dictionary are:

- key: `"depends_on"`, value: a list of datasets that dataset depends on. 
- key: `"derivation"`, value: one of `"PROCESS"`, `"CALCULATE"` or `"AGGREGATE"`, denoting the type derivation required to obtain the dataset from its dependencies. 

If the derivation is `"PROCESS"` then there are no further items in the nested dictionary. If the derivation is `"CALCULATE"` or `"AGGREGATE"`, the nested dictionary will have the additional key and value pair:

- key: method, value: the name of a specific method, either a derivation method or aggregation method as seen in the time-series processor repository. The value of this key value pair should match exactly the `name` specified by the given class in the time-series repository where the intended method is implemented.

**Note:** The `"derivation"` key and derivation methods of the time-series processor repository are not the same entities and should not be confused. They are purely naming conventions that mean different things in their respective repositories.

Depending on the method, there may be an additional key: args. The values will depend on the specifics of the method and may include further nested dictionaries.

```bash
Example:

    `"COSMOS-MOORH-PE_30MIN_RAW": {
        "depends_on": [
            "COSMOS-MOORH-RN_30MIN_PROCESSED",
            "COSMOS-MOORH-G_30MIN_PROCESSED",
            "COSMOS-MOORH-TA_30MIN_PROCESSED",
            "COSMOS-MOORH-RH_30MIN_PROCESSED",
            "COSMOS-MOORH-WS_30MIN_PROCESSED",
            "COSMOS-MOORH-PA_30MIN_PROCESSED"
        ],
        "derivation": "CALCULATE",
        "method": "calculate_PE",
        "args": {
            "round": 5,
            "wind_height": {
                "platform": "cosmos-moorh-aws_anem",
                "attribute": "deployedHeight",
                "source": "deployment"
            }
        }
    }`
```

## `PROCESS`
When a `PROCESS` derivation is invoked, the metadata model performs a search over three processes in this order:

### 1 Correction

At the correction stage of the `PROCESS`, the following files are searched:

- `CORRECTION_CONFIGS.json`
- `CORRECTION_METHODS.csv`
- `CORRECTION_PARAMS.csv`
- `CORRECTION_METHOD_PARAMS.csv`

#### `CORRECTION_CONFIGS.json`

This JSON file provides a list of dictionaries, where each dictionary specifies the dataset that the correction is to be applied to, which specific correction method to use and any corresponding parameters required by that method.

The top level key-value pairs in each dictionary are:

- `"CORRECT_TS"`: The name of the dataset to be processed. The dataset name is formatted in the same was as the top level keys in `COSMOS_TS_ID_DEPENDENCIES.json` and should match exactly the dataset name in that file that has a `PROCESS` derivation if a correction is required.
- `"DESCRIPTION"`: Plain text description of the correction required.
- `"OBS_START_DATE"`: The start date of observations made to create the dataset 
- `"OBS_END_DATE"` (optional): The end date of observations made for that dataset. If the end date is not given the observations are ongoing. 
- `"USE_START_DATE"`: 
- `"METHOD_ID"`: The specific method that should be applied to correct the data. This method is implemented in `dri-timeseries-processor` repository in `correct_methods.py`
- `"parameters"`: A list of dictionaries, one for each parameter required as input to the method. Each dictionary has two key-value pairs:
    - `"PARAM_ID"`: Name of the parameter
    - `"PARAM_VALUE"`: The value the parameter should take for the specific correction to the specific dataset. 

```bash
Example:

 `{
        "CORRECT_TS": "COSMOS-FINCH-WD_30MIN_RAW",
        "DESCRIPTION": "Wind direction orientation calculated incorrectly in program",
        "OBS_START_DATETIME": "2017-06-07 11:30:00",
        "USE_START_DATETIME": "2013-01-01 00:30:00",
        "METHOD_ID": "WD",
        "parameters": [
            {
                "PARAM_ID": "DEP_TS",
                "PARAM_VALUE": "COSMOS-FINCH-UX_30MIN_PROCESSED"
            },
            {
                "PARAM_ID": "DEP_TS",
                "PARAM_VALUE": "COSMOS-FINCH-UY_30MIN_PROCESSED"
            }
        ]
    }`
```

#### `CORRECTION_METHODS.csv`
A csv file that lists all of the correction methods.

#### `CORRECTION_PARAMS.csv`
A csv file that lists all of the correction parameters.

#### `CORRECTION_METHOD_PARAMS.csv`
A csv file that lists all of the correction methods and their corresponding parameters.

### 2 Quality Control (QC)

At the quality control stage of the `PROCESS`, the following files are searched:

- `QC_CONFIGS.json`
- `METHODS.csv`
- `PARAMS.csv`
- `METHOD_PARAMS.csv`
- `QC_FLAG_CODES.csv`

These work similarly to those files used for the correction stage. The additional file `QC_FLAG_CODES.csv` manages the flagging mechanism, where flags are added to the data if the dataset does not meet the QC tests.

### 3 Infilling
TODO

## `CALCULATE`

When the `"derivation"` value for a given dataset in "COSMOS_TS_ID_DEPENDENCIES" is `"CALCULATE"` or `"AGGREGATE"`, a `"method"` is also specified, along with any required arguments, `"args"`.

The methods specified are not implemented in this repository, but rather in the dri-timeseries-processor repository. The value of the `"method"` key should match exactly the CLI `name` provided in class methods inside the dri-timeseries-repository, though is agnostic of lower/upper case.

For `"CALCULATE"`, the dri-timeseries-processor looks for the specified method inside `src/dritimeseriesrepository/operations/derivations/derivation_methods.py`.

For `"AGGREGATE"`, the dri-timeseries-processor looks for the specified method inside `src/dritimeseriesrepository/operations/aggregation/aggregation_methods.py`.

**Note:** Recall that `"derivation"` in this repository does not have the same meaning as in the dri-timeseries-processor repository. A derivation of `"CALCULATE"` here corresponds to a 'derivation method' in the dri-timeseries-processor.

Depending on the method specified, the `"args"` are specified by yet another nested dictionary. Common keys are:

- `"round"`: The number of decimal places the quantity being calculated should be rounded to. Recall the quantity being calculated is specified by the dataset name from the top level keys in `COSMOS_TS_ID_DEPENDENCIES.json`. For example, if the dataset is: `"COSMOS-FINCH-WD_30MIN_RAW"`, then the wind direction (WD) should be rounded to the number of decimal places specified in `"round"`
- `"threshold"` (for `"AGGREGATE"` only): The minimum number of data points that can be used to obtain an accurate aggregation. For example, when taking a daily average of a quantity, there should be enough data points for the daily average to be accurate. If there are only 20 non null datapoints, and they are all from the beginning of the day, if the threshold is 40, taking a daily average using the reduced dataset will bias the result.


## QC Tests