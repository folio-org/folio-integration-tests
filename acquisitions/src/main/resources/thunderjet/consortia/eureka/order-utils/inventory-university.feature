Feature: global inventory

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json' }
    * callonce variablesUniversity

  Scenario: create instance types
    * table instanceTypes
      | id                             | code                       |
      | universityInstanceTypeId       | 'apiTestsInstanceTypeCode' |
      | universitySecondInstanceTypeId | 'zzz'                      |
    * def v = call createInstanceType instanceTypes

  Scenario: create instance statuses
    * table instanceStatuses
      | id                               | code                         |
      | universityInstanceStatusId       | 'temp'                       |
      | universitySecondInstanceStatusId | 'apiTestsInstanceStatusCode' |
    * def v = call createInstanceStatus instanceStatuses

  Scenario: create loan types
    * table loanTypes
      | id                   | name            |
      | universityLoanTypeId | 'Can circulate' |
    * def v = call createLoanType loanTypes

  Scenario: create material types
    * table materialTypes
      | id                           | name   |
      | universityMaterialTypeIdPhys | 'Phys' |
      | universityMaterialTypeIdElec | 'Elec' |
    * def v = call createMaterialType materialTypes

  Scenario: create institutions
    * table institutions
      | id                                    | name          | code |
      | universityLocationUnitsInstitutionsId | 'Universitet' | 'TU' |
    * def v = call createInstitution institutions

  Scenario: create campus
    * table campuses
      | id                                | institutionId                         | name     | code |
      | universityLocationUnitsCampusesId | universityLocationUnitsInstitutionsId | 'Campus' | 'TC' |
    * def v = call createCampus campuses

  Scenario: create libraries
    * table libraries
      | id                                 | campusId                          | name      | code |
      | universityLocationUnitsLibrariesId | universityLocationUnitsCampusesId | 'Library' | 'TL' |
    * def v = call createLibrary libraries

  Scenario: create service points
    * table servicePoints
      | id                        | name            | code  | discoveryDisplayName |
      | universityServicePointsId | 'Service point' | 'TPS' | 'Service point 1'    |
    * def v = call createServicePoint servicePoints

  Scenario: create holdings sources
    * table holdingSources
      | id                         | name    |
      | universityHoldingsSourceId | 'FOLIO' |
    * def v = call createHoldingSource holdingSources

  Scenario: create locations
    * table locations
      | id                     | code   | institutionId                         | campusId                          | libraryId                          | servicePointId            |
      | universityLocationsId  | 'LOC1' | universityLocationUnitsInstitutionsId | universityLocationUnitsCampusesId | universityLocationUnitsLibrariesId | universityServicePointsId |
      | universityLocationsId2 | 'LOC2' | universityLocationUnitsInstitutionsId | universityLocationUnitsCampusesId | universityLocationUnitsLibrariesId | universityServicePointsId |
    * def v = call createLocation locations

  Scenario: Create instances
    * table instances
      | id                   | title          | instanceTypeId           |
      | universityInstanceId | 'instance uni' | universityInstanceTypeId |
    * def v = call createInstance instances

  Scenario: Create holdings
    * table holdings
      | id                   | instanceId           | locationId            | sourceId                   |
      | universityHoldingId1 | universityInstanceId | universityLocationsId | universityHoldingsSourceId |
      | universityHoldingId2 | universityInstanceId | universityLocationsId | universityHoldingsSourceId |
      | universityHoldingId3 | universityInstanceId | universityLocationsId | universityHoldingsSourceId |
    * def v = call createHolding holdings
