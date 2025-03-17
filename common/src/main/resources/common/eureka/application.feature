Feature: Applications

  Background:
    * url baseUrl

  @applicationSearch
  Scenario: searchApplication

    Given path 'applications'
    And param limit = requiredApplications.length
    And param query = orWhereQuery('name', requiredApplications)
    When method GET
    Then status 200
    * def appIds = response.applicationDescriptors.map(x => x.id)
    * def receivedAppNames = response.applicationDescriptors.map(x => x.name)
    Then match receivedAppNames contains requiredApplications
    * karate.set('applicationIds', appIds)
