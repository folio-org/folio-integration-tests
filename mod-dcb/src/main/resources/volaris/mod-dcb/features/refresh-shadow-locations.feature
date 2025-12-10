Feature: Borrowing Flow Scenarios

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def key = ''
    * configure headers = headersUser
    * callonce variables


  @CreateTwoShadowLocations
  Scenario: Create a shadow location from location with agency for borrower transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def dcbAgency = { name: 'DCB Test Agency #1', code: 'AGT1' }
    * def dcbLocation1 = { name: 'DCB Test Location #1', code: 'LT1', agency: '#(dcbAgency)' }
    * def dcbLocation2 = { name: 'DCB Test Location #2', code: 'LT2', agency: '#(dcbAgency)' }
    * def orgPath = '/dcb/shadow-locations/refresh'
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath

    Given path newPath
    And request { locations: [ '#(dcbLocation1)', '#(dcbLocation2)' ] }
    And param apikey = key
    When method POST
    Then status 201
    And match $.locations[*].code contains only ['#(dcbLocation1.code)', '#(dcbLocation2.code)' ]
    And match $.locations[*].status contains only ['SUCCESS', 'SUCCESS']
    And match $['location-units'].institutions[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].institutions[*].status contains only ['SUCCESS']
    And match $['location-units'].campuses[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].campuses[*].status contains only ['SUCCESS']
    And match $['location-units'].libraries[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].libraries[*].status contains only ['SUCCESS']

    * def args = { name: '#(dcbAgency.name)', code: '#(dcbAgency.code)', isShadow: true }
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetInstitutionByNameAndCode') args
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetCampusByNameAndCode') args
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetLibraryByNameAndCode') args

    * def args = { name: '#(dcbLocation1.name)', code: '#(dcbLocation1.code)', isShadow: true }
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetLocationByNameAndCode') args

    * def args = { name: '#(dcbLocation2.name)', code: '#(dcbLocation2.code)', isShadow: true }
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetLocationByNameAndCode') args

  @RepeatCreationOfTwoShadowLocations
  Scenario: Repeat previous shadow locations refresh
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def dcbAgency = { name: 'DCB Test Agency #1', code: 'AGT1' }
    * def dcbLocation1 = { name: 'DCB Test Location #1', code: 'LT1', agency: '#(dcbAgency)' }
    * def dcbLocation2 = { name: 'DCB Test Location #2', code: 'LT2', agency: '#(dcbAgency)' }
    * def orgPath = '/dcb/shadow-locations/refresh'
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath

    Given path newPath
    And request { locations: [ '#(dcbLocation1)', '#(dcbLocation2)' ]}
    And param apikey = key
    When method POST
    Then status 201
    And match $.locations[*].code contains only ['#(dcbLocation1.code)', '#(dcbLocation2.code)' ]
    And match $.locations[*].status contains only ['SKIPPED', 'SKIPPED']
    And match $['location-units'].institutions[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].institutions[*].status contains only ['SKIPPED']
    And match $['location-units'].campuses[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].campuses[*].status contains only ['SKIPPED']
    And match $['location-units'].libraries[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].libraries[*].status contains only ['SKIPPED']

  @CreateShadowLocationFromAgency
  Scenario: Create a shadow location from agency (AGB2) for borrower transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def dcbAgency = { name: 'DCB Test Agency #2', code: 'AGT2' }
    * def orgPath = '/dcb/shadow-locations/refresh'
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath

    Given path newPath
    And request { agencies: [ '#(dcbAgency)' ]}
    And param apikey = key
    When method POST
    Then status 201
    And match $.locations[*].code contains only ['#(dcbAgency.code)']
    And match $.locations[*].status contains only ['SUCCESS']
    And match $['location-units'].institutions[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].institutions[*].status contains only ['SUCCESS']
    And match $['location-units'].campuses[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].campuses[*].status contains only ['SUCCESS']
    And match $['location-units'].libraries[*].code contains only ['#(dcbAgency.code)']
    And match $['location-units'].libraries[*].status contains only ['SUCCESS']

    * def args = { name: '#(dcbAgency.name)', code: '#(dcbAgency.code)', isShadow: true }
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetInstitutionByNameAndCode') args
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetCampusByNameAndCode') args
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetLibraryByNameAndCode') args
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetLocationByNameAndCode') args
