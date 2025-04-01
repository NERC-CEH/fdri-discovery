  ## Sensor / System Model

This area of the model is concerned with defining sensor packages, models of sensor used and related procedures as well as the relationship to deployed instances of specific packages/sensors.

```mermaid
classDiagram
  class Sensor["fdri:EnvironmentalMonitoringSensor"]
  class EMSystem["fdri:EnvironmentalMonitoringSystem"] {
    fdri:serialNumber: string
  }
  class SystemType["fdri:EnvironmentalMonitoringSystemType"]
  class ObservableProperty["sosa:ObservableProperty"]
  
  EMSystem --> SystemType: dct_type
  SystemType --> ObservableProperty: sosa_observes
  EMSystem --> ObservableProperty: sosa_observes
  EMSystem --> EMSystem: ssn_hasSubsystem
  Sensor --|> EMSystem
```


`EnvironmentalMonitoringSystemType` is intended to be used to capture specific pre-defined packages of sensors or sub-systems. e.g. `FDRI Weather Station Sensor Package`, `FRDI Precipitation Station Sensor Package`, as well as specific models of Sensor e.g. `TFA 30-3121 Temperature Sensor`. The `dct:hasPart` relation is used to construct part-whole relations between a system/package and its components. Although not shown in this diagram, `fdri:EnvironmentalMonitoringSystemType` is defined as a subclass of `skos:Concept`.


`fdri:EnvironmentalMonitoringSensor` is intended to capture a specific physical instance of some type of sensor. It is defined to extend `sosa:Sensor`. 

`fdri:EnvironmentalMonitoringSystem` is intended to capture packages of multiple sensors. 

The `dct:type` relation relates a `fdri:EnvironmentalMonitoringSensor` or `fdri:EnvironmentalMonitoringSystem` to the `fdri:EnvironmentalMonitoringSystemType` that represents the package build or sensor model.

An `fdri:EnvironmentalMonitoringSystemType` represents a model of sensor, or a package of specific models of sensor. It can be related to the observable property/ies it provides measurements for using the `sosa:observes` property.

### Sensor / System Procedures

```mermaid
classDiagram
  class SystemType["fdri:EnvironmentalMonitoringSystemType"]
  class ProcedureType["fdri:ProcedureType"]
  class Procedure["fdri:Procedure"] {
    fdri:procedurePeriodicity: xsd:duration
  }
  class Resource["dcat:Resource"]
  class Concept["skos:Concept"]
  class Plan["prov:Plan"]
  
  Plan <|-- Procedure
  Resource <|-- Procedure
  Procedure <-- SystemType : fdri_hasProcedure
  Procedure --> ProcedureType: dct_type
  ProcedureType --|> Concept
  SystemType --|> Concept
```

`fdri:ProcedureType` is intended to capture categories of procedure, e.g. `Installation Procedure`, `Calibration Procedure` etc. The class `fdri:Procedure` is used to represent the procedure that applies to a specific system. `fdri:Procedure` is defined as a subclass of `prov:Plan`, enabling it to be used in relation to `prov:Activity` instances that represent the installation or calibration of a sensor or pacage of sensors. The class is also defined as a subclass of `dcat:CatalogResource` allowing all procedures to be recorded in a procedures catalog,  The property `procedurePeriodicity` may be used to capture the recommended/required period between applications of the procedure to a given sensor.


### Sensor / System Faults

A record of a system fault relates the affected `EnvironmentalMonitoringFacility` to one or more parameters which are affected by the fault. 

A fault is a time-bounded event and so has a related interval with start and end date/date-times. The range of `dcat:startDate` and `dcat:endDate` is specified in DCAT as one of the following XSD datatypes `xsd:gYear`, `xsd:gYearMonth`, `xsd:date`, or `xsd:dateTime` .

The fault is understood as affecting all observations of the specified `Variable` made by the system during the specified interval. Multiple `Variable` instances may be specified on a single fault.

The `removeData` flag is set to true to indicate that affected observations should be removed from the data.

```mermaid
classDiagram
  class EMF["fdri:EnvironmentalMonitoringFacility"]
  class COP["iop:Variable"]
  class Fault["fdri:Fault"]
  class Fault {
    fdri:removeData: xsd:boolean
    rdfs:comment: xsd:string
  }
  class Period["dct:PeriodOfTime"]
  class Period {
    dcat:startDate: rdfs:Literal
    dcat:endDate: rdfs:Literal
  }
  Fault --> EMF: fdri_affectedFacility
  Fault --> COP: fdri_affectedVariable
  Fault --> Period: fdri_interval
```

### Sensor Configuration

Each configuration property of a sensor is represented as a collection of time-bounded property values. 

The `dct:type` property is used to relate a `ConfigurationValueSeries` to a `skos:Concept` that speficies the configured sensor property. This approach uses a taxonomy of configuration properties to capture the different ways in which a sensor could be configured which may provide greater flexibility in adapting the model to new sensor types with novel configuration properties than an approach based on using semantic relationships defined in the domain model.

The `fdri:hasValue` property relates the `ConfigurationValueSeries` to a collection of `TimeBoundValueProperty` instances representing the different values of the configured property through time (excluding the current value).

The `fdri:hasCurrentValue` property relates the `fdri:ConfigurationValueSeries` to the `fdri:TimeBoundPropertyValue` that represents the configuration value that currently applies to the sensor.

On each `fdri:TimeBoundPropertyValue`, the `fdri:interval` property specifies the period over which the configuration applies and the `fdri:value` property specifies the configuration value applied. By inheriting `fdri:TimeBoundPropertyValue` from `schema:PropertyValues` we can support single values, value ranges and references to other resources as the value of a configuration.

An ordering of `fdri:TimeBoundPropertyValue` instances could additionally be modelled using the `dct:replaces` relationship with each value referencing its immediate predecssor.

> **NOTE**
> The preceding is based on the assumption that there is a need for the metadata store to retain historical configuration information. If there are no motivating use cases for this then the structure could be significantly simplified.
 
```mermaid
classDiagram
  class EMSystem["fdri:EnvironmentalMonitoringSystem"]
  class Configuration["fdri:TimeBoundPropertyValue"]
  class ConfigurationValueSeries["fdri:ConfigurationValueSeries"]
  class PeriodOfTime["dct:PeriodOfTime"] {
    dcat:startDate: xsd:date/xsd:dateTime
    dcat:endDate: xsd:date/xsd:dateTime
  }
  class ConfigurationProperty["fdri:ConfigurationProperty"]
  class Concept["skos:Concept"]
  class PropertyValue["schema:PropertyValue"] {
    schema:minValue: rdfs:Literal
    schema:maxValue: rdfs:Literal
    schema:value: rdfs:Literal
    schema:valueReference: rdf:Resource
  }

  EMSystem --> ConfigurationValueSeries: fdri_configuration
  ConfigurationValueSeries --> Configuration: fdri_hadValue
  ConfigurationValueSeries --> Configuration: fdri_hasCurrentValue
  ConfigurationValueSeries --> ConfigurationProperty: dct_type
  ConfigurationProperty --|> Concept
  Configuration --|> PropertyValue
  Configuration --> Configuration: dct_replaces
  Configuration --> PeriodOfTime: fdri_interval
```

> **TODO**
> If we decide that the different time-bound property series of an `EnvironmentalMonitoringSite` can be captured in a soft-typed property value type, then reuse that type here rather than introduce `ConfigurationValue`

The diagram below shows how this structure can be used to capture the
use of a specific version of firmware on a sensor with the firmware version identified by use of a URI

```mermaid
flowchart
  Sensor123 --fdri:configuration--> FIS
  FIS("Firmware Installation Configuration Series") --dct:type--> FirmwareInstallation
  FIS --fdri:hadValue--> F1
  FIS --fdri:hadValue--> F2
  FIS --fdri:hasCurrentValue--> F1
  F1("Latest Value") --schema:valueReference--> http:/fdri.ceh.ac.uk/id/firmware-version/some-model/v2
  F1 --fdri:interval --> int1("`dcat:startDate:...`")
  F2 --schema:valueReference--> http:/fdri.ceh.ac.uk/id/firmware-version/some-model/v1
  F2("Previous Value") --fdri:interval --> int2("`dcat:startDate:...
  dcat:endDate:...`")
  F1 --dct:replaces--> F2
```

The same configuration value could also be captured as a string value if there is no registry of firmware versions that an identifier could resolve to:

```mermaid
flowchart
    Sensor123 --fdri:configuration--> FIS
  FIS("Firmware Installation Configuration Series") --dct:type--> FirmwareInstallation
  FIS --fdri:hadValue--> F1
  FIS --fdri:hadValue--> F2
  FIS --fdri:hasCurrentValue--> F1
  F1("`Latest Value
  schema:value 'v1'`") --fdri:interval --> int1("`dcat:startDate:...`")
  F2("`Previous Value
  schema:value 'v2'`") --fdri:interval --> int2("`dcat:startDate:...
  dcat:endDate:...`")
  F1 --dct:replaces--> F2
```


### Sensor Metadata

Metadata relating to a physical instance of a sensor can be modelled as properties of the `fdri:EnvironmentalMonitoringSensor` instance.


```mermaid
classDiagram
  class System["fdri:EnvironmentalMonitoringSensor"]
  class System {
    rdfs:label: rdf:LangString
    dct:description: rdf:LangString
    fdri:serialNumber: xsd:string
    fdri:assetNumber: xsd:string
    fdri:dateOfPurchase: xsd:date
    fdri:dateOfDisposal: xsd:date
    fdri:storageLocation: xsd:string
    fdri:certification: rdf:Resource
    fdri:serviceContactDetails: vcard:Kind
    rdfs:comment: rdf:LangString
  }
  class SensorStatus["fdri:SensorStatus"]
  class Concept["skos:Concept"]
  System --> SensorStatus : fdri_status
  SensorStatus --|> Concept
```

> **QUESTION**
> Should any/all of this metadata appear on `EnvironmentalMonitoringSystem` ?

> **QUESTION**
> Would we prefer the flexibility of soft-typed property values here rather than modelling a set of direct properties?

> **QUESTION**
> Should any of these properties be captured as value series to track historical changes?

### Sensor Deployment

Deployment history can be constructed from the SOSA model, by following `ssn:deployedSystem` back from the System to the Deployment(s) the system had. Such a traversal may also follow `ssn:hasSubsystem` relations to include deployments in which the system in question was one part of a larger package.

### Sensor Maintenance Activities

Interventions made on a sensor, such as callibration or repair can be modelled as PROV-O activities which can also be used to capture information such as the individual or organisation undertaking the procedure.

```mermaid
flowchart
  activity["`prov:Activity
  Callibration of sensor #1234 on 2024-02-08`"]
  sensor["`fdri:EMSensor
  Sensor #1234`"]
  agent["`foaf:Agent
  Bob Smith`"]
  callibration["`fdri:ActivityType
  Sensor Callibration`"]
  activity -- prov:startedAtTime --> x[2024-08-01T10:00:00Z]
  activity -- prov:endedAtTime --> y[2024-02-08T10:30:11Z]
  activity -- prov:used --> sensor
  activity -- prov:wasAssociatedWith --> agent
  activity -- dct:type --> callibration
```

> **NOTE**
> If there is more of a one to many relationship between recorded activities and the interventions on systems/sensors (e.g. a single site visit by an engineer results in the callibration of 6 sensors, the cleaning of 2 and the replacement of 2 others), then this might be better modelled using the full qualified version of PROV-O, possibly with a custom subclass of `prov:Activity` for maintenance

> **QUESTION**
> Replace prov:used with a more meaningful relationship such as `affected` or `appliedTo` to relate the activity to the system affected by the activity.

### Sensor Calibration Factors

In the FDRI model, a sensor calibration factor is modelled as a `InternalDataProcessingConfiguration` which applies to a combination of an `EnvironmentalMonitoringSensor` and one or more `Variable`s. When a sensor is calibrated, a new `ConfigurationItem` is added to the `InternalDataProcessingConfiguration` as the current configuration item and any previous value is retained using the `hadConfigurationItem` relationship.

The `prov:wasGeneratedBy` relation can also be applied to relate a calibration `ConfigurationItem` to the maintainance `Activity` that represents the sensor calibration.

An initial calibration performed by the manufacturer can also be recorded as an activity based on the information provided on the calibration certificate received.

```mermaid
flowchart
sensor["`fdri:EMSensor
Sensor #1234`"]
variable["`iop:Variable
SWIN`"]
type["`skos:Concept
Calibration Configuration`"]
calibconfig["`fdri:InternalDataProcessingConfiguration
Calibration configuration for sensor #1234`"]
subgraph "Initial Calibration"
  calib1["`prov:Activity
    Manufacturer's callibration of sensor #1234 on 2020-01-05`"]
  calibconfig1["`fdri:ConfigurationItem
  Calibration value from 2020-01-05`"]
  calib1interval["`dcterms:PeriodOfTime
  startDate: 2020-01-05T00:00:00Z
  endDate: 2024-08-01T12:30:00Z`"]
  calibconfig1 -- fdri:observationInterval --> calib1interval
  calibconfig1 -- fdri:argument --> calibarg1
  calibarg1["`fdri:ConfigurationArgument
  Correction Factor Argument #1`"]
  calibval1["`schema:PropertyValue
  schema:value 0.923`"]
  calibarg1 -- fdri:hasValue --> calibval1
end
subgraph "Field Recalibration"
calib2["`prov:Activity
  Field callibration of sensor #1234 on 2024-08-01`"]
  calibconfig2["`fdri:ConfigurationItem
  Calibration value from 2024-08-01`"]
  calib2interval["`dcterms:PeriodOfTime
  startDate: 2024-08-01T12:30:00Z`"]
  calibconfig2 -- fdri:observationInterval --> calib2interval
  calibarg2["`fdri:ConfigurationArgument
  Correction Factor Argument #2`"]
  calibconfig2 -- fdri:argument --> calibarg2
  calibval2["`schema:PropertyValue
  schema:value 0.935`"]
  calibarg2 -- fdri:hasValue --> calibval2
end
calibconfig -- fdri:hadConfigurationItem --> calibconfig1
calibconfig -- fdri:hasCurrentConfigurationItem --> calibconfig2
calibconfig -- fdri:appliesToSystem --> sensor
calibconfig -- fdri:appliesToVariable --> variable
calibconfig --> dcterms:type --> type
calib1 -- prov:used --> sensor
calib2 -- prov:used --> sensor
calibconfig1 -- prov:wasGeneratedBy --> calib1
calibconfig2 -- prov:wasGeneratedBy --> calib2
scalar["`fdri:DataProcessingMethod
Scalar correction`"]
calibconfig1 -- fdri:method --> scalar
calibconfig2 -- fdri:method --> scalar
```
