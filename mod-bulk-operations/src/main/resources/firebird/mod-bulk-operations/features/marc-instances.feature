Feature: mod bulk operations marc-instances features

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-instances.feature')
    * callonce login testUser
    * callonce variables

  Scenario: Edit staff suppress for instances
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200