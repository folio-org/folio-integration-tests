Feature: Test Data Export Spring API

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * def requestBodyOnSuccess = read('classpath:firebird/dataexportspring/payload/req_update_on_success.json')
    * def requestBodyOnFailure = read('classpath:firebird/dataexportspring/payload/req_update_on_failure.json')


  @Positive
  Scenario: UpsertJob should return job with status 201. Then get id job from response.id with status 200
    Given path 'data-export-spring/jobs'
    And request requestBodyOnSuccess
    When method POST
    Then status 201
    And match response.name == 'AUTHORITY_UPDATE_HEADING'

    Given path 'data-export-spring/jobs/'+ response.id
    When method GET
    Then status 200
    Then print response
    And match  response.name contains 'AUTHORITY_UPDATE_HEADING'


  @Negative
  Scenario: UpsertJob should fail and return job with status 400 BadRequest.
    Given path 'data-export-spring/jobs'
    And request requestBodyOnFailure
    When method POST
    Then status 400


  @Positive
  Scenario: Test data-export-spring, Gets job list with status 200
    Given path 'data-export-spring/jobs'
    When method GET
    Then status 200