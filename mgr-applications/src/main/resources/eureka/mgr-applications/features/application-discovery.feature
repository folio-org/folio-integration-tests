Feature: mgr-applications - application discovery

  # Happy path for: GET /applications/{id}/discovery, GET /applications/discovery
  # All names/ids are randomized and everything created is removed in afterScenario.

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
  Scenario: get discovery of an application and search discoveries of applications
    * def appName = 'it-app-appdisc-' + suffix
    * def moduleName = 'it-mod-appdisc-' + suffix
    * def appId = appName + '-1.0.0'
    * def moduleId = moduleName + '-1.0.0'
    * def location = 'http://' + moduleName + ':8081'

    * call read('classpath:eureka/mgr-applications/features/reusable/register-application.feature') { appName: '#(appName)', version: '1.0.0', moduleName: '#(moduleName)', masterToken: '#(masterToken)' }
    * karate.appendTo('createdAppIds', appId)

    # no module discovery is registered yet
    Given path 'applications', appId, 'discovery'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.discovery == []

    Given path 'modules', moduleId, 'discovery'
    And request { id: '#(moduleId)', name: '#(moduleName)', version: '1.0.0', location: '#(location)' }
    When method post
    Then status 201

    # discovery of the application
    Given path 'applications', appId, 'discovery'
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.discovery == '#[1]'
    And match response.discovery[0].id == moduleId
    And match response.discovery[0].name == moduleName
    And match response.discovery[0].version == '1.0.0'
    And match response.discovery[0].location == location

    # discovery of the application with pagination
    Given path 'applications', appId, 'discovery'
    And param offset = 0
    And param limit = 10
    When method get
    Then status 200
    And match response.totalRecords == 1

    # search application discoveries by CQL, grouped by application
    Given path 'applications', 'discovery'
    And param query = 'id==' + appId
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.applicationDiscoveries == '#[1]'
    And match response.applicationDiscoveries[0].applicationId == appId
    And match response.applicationDiscoveries[0].discovery == '#[1]'
    And match response.applicationDiscoveries[0].discovery[0].id == moduleId
    And match response.applicationDiscoveries[0].discovery[0].location == location

    # search application discoveries with pagination
    Given path 'applications', 'discovery'
    And param query = 'name==' + appName
    And param offset = 0
    And param limit = 1
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.applicationDiscoveries[0].applicationId == appId
