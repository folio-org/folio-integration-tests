Feature: CRUD operations on a resource
  Background:
    * url baseUrl

  @getResource
  Scenario: Get a resource
    Given path 'linked-data/resource/' + id
    When method Get
    Then status 200
    * def response = $

  @postResource
  Scenario: Post a resource
    Given path 'linked-data/resource'
    And request resourceRequest
    When method POST
    Then status 200
    * def response = $

  @putResource
  Scenario: Put a resource
    Given path 'linked-data/resource/' + id
    And request resourceRequest
    When method PUT
    Then status 200
    * def response = $

  @getResourceSupportCheck
  Scenario: Identify if instance can be imported
    Given path '/linked-data/inventory-instance/' + inventoryId + '/import-supported'
    When method GET
    Then status 200
    * def response = $

  @getResourcePreview
  Scenario: Get preview of a resource
    Given path '/linked-data/inventory-instance/' + inventoryId + '/preview'
    When method GET
    Then status 200
    * def response = $

  @postImport
  Scenario: Import MARC BIB record from SRS to linked-data
    Given path '/linked-data/inventory-instance/' + inventoryId + '/import'
    When method POST
    Then status 201
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

  @getSourceRecordFormatted
  Scenario: Get a source record
    Given path 'source-storage/records/' + inventoryId + '/formatted'
    And param idType = idType
    When method Get
    Then status 200
    * def response = $

  @getResourceGraph
  Scenario: Get a resource graph
    Given path '/linked-data/resource/' + resourceId + '/graph'
    When method Get
    Then status 200
    * def response = $

  @getDerivedMarc
  Scenario: Get derived MARC record
    Given path '/linked-data/resource/' + resourceId + '/marc'
    When method Get
    Then status 200
    * def response = $

  @getRdf
  Scenario: Derive Bibframe2 RDF
    Given path '/linked-data/resource/' + resourceId + '/rdf'
    When method Get
    Then status 200
    * def response = $

  @getResourceIdFromInventoryId
  Scenario: Get Instance Resource ID from Inveentory Instance Id
    Given path '/linked-data/resource/metadata/' + inventoryId + '/id'
    When method Get
    Then status 200
    * def response = $

  @previewHub
  Scenario: Preview HUB
    Given path 'linked-data/hub'
    And param hubUri = hubUri
    When method GET
    Then status 200
    * def response = $

  @importHub
  Scenario: Import HUB
    Given path 'linked-data/hub'
    And param hubUri = hubUri
    When method POST
    Then status 200
    * def response = $
