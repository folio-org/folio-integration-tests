
Feature: Module

  Background:
    * url baseUrl

  Scenario: get module by id
    Given path getModuleByIdPath
    And param filter = name
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200