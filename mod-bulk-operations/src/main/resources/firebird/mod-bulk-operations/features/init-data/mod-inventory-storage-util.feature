Feature: setup holdings data feature

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)' }

  @PostServicePoints
  Scenario: POST service-points
    Given path 'service-points'
    And request servicePoints
    When method POST
    Then status 201

  @PostInstitutions
  Scenario: POST institutions
    Given path 'location-units/institutions'
    And request institutions
    When method POST
    Then status 201

  @PostCampuses
  Scenario: POST campuses
    Given path 'location-units/campuses'
    And request campuses
    When method POST
    Then status 201

  @PostLibraries
  Scenario: POST libraries
    Given path 'location-units/libraries'
    And request libraries
    When method POST
    Then status 201

  @PostLocationMain
  Scenario: POST location main
    Given path 'locations'
    And request location_main
    When method POST
    Then status 201

  @PostLocationPopularReading
  Scenario: POST location popular reading
    Given path 'locations'
    And request location_popular_reading
    When method POST
    Then status 201

  @PostIdentifierTypes
  Scenario: POST identifier-types
    Given path 'identifier-types'
    And request identifierTypes
    When method POST
    Then status 201

  @PostInstanceTypes
  Scenario: POST instance-types
    Given path 'instance-types'
    And request instanceTypes
    When method POST
    Then status 201

  @PostContributorNameTypes
  Scenario: POST contributor-name-types
    Given path 'contributor-name-types'
    And request contributorNameTypes
    When method POST
    Then status 201

  @PostClassificationTypes
  Scenario: POST classification-types
    Given path 'classification-types'
    And request classificationTypes
    When method POST
    Then status 201

  @PostInstances
  Scenario: POST instances
    Given path 'instance-storage/instances'
    And request instances
    When method POST
    Then status 201

  @PostHoldingsSources
  Scenario: POST holdings sources
    Given path 'holdings-sources'
    And request holdingsSources
    When method POST
    Then status 201

  @PostHoldings
  Scenario: POST holdings
    Given path 'holdings-storage/holdings'
    And request holdings
    When method POST
    Then status 201