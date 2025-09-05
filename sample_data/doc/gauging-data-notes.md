* General points/questions
  * It would be good to ensure that all date/time values in the datasets are expressed in the same form. Ideally all times should be converted to UTC and always provided as a complete date/time and not with date and time in separate columns.
  * I'm not sure whether "flow" and "discharge" are the same concept or not, so for now I have modelled them as two separate variables.

* EA manual guaging:
  * Flow data for a site represented as a time series dataset.
* Flowstick surveys
  * Each survey is an activity
  * One dataset per survey
  * Sample data has only a single survey in it
  * Sensor and firmware record from metadata
* RCA sites
  * Date/times should be cleaned up and combined so that there is a start timestamp and an end timestamp with values in UTC. Note that there is some inconsistency in the source data in the provision of time values. For now I have done this cleanup in a pre-processing step based on the sample data, but there may be other bad values in the full source data. There is one remaining entry (RCA5 Bois Moor Road on 2023-03-28) where the time has been entered as a three-digit number that does not convert.
  * I have assumed that the impeller is effectively a sensor and that the number is a serial number and not a model number (a quick google revealed no results for it as a model number). Note that there are some inconsistencies in the impeller no column which for now I have not tried to correct.
* Sontek surveys
  * Appear to use the same site identifiers as RCA, but one has a space in the identifier. Is this a data issue?
  * To link the sontek survey to the RCA site, I had to extract the site identifier from the site name in the RCA data. It would be good to do this in the source data and to ensure that identifiers are consistently used across the sontek data and the rca data.
  * 
  