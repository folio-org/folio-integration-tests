Feature: Borrowing Flow Scenarios

  Background:
    * url baseUrl
    * def user = testUser
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    # load global variables
    * callonce variables

    # Delete all shadow locations, institutions, campuses and libraries if exist
    # This is to ensure that we are creating shadow locations from scratch
    # before running the refresh shadow locations API
    * call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteShadowLocations')
    * call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteShadowLibraries')
    * call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteShadowCampuses')
    * call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteShadowInstitutions')

  Scenario: Validate all shadow locations are created initially and skipped if already exist
    * print 'Validate all shadow locations are created initially and skipped if already exist'
    # Create mock server data for shadow locations
    * call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@CreateMockServerShadowLocationsData')

    # Call refresh shadow locations API to create shadow locations, institutions, campuses and libraries
    Given path '/dcb/shadow-locations/refresh'
    When method POST
    Then status 201
    And match each response.locations contains { status: 'SUCCESS' }
    And match response.locations[*].code contains ['LOC-1', 'LOC-2', 'LOC-3', 'LOC-4', 'LOC-5', 'LOC-6', 'LOC-7', 'LOC-8']

    And match each response['location-units'].institutions contains { status: 'SUCCESS' }
    And match response['location-units'].institutions[*].code contains ['AG-001', 'AG-002', 'AG-003', 'AG-004', 'AG-005']

    And match each response['location-units'].campuses contains { status: 'SUCCESS' }
    And match response['location-units'].campuses[*].code contains ['AG-001', 'AG-002', 'AG-003', 'AG-004', 'AG-005']

    And match each response['location-units'].libraries contains { status: 'SUCCESS' }
    And match response['location-units'].libraries[*].code contains ['AG-001', 'AG-002', 'AG-003', 'AG-004', 'AG-005']
    * print response

    # Validate Skipped status when shadow locations, institutions, campuses and libraries already exist
    Given path '/dcb/shadow-locations/refresh'
    When method POST
    Then status 201
    And match each response.locations contains { status: 'SKIPPED' }
    And match response.locations[*].code contains ['LOC-1', 'LOC-2', 'LOC-3', 'LOC-4', 'LOC-5', 'LOC-6', 'LOC-7', 'LOC-8']

    And match each response['location-units'].institutions contains { status: 'SKIPPED' }
    And match response['location-units'].institutions[*].code contains ['AG-001', 'AG-002', 'AG-003', 'AG-004', 'AG-005']

    And match each response['location-units'].campuses contains { status: 'SKIPPED' }
    And match response['location-units'].campuses[*].code contains ['AG-001', 'AG-002', 'AG-003', 'AG-004', 'AG-005']

    And match each response['location-units'].libraries contains { status: 'SKIPPED' }
    And match response['location-units'].libraries[*].code contains ['AG-001', 'AG-002', 'AG-003', 'AG-004', 'AG-005']
    * print response

  Scenario: Validate few shadow locations are created which were not existed before and others are skipped
    # Call refresh shadow locations API to create shadow locations, institutions, campuses and libraries
    * print 'alidate few shadow locations are created which were not existed before and others are skipped'
    # Create mock server data for shadow locations
    * call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@CreateMockServerShadowLocationsData')

    Given path '/dcb/shadow-locations/refresh'
    When method POST
    Then status 201

    # Delete few shadow locations, institutions, campuses and libraries to validate that they are created again
    * def result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteLocationByNameAndCode', { name: 'Location-1', code: 'LOC-1' })
    * def result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteLocationByNameAndCode', { name: 'Location-6', code: 'LOC-6' })
    * def result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteLibraryByNameAndCode', { name: 'Agency-One', code: 'AG-001' })
    * def result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteCampusByNameAndCode', { name: 'Agency-One', code: 'AG-001' })
    * def result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteInstitutionByNameAndCode', { name: 'Agency-One', code: 'AG-001'})


    Given path '/dcb/shadow-locations/refresh'
    When method POST
    Then status 201
    # Validate locations with SUCCESS and SKIPPED status
    And match response.locations[?(@.status=='SUCCESS')].code contains ['LOC-1', 'LOC-6']
    And match response.locations[?(@.status=='SKIPPED')].code contains ['LOC-2', 'LOC-3', 'LOC-4', 'LOC-5', 'LOC-7', 'LOC-8']

    # Validate institutions with SUCCESS and SKIPPED status
    And match response['location-units'].institutions[?(@.status=='SUCCESS')].code contains ['AG-001']
    And match response['location-units'].institutions[?(@.status=='SKIPPED')].code contains ['AG-002', 'AG-003', 'AG-004', 'AG-005']

    # Validate campuses with SUCCESS and SKIPPED status
    And match response['location-units'].campuses[?(@.status=='SUCCESS')].code contains ['AG-001']
    And match response['location-units'].campuses[?(@.status=='SKIPPED')].code contains ['AG-002', 'AG-003', 'AG-004', 'AG-005']

    # Validate libraries with SUCCESS and SKIPPED status
    And match response['location-units'].libraries[?(@.status=='SUCCESS')].code contains ['AG-001']
    And match response['location-units'].libraries[?(@.status=='SKIPPED')].code contains ['AG-002', 'AG-003', 'AG-004', 'AG-005']

  Scenario: Validate Error/Exception scenarios with cause/reason
    # Call refresh shadow locations API to create shadow locations, institutions, campuses and libraries
    * print 'Validate Error/Exception scenarios with cause/reason'
    # Create mock server data for shadow locations and simulate error/exception scenarios
    * karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@CreateMockServerShadowLocationsData', { agencyOneCode: '=AG-001', agencyOneName: '=Agency-One' })

    Given path '/dcb/shadow-locations/refresh'
    When method POST
    Then status 201
    # Validate locations with SKIPPED status and specific causes for LOC-1 and LOC-6
    And match response.locations[?(@.code=='LOC-1')].status == ['SKIPPED']
    And match response.locations[?(@.code=='LOC-1')].cause == ['Location agencies IDs are incomplete or null, cannot create shadow location. locationAgenciesIds are: LocationAgenciesIds[institutionId=null, campusId=null, libraryId=null]']
    And match response.locations[?(@.code=='LOC-6')].status == ['SKIPPED']
    And match response.locations[?(@.code=='LOC-6')].cause == ['Location agencies IDs are incomplete or null, cannot create shadow location. locationAgenciesIds are: LocationAgenciesIds[institutionId=null, campusId=null, libraryId=null]']

    # Validate other locations with SKIPPED status
    And match response.locations[?(@.code=='LOC-2' || @.code=='LOC-3' || @.code=='LOC-4' || @.code=='LOC-5' || @.code=='LOC-7' || @.code=='LOC-8')].status == ['SUCCESS', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'SUCCESS']

    # Validate institution with ERROR status and cause
    And match response['location-units'].institutions[?(@.code=='=AG-001')].status == ['ERROR']
    And match response['location-units'].institutions[?(@.code=='=AG-001')].cause != null
    And match response['location-units'].institutions[?(@.code=='=AG-001')].cause == '#present'

    # Validate other institutions with SKIPPED status
    And match response['location-units'].institutions[?(@.code=='AG-002' || @.code=='AG-003' || @.code=='AG-004' || @.code=='AG-005')].status == ['SUCCESS', 'SUCCESS', 'SUCCESS', 'SUCCESS']

    # Validate campus with SKIPPED status and cause
    And match response['location-units'].campuses[?(@.code=='=AG-001')].status == ['SKIPPED']
    And match response['location-units'].campuses[?(@.code=='=AG-001')].cause == ['Institution is null and it was not created, so cannot create campus']

    # Validate other campuses with SKIPPED status
    And match response['location-units'].campuses[?(@.code=='AG-002' || @.code=='AG-003' || @.code=='AG-004' || @.code=='AG-005')].status == ['SUCCESS', 'SUCCESS', 'SUCCESS', 'SUCCESS']

    # Validate library with SKIPPED status and cause
    And match response['location-units'].libraries[?(@.code=='=AG-001')].status == ['SKIPPED']
    And match response['location-units'].libraries[?(@.code=='=AG-001')].cause == ['Campus is null and it was not created, so cannot create library']

    # Validate other libraries with SKIPPED status
    And match response['location-units'].libraries[?(@.code=='AG-002' || @.code=='AG-003' || @.code=='AG-004' || @.code=='AG-005')].status == ['SUCCESS', 'SUCCESS', 'SUCCESS', 'SUCCESS']
