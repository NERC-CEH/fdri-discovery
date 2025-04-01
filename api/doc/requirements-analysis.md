# Combined API - mapping to project requirements

This note reviews the access use cases identified at the start of the project against options for the combined API design, particular an STA profile.

## Summary

| Use Case | STA-profile | Metadata+data API | Comments |
|----------|-------------|-------------------|----------|
| 2a. find observed properties relating to evaporation  | `/ObservedProperty?$filter=substringof('evaporation', tolower(properties/prefLabel))` | `/ref/common/cop/_concepts?search=evaporation` | Better to assume non-standard `$search` extension, part of OData but not STA |
| 2b. find sites which measure evaporation observed properties | `/Things?$filter=properties/observes/hasProperty/@id eq URI-for-evaporation-property'` | `/id/site?observes.hasProperty=URI-for-evaporation-property` | Assumes filter over properties in FDRI model, can avoid this if enumerate all the evaporation COPs |
| 2c. display sites on map UI | `/Things?$filter=Datastreams/ObservedProperty/id eq id-for-potential-evapotranspiration&$expand=Location` | Included in above | |
| 2d. identify the specific OPs for each site (potential- or actual-) | `/Thing({id})?$expand=Datastreams/ObservedProperty` or `/Thing({id})?$select=properties/observed` | `/id/site/{id}?_projection=observes` | Native STA returns multiple copies data due to indirection via Datastreams, can't aggregate. FDRI data model offers shortcut which is usable from STA |
| 2e. retrieve platform information including height | `/Thing({id})?$select=properties.hasPart` | `/id/platform?isPartOf={id}&observes={evaporation-cop}`  | Platform not in STA. Can retrieve FDRI metadata as `properties` field but can't be selective, whereas native metadataAPI can select just relevant platforms |
| 2f(i). retrieve details of _measurement_ and processing |  `/Datastreams({id})/Sensor` | `/id/{platform}/_deployments` | Assumes measurement process is metadata on sensor. Note that e.g. BGS treat put platform (logger) information in Sensor slot so would not work there. |
| 2f(ii). retrieve details of measurement and _processing_ | ?? | `/id/data-processing-configuration?appliesToTimeSeries={id}` | To expose in STA would need inverse of `appliesToTimeseries` so can include all configuration information in `properties` field of Datastream. Use case may be aimed at higher level summary description of processing rather than detailed config. |
| 2g. retrieve actual data for a site/set of sites for a time period | `/Datastreams(id-for-selected-stream)/Observations/phenomenonTime gt 2021-04-01T00:00:00+00:00 and phenomenonTime  lt2021-04-30T00:00:00+00:00` | `/id/dataset/id-for-series/readings?min-timestamp=2021-04-01T00:00:00&max-timestamp-2021-04-30T00:00` | Handling multiple sites would be a loop in STA, but possible in one call with API in the style of Hydrology service |

**1. As a hydrologist looking for data I would like FDRI monitoring data to appear within google searches, e.g. for “evaporation”, “rainfall data”, “river flow data”, etc.**

This would be handled by including json-ld (using dcat or schema.org terms) in the HTML pages for the overall FDRI dataset and individual site pages. That could be done for any API format and pattern.

**2. As a new end user of data from FDRI catchments, I want to be able to find out exactly what is measured and where so I can find data for my hydrological model. I would like to search an FDRI user interface to find out whether there is evaporation data in FDRI catchments. I would like to see on a map where evaporation is measured, and understand whether it is potential evaporation or actual evapotranspiration, understand the context of the measurement location (e.g. above grass or above the tree canopy) and then easily find information on the measurement and calculation methods, before downloading data in a simple format.**

Break this down into:
* 2a. find observed properties relating to evaporation
* 2b. find sites which measure evaporation observed properties
* 2c. display sites on map UI
* 2d. identify the specific OPs for each site (potential- or actual-)
* 2e. retrieve platform information including height
* 2f. retrieve details of measurement and processing
* 2g. retrieve actual data for a site/set of sites for a time period

**2a. find observed properties relating to evaporation**

In the FDRI model _Evaporation_ is likely to be a higher level concept in the observed property scheme, with specific measures such as _potential evaporation_ and _actual evapotranspiration_ as sub-terms with same property facet (presumably [EvaporativeHeatTransfer](https://qudt.org/vocab/quantitykind/EvaporativeHeatTransfer.html)). There may be further sub-terms with specific contexts such as grass or canopy level.

Note that in NVS at present only [potential evapotranspiration](https://vocab.nerc.ac.uk/collection/P01/current/POTEVAPT/) is represented and that is not in i-adopt format. There is nothing obvious in NVS units and properties vocabularies for evaporation. EnvThes is down and the time of writing and can't be checked.

Searching for relevant observed properties would ideally be via text search.OData has `$search` but SensorThings does not. Text search is supported by sapi-nt though not enabled on scheme/_concepts endpoint at the moment. 

Suggested approach for STA-profile is to add `$search` to the profile:

    /ObservedProperty?$search=evaporation

A fallback would be to include `substringof` and case normalization functions in the profile:

    /ObservedProperty?$filter=substringof('evaporation', tolower(properties/prefLabel))

String inclusion is good enough in this case but in general text search is likely to be needed.

Note that it would also be possible for a UI to download an cache the whole ObservedProperty scheme and present it as a searchable hierarchy, performing the search client side.

**2b. find sites which measure evaporation observed properties**

In STA ObservedProperty is an attribute of a Datastream and not directly linked to sites (`Thing`s).

It would be possible to list sites with a given ObservedProperty by starting from the property and navigating from there, through `Datastream` to `Thing`. However, STA does not support distinct or any equivalent. OData 4.0 does include a `$apply` directive for aggregation including `groupby` which is sufficient to emulate a `distinct` predicate. FROST has a custom extension to support `distinct` but this is not part of the standard and the extension only seems to be applicable to simple properties not to links.

So the only option is to list all sites and filter by the id the observed property

    /Things?$filter=Datastreams/ObservedProperty/id eq 'id-for-potential-evapotranspiration'

To see sites with any of the specific evaporation related properties would require them to be enumerated and combined as a disjunction:

    /Things?$filter=Datastreams/ObservedProperty/id eq 'id-for-actual-evapotranspiration' or id eq 'id-for-potential-evapotranspiration'...

Note that in the FDRI data model sites have a direct `observes` property so, assuming query of properties annotations then an alternative is:

    /Things?$filter=properties/observes/@id eq URI-for-potential-evapotranspiration'

This is more efficient since it avoids join through a potentially large number of Datastreams. It is aslo more powerful since we can then find all sites for all evaporation related observed properties in one go:

    /Things?$filter=properties/observes/hasProperty/@id eq URI-for-evaporation-property'

**2c. display sites on map UI**

To include mapping information in the return we need to expand the response to include the Location linked to the site:

    /Things?$filter=Datastreams/ObservedProperty/id eq 'id-for-potential-evapotranspiration'
            &$expand=Location

This makes for a quite large return. It should be possible to use `$select` to limit to just the elements of interest but at least on the BGS FROST server that doesn't work across expands.

**2d. identify the specific OPs for each site (potential- or actual-)**

Again using raw STA this is awkward. We can obtain all the relevant data:

    /Thing(id)?$expand=Datastreams/ObservedProperty

but this lists the details of all the Datastreams which duplicate the desired OP information. Trying to at least reduce the return to just include relevant information through `$select=Datastreams/ObservedProperty` fails, at least on the BGS FROSt server. The duplication can't removed due to the lack of an effective `distinct` or aggregation option.

However, given the FDRI data model then we can obtain what we need via the properties extensions:

    /Thing(id)?$select=properties/observed

Though the client would have to filter the returned OPs to find those related to evaporation.

**2e. retrieve platform information including height**

Assume there that platform height is an annotation on the platform which is part of the overall site.

If we following the mapping of Thing to site then the specific platforms at a site would be part of the `properties` field again and so can be retrieved but it would be up to the client to sort through the information. STA can't filter on returned properties since that is not a "list" style endpoint

In contrast in the existing metadata API we can be much more selective and list platforms for a specific site (or set of sites) and observe a specific property (or set of properties):

    /id/platform?isPartOf=http://fdri.ceh.ac.uk/id/site/xyz&observes=http://fdri.ceh.ac.uk/ref/common/cop/evaporation

**2f. retrieve details of measurement and processing**

The measurement method presumably would be metadata associated with the Sensor type. In STA the Sensor itself is associated with the Datastream. So:

    /Datastreams(id-for-selected-stream)/Sensor

The returned `properties` could include the type of the (abstract) sensor which could contain metadata for measurement process.

Note that BGS treat the Sensor as the platform not a sensor so this would return information on the site logger and not the actual instrument or measurement process. This discrepancy would need to be resolved before this could be standardised.

At present in the FDRI model processing configuration is linked to the TimeSeries via a property (`fdri:appliesToTimeseries`) so the configuration would not naturally be part of the `properties` of a Datastream. In principle, we could introduce an inverse property to link from the time series to the configuration history but that would mean including the (potentially very large) configuration history in returns that show Datastreams and we've already noted limitations on FROST in performing adequate projections.

The existing metadata API includes specific endpoints for configuration information.

**2g. retrieve actual data for a site/set of sites for a time period**

Straightforward for a single site. STA:

    /Datastreams(id-for-series)/Observations/phenomenonTime gt 2021-04-01T00:00:00+00:00 and phenomenonTime  lt2021-04-30T00:00:00+00:00

Natural extensions to metadata API:

    /id/dataset/id-for-series/readings?min-timestamp=2021-04-01T00:00:00&max-timestamp-2021-04-30T00:00:00

Retrieving data for

**1. As an FDRI field engineer, I want to find a specific time series at a site of interest and view QC metrics for the past week on a dashboard, so I can identify any issues at the site.**


2. As an FDRI data manager, I would like to quickly find the method used for derivation / QC / infilling of a variable, and find documentation and code for that method, so I can have clarity on how data is processed.

3. As an FDRI field engineer I would like to view a time series of a variable (possibly aggregated to e.g. daily values) alongside the calibration and deployment history of sensors measuring that variable, so I can identify any discontinuities in the record due to changes in sensor.

4. As a hydrologist aware of the FDRI network, I would like to see an overview of which sites across the network are measuring temperature, when the measurements started, and where there have been gaps in measurement.

5. As an end user I would like to see a list of FDRI sites (as a list and on a map) and key metadata so I can understand where monitoring is taking place.

6. I would like to look for data on days when there was snow (flood/heatwave) including 3 (or a different number) days before and after the event.

7. I would like to find river measurements (eg. ADCP) that are within 100 (or a different number) meters from a given gauging station up or down the river. I would also like to be able to restrict them by timestamp.

8.  I would like to search by ‘project ID’ to find a specific project easily – in case we have external counterparties using FDRI as an infrastructure for their measurements.

9.  I am only interested in searching through soil (river/weather/groundwater/WQ/land-surface exchange) measurements.

10. I only want to see daily (1 min/15 min) data.

11. Show me where a specific data format is available, like photos or radar.

12. I would like to search by station type, for example, show me all permanent river measurement stations.

13. I would like to search by different levels of data, for example, to see if quality-checked data is already available at a location and when it was updated last. This is so that I can develop my own infilling/QC methods and compare with the ones in the FDRI project.

14. I would like to be able to see ‘associated data’ (not sure how to create those links), for example, when I find a drone survey on a river, I would like to see the ‘nearby’ ADCP measurement. 

15. When I ask for rainfall data from FDRI, I would like to be able to also pull rainfall data from other available sources nearby in one dataset with the source of the data (with all other metadata, like instrument type) indicated.

16. As a user show me where we are measuring X and lots of derivatives of this....e.g.

17. Show me where we are measuring X in X catchment, near to X river or X gauging station etc etc

18. Show me which instruments are measuring X, now; or have in the past, date range

19. Show me which datasets contain information about X

20. Show me the full provenance information for the dataset

21. Search for all data available for specific soil type, land cover and/or vegetation type.

22. Show datasets where variable X is measured by different (types of / makes of) instruments.

23. When viewing a variable I want to easily see its units, measurement medium, and resolution.

24. I want to look at just daytime data (between timestamps X and Y) for multiple days/months/years.

25. I want to look at just growing season data (between datetimestamp x and Y) for multiple years.

26. I want to only see data from soil depth of X cm.

27. When viewing a variable I want to easily see anything special/unusual about the site where it was measured.

28. When viewing a variable I want to see any other instruments on which the variable was reliant on, and see its corresponding history of issues, calibrations, modifications, and movements.

29. When viewing a variable I want to see if the values have been capped at a certain max/min.

30. I want to see a history of land activity for any interested site, e.g. cattle movement, grass mowing, pesticide application, irrigation, tilling... and I want to know the source of this information (from PhenoCam photos, from a site host, from an engineer visit).

31. I want to see what an interested site looks like right now, and what it looked like at other notable points in time.

32. For a sensor/variable, I want to know when a deployment/data methodology is a known standard, e.g. provided a hyperlink to show why the sensor was installed at height X cm or why a processing method was used/proven.

33. I want to see whether a site/variable/sensor has a known future, e.g. if a site is likely to be moved/decommissioned, or a sensor discontinued.

34. For a variable at a site, I want to know if there is a ‘backup’ - and how many iterations of this variable are available and if the setups are the same.

35. If there are two sensors measuring the same variable at the same height/depth/condition, I want to know where they are located in relation to each other (and other instruments).




