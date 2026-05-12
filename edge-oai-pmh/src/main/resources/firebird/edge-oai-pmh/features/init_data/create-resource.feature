Feature: Create Work and Instance resource using API

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: create work and instance resources through API
    * def workRequest = read('samples/work-request.json')
    Given path 'linked-data/resource'
    And request resourceRequest
    When method POST
    Then status 200
    * def response = $
    * def workId = response.resource['http://bibfra.me/vocab/lite/Work'].id

    * def instanceRequest = read('samples/instance-request.json')
    Given path 'linked-data/resource'
    And request resourceRequest
    When method POST
    Then status 200
    * def response = $
    * def instanceId = response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata.inventoryId