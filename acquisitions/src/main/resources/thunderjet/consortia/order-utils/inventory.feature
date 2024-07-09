Feature: Central inventory

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * callonce variablesCentral

  Scenario: create instance types
    * table instanceTypes
      | id                          | code                       |
      | centralInstanceTypeId       | 'apiTestsInstanceTypeCode' |
      | centralSecondInstanceTypeId | 'zzz'                      |
    * def v = call createInstanceType instanceTypes

  Scenario: create instance statuses
    * table instanceStatuses
      | id                            | code                         |
      | centralInstanceStatusId       | 'temp'                       |
      | centralSecondInstanceStatusId | 'apiTestsInstanceStatusCode' |
    * def v = call createInstanceStatus instanceStatuses

  Scenario: create loan types
    * table loanTypes
      | id                | name            |
      | centralLoanTypeId | 'Can circulate' |
    * def v = call createLoanType loanTypes

  Scenario: create material types
    * table materialTypes
      | id                        | name   |
      | centralMaterialTypeIdPhys | 'Phys' |
      | centralMaterialTypeIdElec | 'Elec' |
    * def v = call createMaterialType materialTypes

  Scenario: create institutions
    * table institutions
      | id                                 | name          | code |
      | centralLocationUnitsInstitutionsId | 'Universitet' | 'TU' |
    * def v = call createInstitution institutions

  Scenario: create campus
    * table campuses
      | id                             | institutionId                      | name     | code |
      | centralLocationUnitsCampusesId | centralLocationUnitsInstitutionsId | 'Campus' | 'TC' |
    * def v = call createCampus campuses

  Scenario: create libraries
    * table libraries
      | id                              | campusId                       | name      | code |
      | centralLocationUnitsLibrariesId | centralLocationUnitsCampusesId | 'Library' | 'TL' |
    * def v = call createLibrary libraries

  Scenario: create service points
    * table servicePoints
      | id                     | name            | code  | discoveryDisplayName |
      | centralServicePointsId | 'Service point' | 'TPS' | 'Service point 1'    |
    * def v = call createServicePoint servicePoints

  Scenario: create holdings sources
    * table holdingSources
      | id                      | name    |
      | centralHoldingsSourceId | 'FOLIO' |
    * def v = call createHoldingSource holdingSources

  Scenario: create locations
    * table locations
      | id                  | code   | institutionId                      | campusId                       | libraryId                       | servicePointId         |
      | centralLocationsId  | 'LOC1' | centralLocationUnitsInstitutionsId | centralLocationUnitsCampusesId | centralLocationUnitsLibrariesId | centralServicePointsId |
      | centralLocationsId2 | 'LOC2' | centralLocationUnitsInstitutionsId | centralLocationUnitsCampusesId | centralLocationUnitsLibrariesId | centralServicePointsId |
      | centralLocationsId3 | 'LOC3' | centralLocationUnitsInstitutionsId | centralLocationUnitsCampusesId | centralLocationUnitsLibrariesId | centralServicePointsId |
    * def v = call createLocation locations

  Scenario: Create instances
    * table instances
      | id                | title        | instanceTypeId        |
      | centralInstanceId | 'instance 1' | centralInstanceTypeId |
    * def v = call createInstance instances

  Scenario: Create holdings
    * table holdings
      | id                | instanceId        | locationId         | sourceId                |
      | centralHoldingId1 | centralInstanceId | centralLocationsId | centralHoldingsSourceId |
      | centralHoldingId2 | centralInstanceId | centralLocationsId | centralHoldingsSourceId |
      | centralHoldingId3 | centralInstanceId | centralLocationsId | centralHoldingsSourceId |
    * def v = call createHolding holdings
