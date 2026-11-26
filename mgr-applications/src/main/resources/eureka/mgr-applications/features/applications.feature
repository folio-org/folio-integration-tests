Feature: mgr-applications - register, retrieve, list and deregister applications

  # Happy path for: POST /applications, GET /applications, GET /applications/{id}, DELETE /applications/{id}
  # All names/ids are randomized and everything created is removed in afterScenario, because the tests run against
  # environments that already contain data.

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

    # builds a minimal application descriptor with one backend module that provides one interface
    * def buildApplication =
      """
      function(appName, version, moduleName) {
        var moduleId = moduleName + '-' + version;
        return {
          name: appName,
          version: version,
          modules: [ { id: moduleId, name: moduleName, version: version } ],
          moduleDescriptors: [
            {
              id: moduleId,
              name: moduleName,
              provides: [ { id: 'it-iface-' + moduleName, version: '1.0', handlers: [ { methods: ['GET'], pathPattern: '/it-' + moduleName + '/{id}' } ] } ]
            }
          ]
        };
      }
      """

  @Positive
  Scenario: register, get (basic and full), search and deregister an application
    * def appName = 'it-app-' + suffix
    * def moduleName = 'it-mod-' + suffix
    * def appId = appName + '-1.0.0'
    * def moduleId = moduleName + '-1.0.0'
    * def applicationDescriptor = buildApplication(appName, '1.0.0', moduleName)
    * set applicationDescriptor.description = 'karate application ' + suffix

    # register (default validation)
    Given path 'applications'
    And request applicationDescriptor
    When method post
    Then status 201
    * karate.appendTo('createdAppIds', appId)
    And match response.id == appId
    And match response.name == appName
    And match response.version == '1.0.0'
    And match response.description == 'karate application ' + suffix
    And match response.modules == '#[1]'
    And match response.modules[0].id == moduleId

    # get by id
    Given path 'applications', appId
    When method get
    Then status 200
    And match response.id == appId
    And match response.name == appName
    And match response.version == '1.0.0'
    And match response.modules[*].id contains moduleId

    # get by id with full=true includes module descriptors
    Given path 'applications', appId
    And param full = true
    When method get
    Then status 200
    And match response.id == appId
    And match response.moduleDescriptors == '#[1]'
    And match response.moduleDescriptors[0].id == moduleId
    And match response.moduleDescriptors[0].provides[0].id == 'it-iface-' + moduleName

    # search by CQL (basic mode)
    Given path 'applications'
    And param query = 'id==' + appId
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.applicationDescriptors == '#[1]'
    And match response.applicationDescriptors[0].id == appId

    # search by CQL on name with pagination
    Given path 'applications'
    And param query = 'name==' + appName
    And param offset = 0
    And param limit = 1
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.applicationDescriptors[0].name == appName

    # search by CQL with full=true includes module descriptors
    Given path 'applications'
    And param query = 'id==' + appId
    And param full = true
    When method get
    Then status 200
    And match response.applicationDescriptors[0].moduleDescriptors[0].id == moduleId

    # deregister
    Given path 'applications', appId
    When method delete
    Then status 204

    # application is gone
    Given path 'applications', appId
    When method get
    Then status 404

    Given path 'applications'
    And param query = 'id==' + appId
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.applicationDescriptors == []

  @Positive
  Scenario: register an application with default validation disabled (check=false)
    * def appName = 'it-app-nocheck-' + suffix
    * def moduleName = 'it-mod-nocheck-' + suffix
    * def appId = appName + '-1.0.0'
    * def applicationDescriptor = buildApplication(appName, '1.0.0', moduleName)

    Given path 'applications'
    And param check = false
    And request applicationDescriptor
    When method post
    Then status 201
    * karate.appendTo('createdAppIds', appId)
    And match response.id == appId

    Given path 'applications', appId
    When method get
    Then status 200
    And match response.id == appId

  @Positive
  Scenario: register an application which depends on another application
    * def baseAppName = 'it-app-base-' + suffix
    * def baseModuleName = 'it-mod-base-' + suffix
    * def baseAppId = baseAppName + '-1.0.0'
    * def dependentAppName = 'it-app-dependent-' + suffix
    * def dependentModuleName = 'it-mod-dependent-' + suffix
    * def dependentAppId = dependentAppName + '-1.0.0'

    Given path 'applications'
    And request buildApplication(baseAppName, '1.0.0', baseModuleName)
    When method post
    Then status 201
    * karate.appendTo('createdAppIds', baseAppId)

    * def dependentDescriptor = buildApplication(dependentAppName, '1.0.0', dependentModuleName)
    * set dependentDescriptor.dependencies = [ { name: '#(baseAppName)', version: '^1.0.0' } ]
    Given path 'applications'
    And request dependentDescriptor
    When method post
    Then status 201
    * karate.appendTo('createdAppIds', dependentAppId)
    And match response.dependencies == '#[1]'
    And match response.dependencies[0].name == baseAppName
    And match response.dependencies[0].version == '^1.0.0'

  @Positive
  Scenario: list versions of an application using the advanced mode (appName, latest, preRelease, order, orderBy)
    * def appName = 'it-app-versions-' + suffix
    * def moduleName = 'it-mod-versions-' + suffix
    * def versions = [ '1.0.0', '1.1.0', '2.0.0', '2.1.0-SNAPSHOT.1' ]
    * def registerArgs = []
    * eval for (var i = 0; i < versions.length; i++) registerArgs.push({ appName: appName, version: versions[i], moduleName: moduleName, masterToken: masterToken })
    * eval for (var j = 0; j < versions.length; j++) createdAppIds.push(appName + '-' + versions[j])
    * call read('classpath:eureka/mgr-applications/features/reusable/register-application.feature') registerArgs

    # all versions, newest first by default
    Given path 'applications'
    And param appName = appName
    When method get
    Then status 200
    And match response.totalRecords == 4
    And match response.applicationDescriptors[*].version == [ '2.1.0-SNAPSHOT.1', '2.0.0', '1.1.0', '1.0.0' ]
    And match each response.applicationDescriptors contains { id: '#string', name: '#(appName)', version: '#string' }

    # ascending order by version
    Given path 'applications'
    And param appName = appName
    And param order = 'asc'
    And param orderBy = 'version'
    When method get
    Then status 200
    And match response.applicationDescriptors[*].version == [ '1.0.0', '1.1.0', '2.0.0', '2.1.0-SNAPSHOT.1' ]

    # ordering by id
    * def expectedIdsAsc = []
    * eval for (var k = 0; k < versions.length; k++) expectedIdsAsc.push(appName + '-' + versions[k])
    Given path 'applications'
    And param appName = appName
    And param order = 'asc'
    And param orderBy = 'id'
    When method get
    Then status 200
    And match response.applicationDescriptors[*].id == expectedIdsAsc

    # latest N releases
    Given path 'applications'
    And param appName = appName
    And param latest = 1
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.applicationDescriptors[0].version == '2.1.0-SNAPSHOT.1'

    # stable releases only
    Given path 'applications'
    And param appName = appName
    And param preRelease = 'false'
    When method get
    Then status 200
    And match response.applicationDescriptors[*].version == [ '2.0.0', '1.1.0', '1.0.0' ]

    # latest stable release
    Given path 'applications'
    And param appName = appName
    And param preRelease = 'false'
    And param latest = 1
    When method get
    Then status 200
    And match response.applicationDescriptors[*].version == [ '2.0.0' ]

    # pre-releases only
    Given path 'applications'
    And param appName = appName
    And param preRelease = 'only'
    When method get
    Then status 200
    And match response.applicationDescriptors[*].version == [ '2.1.0-SNAPSHOT.1' ]

    # full=true includes module descriptors
    Given path 'applications'
    And param appName = appName
    And param latest = 1
    And param preRelease = 'false'
    And param full = true
    When method get
    Then status 200
    And match response.applicationDescriptors[0].id == appName + '-2.0.0'
    And match response.applicationDescriptors[0].moduleDescriptors == '#[1]'
