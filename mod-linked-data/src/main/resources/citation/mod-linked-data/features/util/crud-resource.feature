Feature: CRUD operations on a resource
  Background:
    * url baseUrl

  @getResource
  Scenario: Get a resource
    Given path 'resource/' + id
    When method Get
    Then status 200
    * def response = $

  @postResource
  Scenario: Post a resource
    Given path 'resource'
    And request resourceRequest
    When method POST
    Then status 200
    * def response = $

  @putResource
  Scenario: Put a resource
    Given path 'resource/' + id
    And request resourceRequest
    When method PUT
    Then status 200
    * def response = $

  @postSourceRecordToStorage
  Scenario: POST a source record to SRS
    Given path 'records-editor/records'
    And request sourceRecordRequest
    When method post
    Then status 201
    * def response = $

  @putSourceRecordToStorage
  Scenario: Put a source record to SRS
    Given path 'records-editor/records/' + sourceRecordId
    And request sourceRecordUpdateRequest
    When method put
    Then status 202

  @getInventoryInstance
  Scenario: Get instance from inventory
    Given path 'inventory/instances/' + id
    When method get
    Then status 200
    * def response = $

  @putInventoryInstance
  Scenario: Put an instance (note: this API don't have a response, 'def response = $' will fail)
    Given path 'inventory/instances/' + inventoryInstanceId
    And request inventoryInstance
    When method put
    Then status 204

  @postAuthorityFile
  Scenario: Post an authority file
    Given path 'authority-source-files'
    And request authorityFileRequest
    When method POST
    Then status 201

  @getSourceRecordFormatted
  Scenario: Get a source record
    Given path 'source-storage/records/' + inventoryId + '/formatted'
    And param idType = idType
    When method Get
    Then status 200
    * def response = $

  @getResourceGraph
  Scenario: Get a resource graph
    Given path '/graph/resource/' + resourceId
    When method Get
    Then status 200
    * def response = $