Feature: Fee/fine owners

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def ownerId = call uuid1
    * def servicePointId = call uuid1

  Scenario: Get non-existent fee/fine owner
    Given path 'owners', ownerId
    When method GET
    Then status 404

  Scenario: Create a fee/fine owner
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201
    # verify that metadata was added to owner record
    And match $.metadata == '#notnull'

  Scenario: Get fee/fine owner
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    Given path 'owners', ownerId
    When method GET
    Then status 200
    And match $.id == ownerId

  Scenario: Get a list of fee/fine owners
    Given path 'owners'
    When method GET
    Then status 200

  Scenario: Delete fee/fine owner
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    Given path 'owners', ownerId
    When method DELETE
    Then status 204