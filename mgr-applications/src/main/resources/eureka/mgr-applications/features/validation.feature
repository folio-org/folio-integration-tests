Feature: mgr-applications - validate application descriptors, interfaces and descriptor dependencies

  # Happy path for: POST /applications/validate, POST /applications/validate-interfaces,
  # POST /applications/validate-descriptors
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

    # provider application: one module providing an interface
    * def providerAppName = 'it-app-provider-' + suffix
    * def providerModuleName = 'it-mod-provider-' + suffix
    * def providerAppId = providerAppName + '-1.0.0'
    * def providerModuleId = providerModuleName + '-1.0.0'
    * def interfaceId = 'it-iface-' + suffix
    * def providerPath = '/it-provider-' + suffix + '/{id}'
    * def providerApp =
      """
      {
        "id": "#(providerAppId)",
        "name": "#(providerAppName)",
        "version": "1.0.0",
        "modules": [ { "id": "#(providerModuleId)", "name": "#(providerModuleName)", "version": "1.0.0" } ],
        "moduleDescriptors": [
          {
            "id": "#(providerModuleId)",
            "name": "#(providerModuleName)",
            "provides": [
              { "id": "#(interfaceId)", "version": "1.0",
                "handlers": [ { "methods": ["GET"], "pathPattern": "#(providerPath)" } ] }
            ]
          }
        ]
      }
      """

    # consumer application: depends on the provider application and requires its interface
    * def consumerAppName = 'it-app-consumer-' + suffix
    * def consumerModuleName = 'it-mod-consumer-' + suffix
    * def consumerAppId = consumerAppName + '-1.0.0'
    * def consumerModuleId = consumerModuleName + '-1.0.0'
    * def consumerApp =
      """
      {
        "id": "#(consumerAppId)",
        "name": "#(consumerAppName)",
        "version": "1.0.0",
        "modules": [ { "id": "#(consumerModuleId)", "name": "#(consumerModuleName)", "version": "1.0.0" } ],
        "moduleDescriptors": [
          {
            "id": "#(consumerModuleId)",
            "name": "#(consumerModuleName)",
            "requires": [ { "id": "#(interfaceId)", "version": "1.0" } ]
          }
        ],
        "dependencies": [ { "name": "#(providerAppName)", "version": "^1.0.0" } ]
      }
      """

  @Positive
  Scenario Outline: validate a valid application descriptor in <mode> mode
    Given path 'applications', 'validate'
    And param mode = '<mode>'
    And request providerApp
    When method post
    Then status 204

    Examples:
      | mode     |
      | default  |
      | basic    |
      | onCreate |

  @Positive
  Scenario: validate an application descriptor without the mode parameter
    Given path 'applications', 'validate'
    And request consumerApp
    When method post
    Then status 204

  @Positive
  Scenario: validate interfaces integrity of registered applications
    Given path 'applications'
    And request providerApp
    When method post
    Then status 201
    * karate.appendTo('createdAppIds', providerAppId)

    Given path 'applications'
    And request consumerApp
    When method post
    Then status 201
    * karate.appendTo('createdAppIds', consumerAppId)

    # the consumer together with its dependency chain is consistent
    Given path 'applications', 'validate-interfaces'
    And request { applicationIds: [ '#(consumerAppId)' ] }
    When method post
    Then status 204

    # several applications at once
    Given path 'applications', 'validate-interfaces'
    And request { applicationIds: [ '#(providerAppId)', '#(consumerAppId)' ] }
    When method post
    Then status 204

  @Positive
  Scenario: validate descriptors dependencies integrity without registering the applications
    Given path 'applications', 'validate-descriptors'
    And request { applicationDescriptors: [ '#(providerApp)', '#(consumerApp)' ] }
    When method post
    Then status 200
    And match response == [ '#(consumerAppId)', '#(providerAppId)' ]

  @Positive
  Scenario: validate descriptors dependencies integrity limited to a scope application
    # scope = consumer: consumer and its dependency tree (provider) are validated
    Given path 'applications', 'validate-descriptors'
    And request { applicationDescriptors: [ '#(providerApp)', '#(consumerApp)' ], scopeApplicationId: '#(consumerAppId)' }
    When method post
    Then status 200
    And match response == [ '#(consumerAppId)', '#(providerAppId)' ]

    # scope = provider: provider has no dependencies, so only it is validated
    Given path 'applications', 'validate-descriptors'
    And request { applicationDescriptors: [ '#(providerApp)', '#(consumerApp)' ], scopeApplicationId: '#(providerAppId)' }
    When method post
    Then status 200
    And match response == [ '#(providerAppId)' ]
