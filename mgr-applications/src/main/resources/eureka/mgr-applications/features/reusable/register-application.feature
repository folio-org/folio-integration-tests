@ignore
Feature: register a minimal test application

  # Parameters: appName, version, moduleName, masterToken
  # Registers an application with a single backend module that has no provided interfaces.

  Background:
    * url baseUrl

  Scenario: register application
    * def appName = karate.get('appName')
    * def version = karate.get('version')
    * def moduleName = karate.get('moduleName')
    * def masterToken = karate.get('masterToken')
    * def moduleId = moduleName + '-' + version
    * configure headers = { 'Authorization': '#("Bearer " + masterToken)', 'X-Okapi-Token': '#(masterToken)' }

    * def applicationDescriptor =
      """
      {
        "name": "#(appName)",
        "version": "#(version)",
        "modules": [ { "id": "#(moduleId)", "name": "#(moduleName)", "version": "#(version)" } ],
        "moduleDescriptors": [ { "id": "#(moduleId)", "name": "#(moduleName)" } ]
      }
      """

    Given path 'applications'
    And request applicationDescriptor
    When method post
    Then status 201
    And match response.id == appName + '-' + version
