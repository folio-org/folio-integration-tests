Feature: mgr-applications - module discovery

  # Happy path for: POST /modules/{id}/discovery, GET /modules/{id}/discovery, PUT /modules/{id}/discovery,
  # DELETE /modules/{id}/discovery, GET /modules/discovery, POST /modules/discovery (batch upsert)
  # All names/ids are randomized and everything created is removed in afterScenario (deleting an application also
  # removes its modules and their discovery).

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * configure headers = { 'Authorization': '#("Bearer " + masterToken)', 'X-Okapi-Token': '#(masterToken)' }
    * def suffix = nowMillis() + '-' + uuid().substring(0, 4)

    * def createdAppIds = []
    * configure afterScenario =
      """
      function() {
        karate.call('classpath:eureka/mgr-applications/features/reusable/delete-applications.feature',
          { applicationIds: karate.get('createdAppIds'), masterToken: karate.get('masterToken') });
      }
      """

  @Positive
  Scenario: create, get, update, search and delete discovery of a single module
    * def appName = 'it-app-disc-' + suffix
    * def moduleName = 'it-mod-disc-' + suffix
    * def appId = appName + '-1.0.0'
    * def moduleId = moduleName + '-1.0.0'
    * def location = 'http://' + moduleName + ':8081'
    * def newLocation = 'http://' + moduleName + '-updated:8082'

    * call read('classpath:eureka/mgr-applications/features/reusable/register-application.feature') { appName: '#(appName)', version: '1.0.0', moduleName: '#(moduleName)', masterToken: '#(masterToken)' }
    * karate.appendTo('createdAppIds', appId)

    # create
    Given path 'modules', moduleId, 'discovery'
    And request { id: '#(moduleId)', name: '#(moduleName)', version: '1.0.0', location: '#(location)' }
    When method post
    Then status 201
    And match response.id == moduleId
    And match response.name == moduleName
    And match response.version == '1.0.0'
    And match response.location == location

    # get
    Given path 'modules', moduleId, 'discovery'
    When method get
    Then status 200
    And match response.id == moduleId
    And match response.name == moduleName
    And match response.version == '1.0.0'
    And match response.location == location

    # update
    Given path 'modules', moduleId, 'discovery'
    And request { id: '#(moduleId)', name: '#(moduleName)', version: '1.0.0', location: '#(newLocation)' }
    When method put
    Then status 204

    Given path 'modules', moduleId, 'discovery'
    When method get
    Then status 200
    And match response.location == newLocation

    # search by CQL
    Given path 'modules', 'discovery'
    And param query = 'id==' + moduleId
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.discovery == '#[1]'
    And match response.discovery[0].id == moduleId
    And match response.discovery[0].location == newLocation

    # search by CQL with pagination
    Given path 'modules', 'discovery'
    And param query = 'name==' + moduleName
    And param offset = 0
    And param limit = 1
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.discovery[0].name == moduleName

    # delete
    Given path 'modules', moduleId, 'discovery'
    When method delete
    Then status 204

    Given path 'modules', moduleId, 'discovery'
    When method get
    Then status 404

    Given path 'modules', 'discovery'
    And param query = 'id==' + moduleId
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.discovery == []

  @Positive
  Scenario: create and update discovery of several modules in a batch (upsert)
    * def firstAppName = 'it-app-batch1-' + suffix
    * def firstModuleName = 'it-mod-batch1-' + suffix
    * def firstAppId = firstAppName + '-1.0.0'
    * def firstModuleId = firstModuleName + '-1.0.0'
    * def firstLocation = 'http://' + firstModuleName + ':8081'
    * def secondAppName = 'it-app-batch2-' + suffix
    * def secondModuleName = 'it-mod-batch2-' + suffix
    * def secondAppId = secondAppName + '-1.0.0'
    * def secondModuleId = secondModuleName + '-1.0.0'
    * def secondLocation = 'http://' + secondModuleName + ':8081'

    * call read('classpath:eureka/mgr-applications/features/reusable/register-application.feature') { appName: '#(firstAppName)', version: '1.0.0', moduleName: '#(firstModuleName)', masterToken: '#(masterToken)' }
    * karate.appendTo('createdAppIds', firstAppId)
    * call read('classpath:eureka/mgr-applications/features/reusable/register-application.feature') { appName: '#(secondAppName)', version: '1.0.0', moduleName: '#(secondModuleName)', masterToken: '#(masterToken)' }
    * karate.appendTo('createdAppIds', secondAppId)

    # create discoveries of both modules
    Given path 'modules', 'discovery'
    And request
      """
      {
        "discovery": [
          { "id": "#(firstModuleId)", "name": "#(firstModuleName)", "version": "1.0.0", "location": "#(firstLocation)" },
          { "id": "#(secondModuleId)", "name": "#(secondModuleName)", "version": "1.0.0", "location": "#(secondLocation)" }
        ]
      }
      """
    When method post
    Then status 201
    And match response.totalRecords == 2
    And match response.discovery == '#[2]'
    And match response.discovery[*].id contains only [ '#(firstModuleId)', '#(secondModuleId)' ]
    And match response.discovery[*].location contains only [ '#(firstLocation)', '#(secondLocation)' ]

    Given path 'modules', 'discovery'
    And param query = 'id==' + firstModuleId + ' or id==' + secondModuleId
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.discovery[*].id contains only [ '#(firstModuleId)', '#(secondModuleId)' ]

    # upsert: the first module keeps its location, the second one is moved to a new location
    * def movedLocation = 'http://' + secondModuleName + '-moved:8082'
    Given path 'modules', 'discovery'
    And request
      """
      {
        "discovery": [
          { "id": "#(firstModuleId)", "name": "#(firstModuleName)", "version": "1.0.0", "location": "#(firstLocation)" },
          { "id": "#(secondModuleId)", "name": "#(secondModuleName)", "version": "1.0.0", "location": "#(movedLocation)" }
        ]
      }
      """
    When method post
    Then status 201
    And match response.totalRecords == 2

    Given path 'modules', firstModuleId, 'discovery'
    When method get
    Then status 200
    And match response.location == firstLocation

    Given path 'modules', secondModuleId, 'discovery'
    When method get
    Then status 200
    And match response.location == movedLocation

    # clean the discovery of both modules
    Given path 'modules', firstModuleId, 'discovery'
    When method delete
    Then status 204

    Given path 'modules', secondModuleId, 'discovery'
    When method delete
    Then status 204
