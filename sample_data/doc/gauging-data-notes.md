* EA manual guaging:
  * Flow data for a site represented as a time series dataset.
  * Created with an "invented" time series definition for EA - could fill in any processing configuration needed here for ingestion into FDRI
  * Defined a Variable and Measure for volumetric flow based on the EA flow variable name (FQ)
* Flowstick surveys
  * Each survey is an activity
  * One dataset per survey
  * Sample data has only a single survey in it
  * Sensor and firmware record from metadata
* RCA sites
  * Date/times should be cleaned up and combined so that there is a start timestamp and an end timestamp with values in UTC. Note that there is some inconsistency in the source data in the provision of time values. For now I have done this cleanup in a pre-processing step based on the sample data, but there may be other bad values in the full source data. There is one remaining entry (RCA5 Bois Moor Road on 2023-03-28) where the time has been entered as a three-digit number that does not convert.
  * I have assumed that the impeller is effectively a sensor and that the number is a serial number and not a model number (a quick google revealed no results for it as a model number). Note that there are some inconsistencies in the impeller no column which for now I have not tried to correct.