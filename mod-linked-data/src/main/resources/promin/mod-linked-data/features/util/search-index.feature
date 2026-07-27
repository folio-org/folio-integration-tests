Feature: Search index operations

  Background:
    * url baseUrl

  @dropSearchIndex
  Scenario: Drop search index for a given resource name
    Given path 'search/index/inventory/reindex'
    And request { recreateIndex: true, resourceName: '#(resourceName)' }
    When method POST
    Then status 200
