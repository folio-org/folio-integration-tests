Feature: mgr-applications - module bootstrap

  # Happy path for: GET /modules/{id}, GET /modules/{id}/bootstrap (ingress), POST /modules/{id}/bootstrap (egress)
  # (ingress/egress bootstrap of a module that provides and consumes the same interface is covered in
  # interface-provided-and-consumed.feature)
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
  Scenario: get full, ingress and egress bootstrap of a module that requires an interface of another module
    * def interfaceId = 'it-iface-' + suffix
    * def providerPath = '/it-bs-' + suffix + '/{id}'

    * def providerAppName = 'it-app-bsprov-' + suffix
    * def providerModuleName = 'it-mod-bsprov-' + suffix
    * def providerAppId = providerAppName + '-1.0.0'
    * def providerModuleId = providerModuleName + '-1.0.0'
    * def providerLocation = 'http://' + providerModuleName + ':8081'

    * def consumerAppName = 'it-app-bscons-' + suffix
    * def consumerModuleName = 'it-mod-bscons-' + suffix
    * def consumerAppId = consumerAppName + '-1.0.0'
    * def consumerModuleId = consumerModuleName + '-1.0.0'
    * def consumerLocation = 'http://' + consumerModuleName + ':8081'

    # provider application with a module providing the interface
    * def providerApp =
      """
      {
        "name": "#(providerAppName)", "version": "1.0.0",
        "modules": [ { "id": "#(providerModuleId)", "name": "#(providerModuleName)", "version": "1.0.0" } ],
        "moduleDescriptors": [
          {
            "id": "#(providerModuleId)", "name": "#(providerModuleName)",
            "provides": [
              { "id": "#(interfaceId)", "version": "1.0",
                "handlers": [ { "methods": ["GET"], "pathPattern": "#(providerPath)" } ] }
            ]
          }
        ]
      }
      """
    Given path 'applications'
    And request providerApp
    When method post
    Then status 201
    * karate.appendTo('createdAppIds', providerAppId)

    # consumer application with a module requiring the interface
    * def consumerApp =
      """
      {
        "name": "#(consumerAppName)", "version": "1.0.0",
        "modules": [ { "id": "#(consumerModuleId)", "name": "#(consumerModuleName)", "version": "1.0.0" } ],
        "moduleDescriptors": [
          {
            "id": "#(consumerModuleId)", "name": "#(consumerModuleName)",
            "requires": [ { "id": "#(interfaceId)", "version": "1.0" } ]
          }
        ],
        "dependencies": [ { "name": "#(providerAppName)", "version": "^1.0.0" } ]
      }
      """
    Given path 'applications'
    And request consumerApp
    When method post
    Then status 201
    * karate.appendTo('createdAppIds', consumerAppId)

    Given path 'modules', providerModuleId, 'discovery'
    And request { id: '#(providerModuleId)', name: '#(providerModuleName)', version: '1.0.0', location: '#(providerLocation)' }
    When method post
    Then status 201

    Given path 'modules', consumerModuleId, 'discovery'
    And request { id: '#(consumerModuleId)', name: '#(consumerModuleName)', version: '1.0.0', location: '#(consumerLocation)' }
    When method post
    Then status 201

    # full bootstrap of the consumer: its own info plus the modules it requires
    Given path 'modules', consumerModuleId
    When method get
    Then status 200
    And match response.module.moduleId == consumerModuleId
    And match response.module.applicationId == consumerAppId
    And match response.module.location == consumerLocation
    And match response.requiredModules == '#[1]'
    And match response.requiredModules[0].moduleId == providerModuleId
    And match response.requiredModules[0].applicationId == providerAppId
    And match response.requiredModules[0].location == providerLocation
    And match response.requiredModules[0].interfaces[*].id == [ '#(interfaceId)' ]

    # full bootstrap of the provider: no required modules
    Given path 'modules', providerModuleId
    When method get
    Then status 200
    And match response.module.moduleId == providerModuleId
    And match response.module.applicationId == providerAppId
    And match response.module.location == providerLocation
    And match response.module.interfaces[*].id == [ '#(interfaceId)' ]
    And match response.requiredModules == '#[0]'

    # ingress bootstrap: only the module's own routes, requiredModules is empty
    Given path 'modules', consumerModuleId, 'bootstrap'
    When method get
    Then status 200
    And match response.module.moduleId == consumerModuleId
    And match response.module.applicationId == consumerAppId
    And match response.module.location == consumerLocation
    And match response.requiredModules == '#[0]'

    Given path 'modules', providerModuleId, 'bootstrap'
    When method get
    Then status 200
    And match response.module.moduleId == providerModuleId
    And match response.module.interfaces[*].id == [ '#(interfaceId)' ]
    And match response.requiredModules == '#[0]'

    # egress bootstrap: required modules resolved within the supplied application scope
    Given path 'modules', consumerModuleId, 'bootstrap'
    And request { applicationIds: [ '#(consumerAppId)', '#(providerAppId)' ] }
    When method post
    Then status 200
    And match response.requiredModules == '#[1]'
    And match response.requiredModules[0].moduleId == providerModuleId
    And match response.requiredModules[0].applicationId == providerAppId
    And match response.requiredModules[0].location == providerLocation
    And match response.requiredModules[0].interfaces[*].id == [ '#(interfaceId)' ]
