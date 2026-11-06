Feature: interface provided and required/optional in the same module descriptor

  # MGRAPPS-99: a module may provide an interface and also list it in `optional` or `requires`, but the same interface
  # cannot be both `requires` and `optional`.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def uniqueSuffix = nowMillis()
    * def interfaceId = 'it-dashboard-' + uniqueSuffix

  @Positive
  Scenario: register and bootstrap a module that provides and optionally consumes the same interface
    * def selfName = 'it-mod-self-' + uniqueSuffix
    * def selfModuleId = selfName + '-1.0.0'
    * def selfAppName = 'it-app-self-' + uniqueSuffix
    * def selfAppId = selfAppName + '-1.0.0'
    * def selfLocation = 'http://' + selfName + ':8081'

    # Step 1: module that provides AND lists the same interface as optional (previously failed on the primary key)
    * def selfApp =
      """
      {
        "name": "#(selfAppName)", "version": "1.0.0",
        "modules": [ { "id": "#(selfModuleId)", "name": "#(selfName)", "version": "1.0.0" } ],
        "moduleDescriptors": [
          {
            "id": "#(selfModuleId)", "name": "#(selfName)",
            "optional": [ { "id": "#(interfaceId)", "version": "2.0" } ],
            "provides": [ { "id": "#(interfaceId)", "version": "2.0", "interfaceType": "multiple" } ]
          }
        ]
      }
      """
    Given path 'applications'
    And header Authorization = 'Bearer ' + masterToken
    And request selfApp
    When method post
    Then status 201

    Given path 'modules', selfModuleId, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { id: '#(selfModuleId)', name: '#(selfName)', version: '1.0.0', location: '#(selfLocation)' }
    When method post
    Then status 201

    # Step 2: bootstrap lists the provided interface
    Given path 'modules', selfModuleId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.module.moduleId == selfModuleId
    And match response.module.applicationId == selfAppId
    And match response.module.interfaces[*].id contains interfaceId

    # Cleanup
    Given path 'applications', selfAppId
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204

  @Positive
  Scenario: register and bootstrap a module that provides and requires the same interface
    * def selfName = 'it-mod-selfreq-' + uniqueSuffix
    * def selfModuleId = selfName + '-1.0.0'
    * def selfAppName = 'it-app-selfreq-' + uniqueSuffix
    * def selfAppId = selfAppName + '-1.0.0'
    * def selfLocation = 'http://' + selfName + ':8081'

    # Step 1: module that provides AND lists the same interface as requires (previously failed on the primary key)
    * def selfApp =
      """
      {
        "name": "#(selfAppName)", "version": "1.0.0",
        "modules": [ { "id": "#(selfModuleId)", "name": "#(selfName)", "version": "1.0.0" } ],
        "moduleDescriptors": [
          {
            "id": "#(selfModuleId)", "name": "#(selfName)",
            "requires": [ { "id": "#(interfaceId)", "version": "2.0" } ],
            "provides": [ { "id": "#(interfaceId)", "version": "2.0", "interfaceType": "multiple" } ]
          }
        ]
      }
      """
    Given path 'applications'
    And header Authorization = 'Bearer ' + masterToken
    And request selfApp
    When method post
    Then status 201

    Given path 'modules', selfModuleId, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { id: '#(selfModuleId)', name: '#(selfName)', version: '1.0.0', location: '#(selfLocation)' }
    When method post
    Then status 201

    # Step 2: bootstrap lists the provided interface
    Given path 'modules', selfModuleId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.module.moduleId == selfModuleId
    And match response.module.applicationId == selfAppId
    And match response.module.interfaces[*].id contains interfaceId

    # Cleanup
    Given path 'applications', selfAppId
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204

  @Negative
  Scenario: validation rejects a module that lists the same interface as both required and optional
    * def moduleName = 'it-mod-conflict-' + uniqueSuffix
    * def moduleId = moduleName + '-1.0.0'
    * def conflictApp =
      """
      {
        "name": "it-app-conflict-#(uniqueSuffix)", "version": "1.0.0",
        "modules": [ { "name": "#(moduleName)", "version": "1.0.0" } ],
        "moduleDescriptors": [
          {
            "id": "#(moduleId)",
            "requires": [ { "id": "#(interfaceId)", "version": "2.0" } ],
            "optional": [ { "id": "#(interfaceId)", "version": "2.0" } ]
          }
        ]
      }
      """
    Given path 'applications', 'validate'
    And header Authorization = 'Bearer ' + masterToken
    And request conflictApp
    When method post
    Then status 400
    And match response.errors[0].message == 'Interface cannot be both required and optional'
    And match response.errors[0].code == 'validation_error'
    And match response.errors[0].parameters[0].key == moduleId
    And match response.errors[0].parameters[0].value == '[' + interfaceId + ']'
