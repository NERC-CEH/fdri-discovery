# Understanding the metadata

This document details what is contained in some of the files inside the `fdri-discovery` repository, the formatting of the files' contents, and how the files are interconnected, and subsequently used by the metadata model to build the data dependency graph and metadata API.

In particular, this document shows which files should be updated to handle a new dataset/method/parameter/argument etc, how to update them, and how their contents are processed by the `dri-timeseries-processor` repository. 

**Note:** This repository is a work in progress. There may be some inconsistencies in naming conventions. For example, mixing hyphens and underscores, interchange of capitalization and lower cases, etc. Furthermore, as COSMOS was implemented first, occasionally the network name is missing from the file name in the case of COSMOS, but is specified for other networks. Datasets for different networks are also at different levels of completeness.


## Registering datasets

- Each dataset from a given network must be registered inside `TIMESERIES_IDS_<NETWORK>.csv`.
- When registering a dataset in `TIMESERIES_IDS_<NETWORK>.csv`, the dataset name is added to the `TIMESERIES_ID` column. 
- Datasets of variables that are not measured, but that must be derived from other data, such as `ALBEDO` or `PE`, do not have a `SENSOR_SLOT_ID` and the entry to this column is left empty in `TIMESERIES_IDS_<NETWORK>.csv`. 
- For 'intermediate' datasets, whose data output we do not wish to store, but is required to calculate another dataset, such as the `SOLAR_ZENITH`, the `S3_BUCKET` and `S3_DATASET` entries are also left empty in `TIMESERIES_IDS_<NETWORK>.csv`.


## Dataset naming conventions

The names of the datasets, or `TIMESERIES_ID`, are formatted as follows:

```bash
"{network}-{site}-{variable}_{resolution}_{status}"
```

For example, in `TIMESERIES_IDS_COSMOS.json` we have:
```bash
"COSMOS-ALIC1-ALBEDO_30MIN_PROCESSED"
```

The dataset names/`TIMESERIES_ID` can be formed from the following options:

- **network**: `COSMOS`, `FDRI`, `AMS`, `NMDB`, `NRFA`, `EA`, etc.
- **site**: site from the given network. See `SITES.csv` for a list of 51 COSMOS sites, and similarly `NMDB_SITES.csv`, `NRFA_SITES.csv`, `fdri_sites.csv`, `AMS_sites.csv`, etc. The naming conventions for these files will be made consistent in due course.
- **variable**: e.g. `G1`, `G2`, `G`, `SWIN`, `SWOUT`, `LWIN`, `LWOUT`, `PA`, `PE`, `WS`, `WD`, etc.
- **resolution**: `30MIN`, `1HOUR`, `1DAY`
- **status**: `RAW`, `PROCESSED`

**Notes:** 
- Variables containing multiple words are separated by underscores.
- The mix of hyphens and underscores in the timeseries ids may be updated in due course.
- Naming conventions for the site `.csv` files will also be made consistent in due course.


## Dataset dependency configs

`<NETWORK>_TS_ID_DEPENDENCIES.json` are JSON files where each dataset that depends on another dataset is listed as a top level key, together with their dependencies, the `"derivation"` required to obtain that dataset from its dependencies, and any relevant arguments required by the `"derivation"`. The dataset names and the dependencies are the same format as those in the `TIMESERIES_IDS` column from `TIMESERIES_IDS_<NETWORK>.json`.

The values corresponding to the top-level dataset keys are nested dictionaries. The key-value pairs of these nested dictionaries are:
- `"depends_on"`: a list of dataset dependencies.
- `"derivation"`: one of `"PROCESS"`, `"CALCULATE"` or `"AGGREGATE"`, denoting the type derivation required to obtain the dataset from its dependencies. 

If the derivation is `"PROCESS"` then there are no further items in the nested dictionary. If the derivation is `"CALCULATE"` or `"AGGREGATE"`, the nested dictionary will have the additional key and value pair:

- `"method"`: the name of a specific method, either a derivation method or aggregation method, which is implemented in the `dri-timeseries-processor` repository. 

Depending on the method, there may be an additional key: `"args"`. The value of the `"args"` key is another nested dictionary. They key/value pairs inside this dictionary will depend on the specifics of the method and may include further nested dictionaries. Some of the key-value pairs found in the `"args"` nested dictionary include:

- `"round"`: The number of decimal places the quantity being calculated should be rounded to. Recall the quantity being calculated is specified by the dataset name from the top level keys in `<NETWORK>_TS_ID_DEPENDENCIES.json`. For example, if the dataset is: `"COSMOS-FINCH-WD_30MIN_RAW"`, then the wind direction (WD) should be rounded to the number of decimal places specified in `"round"`.
- `"threshold"` (for `"AGGREGATE"` only): The minimum number of data points that can be used to obtain an accurate aggregation. For example, when taking a daily average of a quantity, there should be enough data points for the daily average to be accurate. If there are only 20 non null datapoints, and they are all from the beginning of the day, if the threshold is 40, taking a daily average using the reduced dataset will bias the result.
- `"start_/end_date"`: a string that gets converted to a date time object in the `dri-timeseries-processor` repository. used for `"AGGREGATE"` methods where only certain times of the day should be aggregated, such as the albedo.
- `"annotation"`: value: a list of strings of site attributes. These are values specific to the site. For example, if one of the annotations is `"ALTITUDE"`, the metadata model finds the altitude value by looking at the `ALTITUDE` column in`<NETWORK>_SITES.csv`. Other annotations may point to other files, for example the numerical values for the annotation `"REF_C0"` is looked up in `SITE_CALLIBRATION_INFO.csv`. Annotations in `<NETWORK>_SITES.csv` and `SITE_CALLIBRATION_INFO.csv` must also be registered in `ANNOTATION_PROPERTIES.csv`.

```bash
Example:

    "COSMOS-ALIC1-ALBEDO_1DAY_PROCESSED": {
        "use_start_date": "2025-03-28T12:00:00Z",
        "depends_on": [
            "COSMOS-ALIC1-ALBEDO_30MIN_PROCESSED"
        ],
        "derivation": "AGGREGATE",
        "method": "mean",
        "args": {
            "round": 3,
            "start_time": "10:30:00",
            "end_time": "14:00:00",
            "threshold": 7
        }
    }
```

**Notes:** 
- Not every dataset inside `TIMESERIES_IDS_<NETWORK>.csv` will have a dataset dependency config. Datasets that are loaded from raw data and/or do not depend on any other datasets do not have a dependency config.
- The `"derivation"` key and derivation methods of the `dri-timeseries-processor` repository are not the same entities and should not be confused. They are purely naming conventions that mean different things in their respective repositories. Generally a `"derivation"` key with a value of `"CALCULATE"` in the `fdri-discovery` repository corresponds to a `derivation` method in the `dri-timeseries-processor` repository.


## `PROCESS`
When a `PROCESS` derivation is invoked, the metadata model performs a search over three possible 'processes' in this order: **correction**, **QC** and **infilling**.

### 1 Correction

At the correction stage of the `PROCESS`, the following files are searched:

- `CORRECTION_CONFIGS.json`
- `CORRECTION_METHODS.csv`
- `CORRECTION_PARAMS.csv`
- `CORRECTION_METHOD_PARAMS.csv`

These files are not specific to a given network, but are mostly only implemented for COSMOS thus far.

#### `CORRECTION_CONFIGS.json`

This JSON file provides a list of dictionaries, where each dictionary specifies the dataset that the correction is to be applied to, which correction method to use, and any parameters required by that method. 

For example, the dataset `COSMOS-ALIC1-PE_30MIN_PROCESSED` is obtained by applying the correction method `clip` to the raw data, `COSMOS-ALIC1-PE_30MIN_RAW`. The `clip` method is implemented in the `dri-timeseries-processor` repository. The dataset dependency config can be found in `COSMOS_TS_ID_DEPENDENCIES.json` and looks like: 

```bash
"COSMOS-ALIC1-PE_30MIN_PROCESSED": {
        "use_start_date": "2025-03-28T12:00:00Z",
        "depends_on": [
            "COSMOS-ALIC1-PE_30MIN_RAW"
        ],
        "derivation": "PROCESS"
    }
```
As the correction must be applied to the dependency, `COSMOS-ALIC1-PE_30MIN_RAW`, the correction config appears in `CORRECTION_CONFIGS.json` as:
```bash
{
        "CORRECT_TS": "COSMOS-ALIC1-PE_30MIN_RAW",
        "DESCRIPTION": "Clipped PE data: negative values set to zero",
        "OBS_START_DATETIME": "2013-01-01 00:30:00",
        "USE_START_DATETIME": "2013-01-01 00:30:00",
        "METHOD_ID": "CLIP",
        "parameters": [
            {
                "PARAM_ID": "MIN",
                "PARAM_VALUE": 0
            }
        ]
    }
```

The top level key-value pairs in each correction config dictionary are:

- `"CORRECT_TS"`: The name of the dataset to be processed. The dataset name is formatted in the same way as the top level keys in `<NETWORK>_TS_ID_DEPENDENCIES.json`. The dataset name should match the name of the dataset dependency in a given dataset dependency config in `<NETWORK>_TS_ID_DEPENDENCIES.json` that has a `PROCESS` derivation where a correction is required.
- `"DESCRIPTION"`: Plain text description of the correction required.
- `"OBS_START_DATE"`: The start date of observations of the dataset being corrected.
- `"OBS_END_DATE"` (optional): The end date of observations made for the dataset being corrected. If the end date is not given the observations are ongoing. 
- `"USE_START_DATE"`(optional): Specifies a different start date to use.
- `"METHOD_ID"`: The specific method that should be applied to correct the data. This method is implemented in `dri-timeseries-processor` repository in `correct_methods.py`
- `"parameters"`: A list of dictionaries, one for each parameter required as input to the correction method. Each dictionary has two key-value pairs:
    - `"PARAM_ID"`: Name of the parameter
    - `"PARAM_VALUE"`: The value the parameter should take for the specific correction to the specific dataset. 


Sometimes a correction method requires inputs from several different datasets, but the metadata model is currently set up so that there can only be one dataset dependency for a `PROCESS` derivation. That is, any dataset dependency configs in `<NETWORK>_TS_ID_DEPENDENCIES.json` that use `"derivation": "PROCESS"` can only have a single dependency. If additional dependencies are required for the `PROCESS` correction step, the additional dependencies are included as parameters in the correction config in `CORRECTION_CONFIGS.json`. For example:

```bash
 {
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
    }
```

#### `CORRECTION_METHODS.csv`
A csv file that lists all of the correction methods. Some methods can be used by all networks, whereas others are network specific. The `CATEGORY` column in the `CORRECTION_METHODS.csv` file indicates whether the method is network specific or generic using the entries: `<NETWORK> Specific` or `Generic`. 

Any correction method specified as a `"METHOD_ID"` in the `CORRECTION_CONFIGS.json` must be registered in `CORRECTION_METHODS.csv`

#### `CORRECTION_PARAMS.csv`
A csv file that lists all of the correction parameters.

Any correction parameter specified as a `"PARAM_ID"` in the `CORRECTION_CONFIGS.json` must be registered in `CORRECTION_PARAMS.csv`

#### `CORRECTION_METHOD_PARAMS.csv`
A csv file that lists all of the correction methods and their corresponding parameters, establishing a relationship between the methods and their parameters.

Any correction method specified as a `"METHOD_ID"` and parameter specified as a `"PARAM_ID"` in the `CORRECTION_CONFIGS.json` must be registered in `CORRECTION_METHODS_PARAMS.csv`

### 2 Quality Control (QC)

At the quality control stage of the `PROCESS`, the following files are searched:

- `QC_CONFIGS.json` (for COSMOS) and `<NETWORK>_QC_CONFIGS.json` for other networks.
- `METHODS.csv`
- `PARAMS.csv`
- `METHOD_PARAMS.csv`
- `QC_FLAG_CODES.csv`

These work similarly to those files used during the correction stage. The additional file `QC_FLAG_CODES.csv` manages the flagging mechanism, where flags are added to the data if the dataset does not meet the QC tests.

Recently some QC configs have been added to `FDRI_QC_CONFIGS.csv`, e.g. battery voltage: `"BATTV"`.

### 3 Infilling
ToDo

## `CALCULATE` and `AGGREGATE`

When the `"derivation"` value for a given dataset dependency config in `<NETWORK>_TS_ID_DEPENDENCIES.json` is `"CALCULATE"` or `"AGGREGATE"`, a `"method"` is also specified, along with any required arguments, `"args"`. The value of a `"method"` key in `<NETWORK>_TS_ID_DEPENDENCIES.json` should match (but is not case sensitive to) the CLI `name` provided in the classes inside either `aggregation_methods.py` or `derivation_methods.py` from the `dri-timeseries-processor` repository. 

- For `"CALCULATE"`, the `dri-timeseries-processor` looks for the specified method inside `src/dritimeseriesrepository/operations/derivations/derivation_methods.py`. Datasets that are obtained using `CALCULATE` must register their calculation method in `MEASURES.csv`, in additional to the units of measurement of the dataset. This may be `UNITLESS`. Units must also be registered in `UNITS.csv`.
- For `"AGGREGATE"`, the dri-timeseries-processor looks for the specified method inside `src/dritimeseriesrepository/operations/aggregation/aggregation_methods.py`.

For example, if the `"method"` is `"calc_albedo"`, this corresponds to a method in `derivation_methods.py` in the `dri-timeseries-processor` repository, and looks like:

![Albedo derivation method from the `dri-timeseries-processor` repository](example_method_timeseries_processor.png)


Most dataset dependency configs in `<NETWORK>_TS_ID_DEPENDENCIES.json` that use `CALCULATE` or `AGGREGATE` construct processed datasets from other processed datasets. Occasionally a raw dataset will be constructed from processed datasets, for example: 

```bash
"COSMOS-ALIC1-PE_30MIN_RAW": {
        "use_start_date": "2025-03-28T12:00:00Z",
        "depends_on": [
            "COSMOS-ALIC1-RN_30MIN_PROCESSED",
            "COSMOS-ALIC1-G_30MIN_PROCESSED",
            "COSMOS-ALIC1-TA_30MIN_PROCESSED",
            "COSMOS-ALIC1-RH_30MIN_PROCESSED",
            "COSMOS-ALIC1-WS_30MIN_PROCESSED",
            "COSMOS-ALIC1-PA_30MIN_PROCESSED"
        ],
        "derivation": "CALCULATE",
        "method": "calculate_PE",
        "args": {
            "round": 5,
            "wind_height": {
                "platform": "cosmos-alic-aws_anem",
                "attribute": "deployedHeight",
                "source": "deployment"
            }
        }
    }
```
The reason for this is because the PE data can only be obtained from a derivation, as it cannot be measured directly. Any raw data has been checked via `PROCESS`, and only the processed data that has been corrected and passed QC/infill checks is used in derivations. The PE data must also be corrected however, so while the `PE_30MIN_RAW` does not come directly from raw measurements, it is labelled as raw to distinguish from being processed at a later stage.


## The metadata model

The model is implemented in the `templates` folder using `.yaml` files. These determine how the files inside `src` should be read and how the metadata API should be formatted.

**ToDo**: We are currently in the process of handing over from Epimorphics so the we have more autonomy, control, and understanding of how the model works. 


## Useful scripts for quickly updating the metadata

Scripts are available in the [Codeberg repo](https://codeberg.org/CEH-HOTDOG/a_complete_list_of_things_that_are_useful/src/branch/main/metadata_config_tools) to quickly add e.g. new dataset dependency configs to the `<NETWORK>_TS_ID_DEPENDENCIES.json`, avoiding having to copy and paste the same data for every site in the network.

Each script modifies a specific metadata configuration file, but can easily be adapted to work with different config files by replacing the templates and file paths within these scripts.
