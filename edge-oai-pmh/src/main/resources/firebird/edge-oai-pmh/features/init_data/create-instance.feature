Feature: create instance

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: post instance
    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.instanceTypeId = instanceTypeId
    * set instance.hrid = instanceHrid
    * set instance.source = instanceSource
    And request instance
    When method POST
    Then status 201