Feature: Test Data Export Spring API

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * def requestBodyOnSuccess = read('classpath:samples/auth_update_headings_success.json')
    * def requestBodyOnFailure = read('classpath:samples/auth_update_headings_failure.json')


  @Positive
  Scenario: UpsertJob should return job with status 201. Then get id job from response.id with status 200
    Given path 'data-export-spring/jobs'
    And request requestBodyOnSuccess
    When method POST
    Then status 201
    And match response.type == 'AUTH_HEADINGS_UPDATES'

    * def jobId = response.id

    Given path 'data-export-spring/jobs', jobId
    And retry until response.status == 'SUCCESSFUL' || response.status == 'FAILED'
    When method GET
    Then status 200
    And match $.status == 'SUCCESSFUL'
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And assert response.files.length == 1
    And print "++++++:"
    And print response
    And print "++++++:"
    And print response.files

    Given path 'data-export-spring/jobs', jobId, 'download'
    When method GET
    Then status 200

    
  @Negative
  Scenario: UpsertJob should fail and return job with status 400 BadRequest.
    Given path 'data-export-spring/jobs'
    And request requestBodyOnFailure
    When method POST
    Then status 400
    And assert response.errors[0].code == '400 BAD_REQUEST'


  @Positive
  Scenario: Test data-export-spring. Gets job list by limit of 1 items with status 200
    Given path 'data-export-spring/jobs'
    And param limit = 1

    When method GET
    Then status 200
    And assert karate.sizeOf(response.jobRecords) == 1