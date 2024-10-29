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

  @postBibToSrs
  Scenario: POST a MARC Bib record to SRS
    Given path 'records-editor/records'
    And request srsBibRequest
    When method post
    Then status 201

  @getInventoryInstance
  Scenario: Get instance from inventory
    Given path 'inventory/instances/' + id
    When method get
    Then status 200
    * def response = $

  @putInventoryInstance
  Scenario: Put an instance
    Given path 'inventory/instances/' + inventoryInstanceId
    And request inventoryInstance
    When method put
    Then status 204
    * def response = $