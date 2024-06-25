Feature: global inventory

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json' }

  Scenario: create instance types
    * table instanceTypes
      | id                                     | code
      | '6d6f642d-0000-1111-aaaa-6f7264657273' | 'apiTestsInstanceTypeCode'
      | '30fffe0e-e985-4144-b2e2-1e8179bdb41f' | 'zzz'
    * def v = call createInstanceType instanceTypes

  Scenario: create instance statuses
    * table instanceStatuses
      | id                                     | code
      | '6d6f642d-0001-1111-aaaa-6f7264657273' | 'apiTestsInstanceStatusCode'
      | 'daf2681c-25af-4202-a3fa-e58fdf806183' | 'temp'
    * def v = call createInstanceStatus instanceStatuses

  Scenario: create loan types
    * table loanTypes
      | id                                     | name
      | '2b94c631-fca9-4892-a730-03ee529ffe27' | 'Can circulate'
    * def v = call createLoanType loanTypes

  Scenario: create material types
    * table materialTypes
      | id                                     | name
      | '6d6f642d-0003-1111-aaaa-6f7264657272' | 'Phys'
      | '6d6f642d-0003-1111-aaaa-6f7264657273' | 'Elec'
    * def v = call createMaterialType materialTypes

  Scenario: create institutions
    * table institutions
      | id                                     | name          | code
      | '40ee00ca-a518-4b49-be01-0638d0a4ac57' | 'Universitet' | 'TU'
    * def v = call createInstitution institutions

  Scenario: create campus
    * table campuses
      | id                                     | institutionId                          | name     | code
      | '62cf76b7-cca5-4d33-9217-edf42ce1a848' | '40ee00ca-a518-4b49-be01-0638d0a4ac57' | 'Campus' | 'TC'
    * def v = call createCampus campuses

  Scenario: create libraries
    * table libraries
      | id                                     | campusId                               | name      | code
      | '5d78803e-ca04-4b4a-aeae-2c63b924518b' | '62cf76b7-cca5-4d33-9217-edf42ce1a848' | 'Library' | 'TL'
    * def v = call createLibrary libraries

  Scenario: create service points
    * table servicePoints
      | id                                     | name            | code  | discoveryDisplayName
      | '3a40852d-49fd-4df2-a1f9-6e2641a6e91f' | 'Service point' | 'TPS' | 'Service point 1'
    * def v = call createServicePoint servicePoints

  Scenario: create holdings sources
    * table holdingSources
      | id                                     | name
      | 'f32d531e-df79-46b3-8932-cdd35f7a2264' | 'FOLIO'
    * def v = call createHoldingSource holdingSources

  Scenario: create locations
    * table locations
      | id                                     | code   | institutionId                          | campusId                               | libraryId                              | servicePointId
      | 'b32c5ce2-6738-42db-a291-2796b1c3c4c4' | 'LOC1' | '40ee00ca-a518-4b49-be01-0638d0a4ac57' | '62cf76b7-cca5-4d33-9217-edf42ce1a848' | '5d78803e-ca04-4b4a-aeae-2c63b924518b' | '3a40852d-49fd-4df2-a1f9-6e2641a6e91f'
    * def v = call createLocation locations
