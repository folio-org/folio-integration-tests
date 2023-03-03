Feature: bulk-edit users update tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenAdmin = okapitoken
    * configure retry = { interval: 5000, count: 5 }
    * configure headers = { 'Accept': '*/*', 'x-okapi-token': '#(okapitokenAdmin)', 'x-okapi-tenant': '#(testUser.tenant)' }
    * def applicationJsonContentType = { 'Content-Type': 'application/json' }
    * def multipartFromDataContentType = { 'Content-Type': 'multipart/form-data' }
    * def UserUtil = Java.type('org.folio.util.UserUtil')
    * def userUtil = new UserUtil();
    * callonce loadVariables

  # POSITIVE SCENARIOS

  Scenario: test bulk-edit job type BULK_EDIT_IDENTIFIERS
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request userIdentifiersJob

    * pause(8000)

    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    * pause(8000)

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/user/csv/barcodes/users-barcodes.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '3'

    #get job until status SUCCESSFUL and validate
    Given path 'data-export-spring/jobs', jobId
    And headers applicationJsonContentType
    And retry until response.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And assert response.files.length == 3
    And def fileLink = $.files[0]

    #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString('classpath:samples/user/csv/expected-user-records-identifiers-job.csv')
    * string response = response
    And print 'obtained response: ', response
    * def fileMatches = userUtil.compareUsersCsvFilesString(expectedCsvFile, response);
    And match fileMatches == true

    #get preview
    Given url baseUrl
    And path 'bulk-edit', jobId, 'preview/users'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And def expectedPreviewUsersJson = read('classpath:samples/user/expected-users-preview-after-identifiers-job.json')
    And match $.totalRecords == 3
    And print 'obtained users: ', response.users
    And match $.users contains deep expectedPreviewUsersJson.users[0]
    And match $.users contains deep expectedPreviewUsersJson.users[1]
    And match $.users contains deep expectedPreviewUsersJson.users[2]

    #error logs should be empty
    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And match $.total_records == 0

  Scenario: test bulk-edit user update job with type BULK_EDIT_UPDATE
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request userUpdateJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    * pause(8000)

    #uplaod file
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/user/csv/edited-user-records.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '3'

    #trigger the job execution
    Given path 'bulk-edit', jobId, 'start'
    And headers applicationJsonContentType
    When method POST
    Then status 200

    #get job until status SUCCESSFUL and validate
    Given path 'data-export-spring/jobs', jobId
    And headers applicationJsonContentType
    And retry until response.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And match $.progress contains { total: 3, processed: 3, progress: 100}

    #get preview
    Given path 'bulk-edit', jobId, 'preview/users'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And def expectedPreviewUsersJson = read('classpath:samples/user/expected-users-preview-after-update-job.json')
    And print 'obtained users: ', response.users
    And match $.users contains deep expectedPreviewUsersJson.users[0]
    And match $.users contains deep expectedPreviewUsersJson.users[1]
    And match $.users contains deep expectedPreviewUsersJson.users[2]

    #error logs should be empty
    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And match $.total_records == 0

    #verify users was updated against identifiers job and expected users data csv file
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request userIdentifiersJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    * pause(8000)

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/user/csv/barcodes/updated-users-barcodes.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '3'

    #get job until status SUCCESSFUL and validate
    Given path 'data-export-spring/jobs', jobId
    And headers applicationJsonContentType
    And retry until response.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And assert response.files.length == 3
    And def fileLink = $.files[0]

    #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString('classpath:samples/user/csv/expected-updated-user-records-after-update-job.csv')
    * string response = response
    And print 'obtained response: ', response
    * def fileMatches = userUtil.compareUsersCsvFilesString(expectedCsvFile, response);
    And match fileMatches == true

    #roll back users for further test usage
    Scenario: roll back users
      * call rollBackUsersData

    # NEGATIVE SCENARIOS

  Scenario: test bulk-edit job type BULK_EDIT_IDENTIFIERS with errors
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request userIdentifiersJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    * pause(8000)

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/user/csv/barcodes/invalid-user-barcodes.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '2'

    #get job until status SUCCESSFUL and validate
    Given path 'data-export-spring/jobs', jobId
    And headers applicationJsonContentType
    And retry until response.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And assert response.files.length == 2
    And def fileLink = $.files[1]

    #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString('classpath:samples/user/csv/invalid-barcodes-expected-errors-file.csv')
    * string response = response
    And print 'obtained response: ', response
    And def fileMatches = userUtil.compareErrorsCsvFiles(expectedCsvFile, response);
    And match fileMatches == true

    #get preview
    Given url baseUrl
    And path 'bulk-edit', jobId, 'preview/users'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And match $.totalRecords == 0

    #get errors should return barcodes not found errors
    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And def expectedErrorsJson = read('classpath:samples/user/errors/invalid-identifiers-expected-errors.json')
    And match $.total_records == 2
    And print 'obtained errors: ', response.errors
    And match $.errors contains deep expectedErrorsJson.errors[0]
    And match $.errors contains deep expectedErrorsJson.errors[1]

  Scenario: test bulk-edit user update job (type BULK_EDIT_UPDATE) invalid UUID in a file
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
    And multipart file file = { read: 'classpath:samples/user/csv/invalid-user-records-invalid-uuid.csv', contentType: 'text/csv' }
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
    And retry until response.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And match $.progress contains { total: 1, processed: 1, progress: 100}
    And assert response.files.length == 2
    And def errorsFileLink = $.files[1]

    #verify errors file
    Given url errorsFileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString('classpath:samples/user/csv/errors-invalid-user-records-invalid-uuid.csv')
    * string response = response
    And print 'obtained response: ', response
    And def fileMatches = userUtil.compareErrorsCsvFiles(expectedCsvFile, response);
    And match fileMatches == true

    #verify preview is empty
    Given url baseUrl
    And path 'bulk-edit', jobId, 'preview/users'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And match $.totalRecords == 0

    #get errors should return invalid UUID error
    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And def expectedErrorsJson = read('classpath:samples/user/errors/invalid-uuid-upload-job-errors.json')
    And print 'obtained errors: ', response.errors
    And match $.total_records == 1
    And match $.errors contains deep expectedErrorsJson.errors[0]

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
    Given path 'bulk-edit', jobId, 'preview/users'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And match $.totalRecords == 0

    #verify empty errors response since the error was populated within the job field
    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    When method GET
    Then status 200
    And match $.total_records == 0