Feature: Applications

  Background:
    * url baseUrl

  @applicationsearch
  Scenario: searchApplication
    Given path 'applications'
    When method GET
    Then status 200
    * def appId = response.applicationDescriptors.filter(x => x.description == 'Application comprised of all Folio modules')[0].id
    * karate.set('allFolioModulesApplicationId', appId)
