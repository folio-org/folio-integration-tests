Feature: post instance

  Background:
    * url baseUrl

  Scenario: Create Instance
    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance = read('classpath:folijet/mod-source-record-storage/features/samples/instance.json')
    * set instance.id = instanceId
    * set instance.hrid = hrId
    And request instance
    When method POST
    Then status 201
