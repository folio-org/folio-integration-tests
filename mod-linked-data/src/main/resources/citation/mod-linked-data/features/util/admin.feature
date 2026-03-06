Feature: Admin operations on linked data module
  Background:
    * url baseUrl

  @deleteCache
  Scenario: Delete cache
    Given path '/linked-data/admin/caches'
    When method delete
    Then status 204
