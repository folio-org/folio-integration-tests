Feature: Event config

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def eventId = call uuid1

  Scenario: Get all event configs
    Given path 'eventConfig'
    When method GET
    Then status 200

  Scenario: Get event config by ID
    Given path 'eventConfig/767c364e-2eae-4e6c-bb55-ebcc68b7bf66'
    When method GET
    Then status 200
    And match $ == read('samples/create-password-event.json')

  Scenario: Get event configs by name using a query
    Given path 'eventConfig'
    * def eventName = 'TEST_EVENT'
    * def outputFormat = 'text/html'
    * def requestEntity = read('samples/event-config-request.json')
    And request requestEntity
    When method POST
    Then status 201

    Given path 'eventConfig'
    And param query = 'name==' + eventName
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.eventEntity[0] == requestEntity

  Scenario: Post event config
    Given path 'eventConfig'
    When method GET
    Then status 200
    * def initial_num_records = $.totalRecords

    Given path 'eventConfig'
    * def eventName = 'POST_TEST_EVENT'
    * def outputFormat = 'text/plain'
    * def requestEntity = read('samples/event-config-request.json')
    And request requestEntity
    When method POST
    Then status 201

    Given path 'eventConfig'
    When method GET
    Then status 200
    And match $.totalRecords == initial_num_records + 1

    Given path 'eventConfig/' + eventId
    When method GET
    Then status 200
    And match $ == requestEntity

  Scenario: Post HTML event config
    Given path 'eventConfig'
    * def eventName = 'HTML_TEST_EVENT'
    * def outputFormat = 'text/html'
    And request read('samples/event-config-request.json')
    When method POST
    Then status 201

    Given path 'eventConfig/' + eventId
    When method GET
    Then status 200
    And match $.name == eventName
    And match $.templates[0].outputFormat == outputFormat

  Scenario: Post text event config
    Given path 'eventConfig'
    * def eventName = 'TEXT_TEST_EVENT'
    * def outputFormat = 'text/plain'
    And request read('samples/event-config-request.json')
    When method POST
    Then status 201

    Given path 'eventConfig/' + eventId
    When method GET
    Then status 200
    And match $.name == eventName
    And match $.templates[0].outputFormat == outputFormat

  Scenario: Put event config
    Given path 'eventConfig'
    * def eventName = 'TEST_EVENT_BEFORE_UPDATE'
    * def outputFormat = 'text/html'
    And request read('samples/event-config-request.json')
    When method POST
    Then status 201

    Given path 'eventConfig/' + eventId
    * def eventName = 'UPDATED_TEST_EVENT'
    * def outputFormat = 'text/plain'
    * def requestEntity = read('samples/event-config-request.json')
    And request requestEntity
    When method PUT
    Then status 204

    Given path 'eventConfig/' + eventId
    When method GET
    Then status 200
    And match $ == requestEntity

  Scenario: Delete event config
    Given path 'eventConfig'
    * def eventName = 'EVENT_FOR_REMOVING'
    * def outputFormat = 'text/html'
    And request read('samples/event-config-request.json')
    When method POST
    Then status 201

    Given path 'eventConfig'
    When method GET
    Then status 200
    * def num_records = $.totalRecords

    Given path 'eventConfig/' + eventId
    When method DELETE
    Then status 204

    Given path 'eventConfig'
    When method GET
    Then status 200
    And match $.totalRecords == num_records - 1

    Given path 'eventConfig/' + eventId
    When method GET
    Then status 404

  Scenario: Should not allow to create configuration with duplicate name
    Given path 'eventConfig'
    * def eventName = 'DUPLICATED_TEST_EVENT'
    * def outputFormat = 'text/html'
    And request read('samples/event-config-request.json')
    When method POST
    Then status 201

    Given path 'eventConfig'
    And request read('samples/event-config-request.json')
    When method POST
    Then status 400
    And match $ contains 'id value already exists in table event_configurations'

  Scenario: Should return nothing when querying configs with the nonexistent name
    Given path 'eventConfig'
    And param query = 'name==NONEXISTENT EVENT'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: Should return 400 when query is invalid
    Given path 'eventConfig'
    And param query = 'nonexistent parameter==nonexistent'
    When method GET
    Then status 400