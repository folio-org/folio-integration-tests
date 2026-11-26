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
    * def moduleConflictName = 'it-app-conflict-' + uniqueSuffix
    * def moduleId = moduleName + '-1.0.0'
    * def conflictApp =
      """
      {
        "name": "#(moduleConflictName)", "version": "1.0.0",
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

  @Positive
  Scenario Outline: ingress and egress bootstrap for a module that provides and <refType> the same interface
    * def refType = '<refType>'
    * def selfName = 'it-mod-eg-' + uniqueSuffix
    * def selfModuleId = selfName + '-1.0.0'
    * def selfAppName = 'it-app-eg-' + uniqueSuffix
    * def selfAppId = selfAppName + '-1.0.0'
    * def selfLocation = 'http://' + selfName + ':8081'
    * def otherName = 'it-mod-other-' + uniqueSuffix
    * def otherModuleId = otherName + '-1.0.0'
    * def otherAppName = 'it-app-other-' + uniqueSuffix
    * def otherAppId = otherAppName + '-1.0.0'
    * def otherLocation = 'http://' + otherName + ':8081'

    # Step 1: another module in another application provides the same (multiple) interface
    * def otherApp =
      """
      {
        "name": "#(otherAppName)", "version": "1.0.0",
        "modules": [ { "id": "#(otherModuleId)", "name": "#(otherName)", "version": "1.0.0" } ],
        "moduleDescriptors": [
          {
            "id": "#(otherModuleId)", "name": "#(otherName)",
            "provides": [ { "id": "#(interfaceId)", "version": "2.0", "interfaceType": "multiple" } ]
          }
        ]
      }
      """
    Given path 'applications'
    And header Authorization = 'Bearer ' + masterToken
    And request otherApp
    When method post
    Then status 201

    Given path 'modules', otherModuleId, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { id: '#(otherModuleId)', name: '#(otherName)', version: '1.0.0', location: '#(otherLocation)' }
    When method post
    Then status 201

    # Step 2: module that provides AND lists the same interface as <refType>
    * def selfDescriptor = { id: '#(selfModuleId)', name: '#(selfName)' }
    * def providedRef = { id: '#(interfaceId)', version: '2.0', interfaceType: 'multiple' }
    * def consumedRef = { id: '#(interfaceId)', version: '2.0' }
    * set selfDescriptor.provides = [ '#(providedRef)' ]
    * eval selfDescriptor[refType] = [ consumedRef ]
    * def selfApp =
      """
      {
        "name": "#(selfAppName)", "version": "1.0.0",
        "modules": [ { "id": "#(selfModuleId)", "name": "#(selfName)", "version": "1.0.0" } ],
        "moduleDescriptors": [ "#(selfDescriptor)" ]
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

    # Step 3: ingress bootstrap lists the provided interface exactly once and has no required modules
    Given path 'modules', selfModuleId, 'bootstrap'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.module.moduleId == selfModuleId
    And match response.module.location == selfLocation
    And match response.module.interfaces[*].id == [ '#(interfaceId)' ]
    And match response.requiredModules == '#[0]'

    # Step 4: egress bootstrap returns the other provider, never the module itself
    Given path 'modules', selfModuleId, 'bootstrap'
    And header Authorization = 'Bearer ' + masterToken
    And request { applicationIds: [ '#(selfAppId)', '#(otherAppId)' ] }
    When method post
    Then status 200
    And match response.requiredModules == '#[1]'
    And match response.requiredModules[0].moduleId == otherModuleId
    And match response.requiredModules[0].applicationId == otherAppId
    And match response.requiredModules[0].location == otherLocation
    And match response.requiredModules[0].interfaces[*].id == [ '#(interfaceId)' ]

    # Step 5: scope limited to the module's own application yields no providers (self is excluded)
    Given path 'modules', selfModuleId, 'bootstrap'
    And header Authorization = 'Bearer ' + masterToken
    And request { applicationIds: [ '#(selfAppId)' ] }
    When method post
    Then status 200
    And match response.requiredModules == '#[0]'

    # Cleanup
    Given path 'applications', selfAppId
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204

    Given path 'applications', otherAppId
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204

    Examples:
      | refType  |
      | optional |
      | requires |
