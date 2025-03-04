Feature: Applications

  Background:
    * url baseUrl

  @applicationsearch
  Scenario: searchApplication
    Given path 'applications'
    When method GET
    Then status 200
    * def totalAmount = get response.totalRecords

    Given path 'applications'
    And param limit = totalAmount
    When method GET
    Then status 200
    * def appIds = response.applicationDescriptors.map(x => x.id)
    * karate.set('applicationIds', appIds)
