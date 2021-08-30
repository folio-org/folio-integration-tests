Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def instance = read('samples/instance-entity.json')
    * def holdingsRecord = read('samples/holdings-record-entity.json')
    * def instanceType = read('samples/instance-type-entity.json')
    * def location = read('samples/location-entity.json')
    * def institution = read('samples/institution-entity.json')
    * def campus = read('samples/campus-entity.json')
    * def library = read('samples/library-entity.json')
    * def loanTypes = read('samples/loan-type-entity.json')
    * instance.instanceTypeId = instanceType.id

  Scenario: init data
    Given path 'loan-types'
    And request loanTypes
    When method POST
    Then status 201

    Given path 'location-units/institutions'
    And request institution
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request campus
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request library
    When method POST
    Then status 201

    Given path 'locations'
    And request location
    When method POST
    Then status 201

    Given path 'instance-types'
    And request instanceType
    When method POST
    Then status 201

    Given path 'inventory/instances'
    And request instance
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And request holdingsRecord
    When method POST
    Then status 201
