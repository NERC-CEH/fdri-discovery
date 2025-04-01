# OGC SensorThings API Specification and FDRI Model

## Introduction

This section discusses how the FDRI model might be aligned with the data model proposed by the [OGC SensorThings API Part 1: Sensing Version 1.1](http://www.opengis.net/doc/is/sensorthings/1.1).

The SensorThings API specificiation is divided into two parts. Part 1 covers Sensing, Part 2 covers Tasking. The Sensing part is intended to address managing and retrieving observations and metadata from heterogeneous IoT sensor systems, and so is the part which FDRI might most simply align. In the following discussion, a reference to "SensorThings" or the "SensorThings API" should be taken to refer specifically to the Sensing part of the SensorThings API specification. 

## Type Mappings

![Sensor Things Entity Types diagram](sensor-things-types.png)

The diagram above shows the 9 types of entity defined by SensorThings.

This proposal recommends the following mappings of FDRI classes to SensorThings entity types:

| SensorThings Entity   | FDRI Class  |
|-----------------------|-------------|
| Datastream            | TimeSeriesDataset |
| Sensor                | EnvironmentalMonitoringSystem |
| ObservedProperty      | Variable |
| Thing                 | EnvironmentalMonitoringFacility |
| Location              | EnvironmentalMonitoringFacility |
| Observation           | NOT MAPPED |
| FeatureOfInterest     | NOT MAPPED |
| ValueCode             | NOT MAPPED |

### Datastream

The SensorThings `Datastream` has a partial mapping to the FDRI `TimeSeriesDataset` class. The mapping is partial because the modelling of the SensorThings `Datastream` assumes that a `Datastream` is the result of observations from a single sensor, whereas the FDRI model makes no such assumption and the relation between an FDRI `TimeSeriesDataset` and the sensor (or sensors) which produced the observations contained in the dataset is indirect. Thus an accurate mapping will only be possible for `TimeSeriesDataset` instances which are restricted to observations of a single property of a single feature of interest made by a single sensor.

**Property Mappings**

name
: Maps to `dct:title` - SensorThings allows only a single value, FDRI allows multiple language tagged strings.

description
: Maps to `dct:description` -  SensorThings allows only a single value, FDRI allows multiple language tagged strings.

observationType
: There is no direct equivalent to this property in FDRI. A default of `OM_Observation` could be used, or an additional mapping property could be added to the FDRI `Variable` type to allow the value type to be specified using the same controlled vocabulary as SensorThings (O&M conceptual model)

unitOfMeasurement
: This is a structured value in SensorThings. The fields of the structure can be mapped to subproperties of an FDRI Variable as follows:
  * name - maps to the SKOS prefLabel of the unit of the FDRI Variable
  * symbol - maps to the unitName of the FDRI Variable
  * definition - maps to the IRI identifier of the FDRI Variable

observedArea
: This property can be mapped if either the dct:spatial property, or the sosa:hasFeatureOfInterest property of the FDRI TimeSeriesDataset has at least one boundary geometry. The SensorThings API uses GeoJSON as the format for the boundary information which may require some translation from the WKT format preferred in FDRI.

phenomenonTime
: This property does not have a direct mapping in the current FDRI model.

resultTime
: This property can be mapped to the dct:temporal property of the FDRI TimeSeriesDataset.

**Relationship Mappings**

sensor
: The SensorThings API makes an assumption that a Datastream contains results from only a single sensor. This is not a constraint in the FDRI model and so it may not be possible to accurately map sensor relations. Under the current FDRI model one must traverse the SPARQL property path `fdri:originatingFacility/^ssn:deployedOnPlatform/ssn:deployedSystem` from the FDRI TimeSeriesDataset and filter to include only those `fdri:EnvironmentalMonitoringSystem`s where the `sosa:observes` property is the Variable as is captured by the Datastream. In programme data such as COSMOS where a TimeSeriesDataset is site-specific and not sensor-specific, there may be multiple sensors that match this filter, the API mapping could choose to return only the currently deployed sensor in this case.

observedProperty
: This relation maps to the `sosa:observedProperty` property of the FDRI TimeSeriesDataset

observations
: This relationship has no mapping as the FDRI metadata service does not manage observation data or row-level metadata on observations.

thing
: In the SensorThings API this relation is to a Thing in an IOT network. In the FDRI model this could be considered to be the EnvironmentalMonitoringFacility from which the TimeSeriesDataset originates. If this interpretation holds, then this relationship maps to the property `fdri:originatingFacility` on the FDRI TimeSeriesDataset.

### Thing

In the SensorThings API the "Thing" is the physical element of the IOT infrastructure that holds one or more sensors. This maps to the FDRI concept of the EnvironmentalMonitoringFaciltiy and in particular to the sub-classes of EnvironmentalMonitoringSite and EnvironmentalMonitoringPlatform.

**Property Mappings**

name
: Maps to the `rdfs:label` property

description
: Maps to the `rdf:comment` property


**Relationship Mappings**

Location
: Maps to the geos:hasGeometry property. For a mobile facility there may be no meaningful value to record.

HistoricalLocation
: Under the interpretation of a Thing as an EnvironmentalMonitoringFacility there is currently no equivalent to this property. This property may be used when considering drone / UAV data.

Datastream
: Maps to those TimeSeriesDatasets with an `fdri:originatingFacility` of this facility or one of its parts. 

### Location

**Property Mappings**
name
: maps to the rdfs:label of the FDRI class that is mapped to the Thing that has this location

description
: maps to the rdf:comment of the FDRI class that is mapped to the Thing that has this location

encodingType
: to align with SensorThings, this should map to GeoJSON (application/geo+json)

location
: maps to the geos:hasGeometry/geos:asWKT property converted to a GeoJSON object. The FDRI data model provides a number of seperate propertes for encoding a geometry, representative point, bounding box etc. An implementation of the SensorThings API should define a consistent preference order for the use of these properties.

**Relationship Mappings**
things
: Maps back to the EnvironmentalMonitoringFacility instance that has this location.

### Sensor

Sensor maps to the FDRI EnvironmentalMonitoringSystem type (and its sub-class EnvironmentalMonitoringSensor). 

**NOTE** The SensorThings API requires that all sensors are associated with a detailed description in the form of a datasheet or SensorML metadata block. This is not a requirement in the FDRI model and so such mappings may only be partial if we are to stick to this requirement. Alternatively we could treat the FDRI EnvironmentalMonitoringSystem resources itself as the primary source of sensor metadata.

**Property Mapping**

name
: maps to the rdfs:label of the EnvironmentalMonitoringSystem

description
: maps to the rdf:comment of the EnvironmentalMonitoringSystem

encodingType
: FDRI

metadata
: The IRI of the EnvironmentalMonnitoringSystem resource

**Relationship Mapping**

Datastream
: The Datastreams mapped from the TimeSeriesDataset(s) with an fdri:originatingFacility which hosts a (current) deployment of this EnvironmentalMonitoringSystem

### ObservedProperty

ObservedProperty maps to Variable in the FDRI model.

**Property Mapping**

name
: maps to the skos:prefLabel of the Variable

description
: maps to the skos:scopNote of the Variable (if any), otherwise the skos:prefLabel of the Variable

definition
: the IRI of the Variable resource

**Relationship mapping**

Datastream
: The Datastreams mapped from those TimeSeriesDataset(s) with a sosa:observedProperty of this Variable.

### HistoricalLocation

This entity is not mapped to any FDRI class and is unused under the FDRI to SensorThibgs mapping

### Observation

This entity is not mapped to any FDRI class as the FDRI metadata store does not cover row-level observation metadata.
The mapping to Observation will need to be addressed in the workstream focussed on delivering metadata+data via an API. 


### FeatureOfInterest

This entity is only used in relation to the unmapped Observation class, however it is likely that in an implementation
that includes Observation entities, the FeatureOfInterest entities will be derived from the reference data in the FDRI metadata store.

FeatureOfInterest maps to the FDRI GeospatialFeatureOfInterest class.

**Property mapping**
name
: maps to the rdfs:label of the GeospatialFeatureOfInterest. The SensorThings API allows only a single string, so if multiple labels are present on the GeospatialFeatureOfInterest resource, one must be chosen.

description
: maps to the rdf:comment of the GeospatialFeatureOfInterest if present, otherwise the rdfs:label. Only a single string is allowed so if multiple values are present on the GeospatialFeatureOfInterest resource, one must be chosen.

encodingType
: Must map to GeoJSON

feature
: The geospatial boundary or representative point of the GeospatialFeatureOfInterest converted to GeoJSON. Several properties are provided in the FDRI data model each of which could be converted to a GeoJSON structure. An implementation should defined a consistent approach to the preference order in which those properties are used (which should be consistent with the approach used for mapping the Location entity)

**Relationship mapping**

Observations
: The observations for a feature of interest can be found be querying for all TimeSeriesDatasets that have the mapped GeospatialFeatureOfInterest as their feature of interest and providing access to the observations from those datasets.

### ValueCode

This entity is used primarily to represent the value of classification observations in the SensorThings API model. As the FDRI mapping does not include observation data, there is no need to map ValueCode. However, in principal the obvious type mapping in the model is to `skos:Concept`.

## Extension Properties

All of the entity types defined in SensorThings have a property named `properties`. The value of this property is defined as "A JSON Object containing user-annotated properties as key-value pairs.". This provides an extension point where FDRI-specific properties could be included in the SensorThings API. The requirements for these properties will depend on the particular use cases for a SensorThings API over FDRI data, in the absence of specific use cases, it is recommended that the `properties` object should contain a JSON-LD representation of the FDRI resource that is mapped to the SensorThings entity. The Location entity might be treated as a special case where only the IRI identifier and geolocation properties of the FDRI resource are included in the properties.

## Implications for the FDRI model

### Introduce resource identifiers

In the SensorThings API, each resource requires an ID property which is used to retrieve the resource from the collection that it is in. This ID property could simply be the IRI of the mapped resource but this would require escaping when used in the URIs of the SensorThings API and would make for longer, potentially less readable SensorThings API paths.

To address this issue, the FDRI data model could be extended to allow a property such as the Dublin Core `dct:identifier` or the SKOS `skos:notation` property to provide a unique identifier string for each resource which could either be derived from the IRI identifier (e.g. by slicing off the common leading part of the IRI identifier, or by hashing the IRI identifier) or could be separately derived or generated (e.g. as UUIDs).

Alternatively if there are consistent templates for resource identifiers it may be possible to map FDRI resource IRIs into stub identifiers in a consistent manner that does not require any additiona property to store them.

### Consider adding a Location resource type

Consider making a resource type equivalent to the SensorThings Location entity type. This would involve moving the properties `hasGeometry`, `hasBoundingBox` etc. which are currently defined on classes such as `EnvironmentalMonitoringFacility` and `GeospatialFeatureOfInterest` into a separate class (possibly using the GeoSPARQL `geos:Feature` class), and then having a specific relation such as `fdri:hasLocation` to relate the facility or feature of interest to its location. 

**NOTE** The use of the `geo:Feature` class may be inappropriate for this purpose as its definition overlaps more strongly with the FDRI `GeospatialFeatureOfInterest` than it does with the SensorThings notion of `Location`.

### Consider how to ensure a name and descrption for all entities

In the current FDRI data model, a label is not mandatory, but in the SensorThings API the name property is mandatory for all entities. This issue may be addressed either by making an rfds:label, skos:prefLabel and/or dct:title mandatory on the relevant FDRI resource types or by defining an approach to generating labels for resources that do not have any of these properties.

The issue is the same for the description property in the SensorThings API, although if there is an approach to ensuring that a label is present for all SensorThings entities, the description property could simply repeat this for any entity that does not have an explicit description.