Feature: Module

  Background:
    * url baseUrl

  Scenario: get module by id
    * def modulesUrl = '_/proxy/tenants/' + prototypeTenant + '/modules'
    Given path modulesUrl
    And param filter = name
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200



