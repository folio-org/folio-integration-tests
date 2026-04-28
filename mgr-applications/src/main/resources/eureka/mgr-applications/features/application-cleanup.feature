Feature: cleanup removes unentitled application and its Kong service

  Background:
    * url baseUrl
    * configure readTimeout = 3000000

  @Positive
  Scenario: cleanup removes unentitled application and cleans up Kong service and route
    * call read('classpath:eureka/mgr-applications/features/helpers.feature@loginAdmin')
    * def adminToken = okapitoken

    * def uniqueSuffix = nowMillis()
    * def syntheticAppName = 'it-cleanup-app-' + uniqueSuffix
    * def syntheticModuleName = 'it-cleanup-module-' + uniqueSuffix
    * def syntheticAppVersion = '1.0.0'
    * def syntheticModuleId = syntheticModuleName + '-' + syntheticAppVersion
    * def syntheticDiscoveryUrl = 'http://it-cleanup-' + uniqueSuffix + ':8080'
    * def syntheticHandlerId = 'it-cleanup-api-' + uniqueSuffix
    * def syntheticHandlerPath = '/it-cleanup-' + uniqueSuffix + '/{id}'

    * def syntheticApplicationDescriptor =
      """
      {
        "name": "#(syntheticAppName)",
        "version": "#(syntheticAppVersion)",
        "modules": [
          { "id": "#(syntheticModuleId)", "name": "#(syntheticModuleName)", "version": "#(syntheticAppVersion)" }
        ],
        "moduleDescriptors": [
          {
            "id": "#(syntheticModuleId)",
            "name": "#(syntheticModuleName)",
            "provides": [
              {
                "id": "#(syntheticHandlerId)",
                "version": "1.0",
                "handlers": [
                  { "methods": ["GET"], "pathPattern": "#(syntheticHandlerPath)" }
                ]
              }
            ]
          }
        ]
      }
      """

    * def createdApplication = call read('classpath:eureka/mgr-applications/features/helpers.feature@createApplication') { applicationDescriptor: '#(syntheticApplicationDescriptor)' }
    * def syntheticApplicationId = createdApplication.response.id

    * def discoveryRequest =
      """
      {
        "id": "#(syntheticModuleId)",
        "name": "#(syntheticModuleName)",
        "version": "#(syntheticAppVersion)",
        "location": "#(syntheticDiscoveryUrl)"
      }
      """

    * call read('classpath:eureka/mgr-applications/features/helpers.feature@createModuleDiscovery') { moduleId: '#(syntheticModuleId)', discoveryRequest: '#(discoveryRequest)' }

    # wait for Kong to register the service before running cleanup
    * configure retry = { count: 20, interval: 3000 }
    * url kongAdminUrl
    Given path 'services', syntheticModuleName
    And retry until responseStatus == 200
    When method GET

    # run cleanup
    * url baseUrl
    * def cleanupResult = call read('classpath:eureka/mgr-applications/features/helpers.feature@cleanupApplications')
    * def cleanupResponse = cleanupResult.response
    * match cleanupResponse.cleaned == cleanupResponse.cleanedIds.length
    * match cleanupResponse.cleanedIds contains syntheticApplicationId
    * match cleanupResponse.failedIds !contains syntheticApplicationId

    # verify application is removed from mgr-applications
    Given url baseUrl
    And path 'applications', syntheticApplicationId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 404

    # verify module discovery record is removed
    Given url baseUrl
    And path 'modules', 'discovery', syntheticModuleId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 404

    # verify Kong service is removed (with retry to allow async propagation)
    * configure retry = { count: 20, interval: 3000 }
    * url kongAdminUrl
    Given path 'services', syntheticModuleName
    And retry until responseStatus == 404
    When method GET
