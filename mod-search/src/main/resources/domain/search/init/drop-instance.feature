Feature: Remove an instance
  Background:
    * url baseUrl
    * configure headers = baseHeaders

  Scenario: Drop instance with given id
    Given path 'instance-storage/instances/' + instanceId
    When method DELETE
    Then status 204