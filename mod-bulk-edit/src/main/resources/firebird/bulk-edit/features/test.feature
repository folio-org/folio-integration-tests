Feature: bulk-edit users update tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenAdmin = okapitoken
    * configure retry = { interval: 10000, count: 5 }
    * configure headers = { 'Accept': '*/*', 'x-okapi-token': '#(okapitokenAdmin)', 'x-okapi-tenant': '#(testUser.tenant)' }
    * def applicationJsonContentType = { 'Content-Type': 'application/json' }
    * def multipartFromDataContentType = { 'Content-Type': 'multipart/form-data' }
    * def UserUtil = Java.type('org.folio.util.UserUtil')
    * def userUtil = new UserUtil();
    * callonce loadVariables

  Scenario: test bulk-edit user update job (type BULK_EDIT_UPDATE) incorrect number of tokens
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request userUpdateJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/user/csv/invalid-user-records-incorrect-number-of-tokens.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '1'

    #trigger the job execution
    Given path 'bulk-edit', jobId, 'start'
    And headers applicationJsonContentType
    When method POST
    Then status 200

    #get job until status SUCCESSFUL and validate
    Given path 'data-export-spring/jobs', jobId
    And headers applicationJsonContentType
    And retry until response.status == 'FAILED'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And match $.errorDetails == 'Incorrect number of tokens found in record: expected 25 actual 33 (IncorrectTokenCountException)'

    #verify preview is absent
    Given path 'bulk-edit', jobId, 'preview'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And match $.totalRecords == 0