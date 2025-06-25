Feature: Edge Orders MOSAIC

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login  testUser
    * def folioHeaders = { "Content-Type": "application/json", "x-okapi-token": "#(okapitoken)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def edgeHeaders = { "Content-Type": "application/xml", "Accept": "application/json" }

    * def apiKey = "eyJzIjoiZmxpcGFZTTdLcG9wbWhGbEYiLCJ0IjoidGVzdGVkZ2VvcmRlcnMiLCJ1IjoidGVzdC11c2VyIn0="
    * configure lowerCaseResponseHeaders = true

  Scenario: Validate Order apiKey
    Given url edgeUrl
    And path "mosaic/validate"
    And param type = "MOSAIC"
    And param apiKey = apiKey
    When method GET
    Then status 200
    And match $.status == "SUCCESS"