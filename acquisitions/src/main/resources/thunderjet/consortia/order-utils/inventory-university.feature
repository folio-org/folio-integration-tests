@parallel=false
Feature: Global inventory

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': '*/*' }
    * callonce variablesUniversity

  Scenario: Change HRID settings to use different prefixes than central tenant
    * def v = call updateHridSettings { instancesPrefix: 'inu', holdingsPrefix: 'hou', itemsPrefix: 'itu' }

  Scenario: Create instance types
    * table instanceTypes
      | id                             | code                       |
      | universityInstanceTypeId       | 'apiTestsInstanceTypeCode' |
      | universitySecondInstanceTypeId | 'zzz'                      |
    * def v = call createInstanceType instanceTypes

  Scenario: Create instance statuses
    * table instanceStatuses
      | id                               | code                         |
      | universityInstanceStatusId       | 'temp'                       |
      | universitySecondInstanceStatusId | 'apiTestsInstanceStatusCode' |
    * def v = call createInstanceStatus instanceStatuses

  Scenario: Create loan types
    * table loanTypes
      | id                   | name            |
      | universityLoanTypeId | 'Can circulate' |
    * def v = call createLoanType loanTypes

  Scenario: Create material types
    * table materialTypes
      | id                           | name   |
      | universityMaterialTypeIdPhys | 'Phys' |
      | universityMaterialTypeIdElec | 'Elec' |
    * def v = call createMaterialType materialTypes

  Scenario: Create institutions
    * table institutions
      | id                                    | name          | code |
      | universityLocationUnitsInstitutionsId | 'Universitet' | 'TU' |
    * def v = call createInstitution institutions

  Scenario: Create campus
    * table campuses
      | id                                | institutionId                         | name     | code |
      | universityLocationUnitsCampusesId | universityLocationUnitsInstitutionsId | 'Campus' | 'TC' |
    * def v = call createCampus campuses

  Scenario: Create libraries
    * table libraries
      | id                                 | campusId                          | name      | code |
      | universityLocationUnitsLibrariesId | universityLocationUnitsCampusesId | 'Library' | 'TL' |
    * def v = call createLibrary libraries

  Scenario: Create service points
    * def randomStr = call random_string
    * def name = 'Service-point-' + randomStr
    * def code = 'TPS-' + randomStr
    * def discoveryDisplayName = 'Service-point-1-' + randomStr
    * table servicePoints
      | id                        | name      | code      | discoveryDisplayName      |
      | universityServicePointsId | '#(name)' | '#(code)' | '#(discoveryDisplayName)' |
    * def v = call createServicePoint servicePoints

  Scenario: Create holdings sources
    * table holdingSources
      | id                         | name    |
      | universityHoldingsSourceId | 'FOLIO' |
    * def v = call createHoldingSource holdingSources

  Scenario: Create locations
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
