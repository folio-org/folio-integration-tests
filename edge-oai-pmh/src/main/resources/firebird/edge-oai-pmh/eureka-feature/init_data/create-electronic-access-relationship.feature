Feature: create electronic access relationship

  Background:
    * url baseUrl
    * callonce login testUser

  Scenario: post electronic relationship
    * def relationship = {}
    * set relationship.id = electronicRelationshipId
    * set relationship.name = name
    * set relationship.source = 'folio'

    Given path 'electronic-access-relationships'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request relationship
    When method POST
    Then status 201