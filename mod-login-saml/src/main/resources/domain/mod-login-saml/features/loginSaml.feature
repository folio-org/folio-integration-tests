Feature: Template engine

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Check the SAML endpoint
    Given path '/saml/check'
    #And header x-okapi-tenant = testUser.tenant
    When method GET
    Then status 200

  Scenario: Get all templates
    Given path 'templates'
    When method GET
    Then status 200
