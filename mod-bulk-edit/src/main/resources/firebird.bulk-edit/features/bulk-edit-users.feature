Feature: bulk-edit users update tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * configure multipartHeaders = { 'Content-Type': 'application/json', }
    * callonce loadVariables

  # POSITIVE SCENARIOS

  Scenario: test bulk-edit job type BULK_EDIT_IDENTIFIERS
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And request userIdentifiersJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file userBarcodesCsvFile = { read: 'classpath:samples/user/csv/users-barcodes.csv', filename: 'users-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    And string responseMessage = response
    #uncomment after JIRA + edit users-barcodes.csv file by removing duplicated barcode "11111" at 2 line
    #And match responseMessage == '3'
    And match responseMessage == '4'

    #get job until status SUCCESSFUL and validate
    Given path data-export-spring/jobs', jobId
    And retry until $.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present
    #should be uncommented after JIRA
    #And match $.files.length == 1, errors file should be absent
    And def fileLink = $.files[0]

    #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = read('classpath:samples/user/csv/expected-user-records.csv')
    And match response == expectedCsvFile

    #get preview
    Given url baseUrl
    And path 'bulk-edit', jobId, 'preview'
    And param limit = 10
    When method GET
    Then status 200
    And def expectedPreviewUsersJson = read('classpath:samples/user/expected-users-preview-after-identifiers-job.json')
    And match $.users contains expectedPreviewUsersJson.users[0]
    And match $.users contains expectedPreviewUsersJson.users[1]
    And match $.users contains expectedPreviewUsersJson.users[2]

    #error logs should be empty (uncomment after JIRA)
#    Given path 'bulk-edit', jobId, 'errors'
#    And param limit = 10
#    When method GET
#    Then status 200
#    And match $.errors.totalRecords == 0

  Scenario: test bulk-edit user update job with type BULK_EDIT_UPDATE
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And request userUpdateJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file editedCsvFile = { read: 'classpath:samples/user/csv/edited-user-records.csv', filename: 'edited-user-records.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '3'

    #trigger the job execution
    Given path 'bulk-edit', jobId, 'start'
    When method POST
    Then status 200

    #get job until status SUCCESSFUL and validate
    Given path data-export-spring/jobs', jobId
    And retry until $.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present
    And match $.progress == '{ total: 3, processed: 3, progress: 100}'

    #get preview
    Given path 'bulk-edit', jobId, 'preview'
    And param limit = 10
    When method GET
    Then status 200
    And def expectedPreviewUsersJson = read('classpath:samples/user/expected-users-preview-after-update-job.json')
    And match $.users contains expectedPreviewUsersJson.users[0]
    And match $.users contains expectedPreviewUsersJson.users[1]
    And match $.users contains expectedPreviewUsersJson.users[2]

    #error logs should be empty  uncomment after JIRA
#    Given path 'bulk-edit', jobId, 'errors'
#    And param limit = 10
#    When method GET
#    Then status 200
#    And match $.errors.totalRecords == 0

    #roll back users for further test usage
    * call rollBackUsersData

    # NEGATIVE SCENARIOS

  Scenario: test bulk-edit job type BULK_EDIT_IDENTIFIERS with errors
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And request userIdentifiersJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file userBarcodesCsvFile = { read: 'classpath:samples/user/csv/invalid-user-barcodes.csv', filename: 'invalid-user-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '2'

    #get job until status SUCCESSFUL and validate
    Given path data-export-spring/jobs', jobId
    And retry until $.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present
    And match $.files.length == 2
    And def fileLink = $.files[1]

    #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = read('classpath:samples/user/csv/invalid-barcodes-expected-errors-file.csv')
    And match response == expectedCsvFile

    #get preview
    Given url baseUrl
    And path 'bulk-edit', jobId, 'preview'
    And param limit = 10
    When method GET
    Then status 200
    And match $.totalRecords == 0

    #get errors (uncomment after JIRA)
#    Given url baseUrl
#    And path 'bulk-edit', jobId, 'errors'
#    And param limit = 10
#    When method GET
#    Then status 200
#    And match $.totalRecords == 2

  Scenario: test bulk-edit user update job (type BULK_EDIT_UPDATE) invalid UUID in a file
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And request userUpdateJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file editedCsvFile = { read: 'classpath:samples/user/csv/invalid-user-records-invalid-uuid.csv', filename: 'invalid-user-records-invalid-uuid.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '1'

    #trigger the job execution
    Given path 'bulk-edit', jobId, 'start'
    When method POST
    Then status 200

    #get job until status SUCCESSFUL and validate
    Given path data-export-spring/jobs', jobId
    And retry until $.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present
    And match $.progress == '{ total: 1, processed: 1, progress: 100}'
    And def errorsFileLink = $.files[1]

    #verify errors file
    Given url errorsFileLink
    When method GET
    Then status 200
    And def expectedCsvFile = read('classpath:samples/user/csv/errors-invalid-user-records-invalid-uuid.csv')
    And match response == expectedCsvFile

    #verify preview is empty
    Given path 'bulk-edit', jobId, 'preview'
    And param limit = 10
    When method GET
    Then status 200
    And match $.totalRecords == 0

#    #error logs should be empty  uncomment after JIRA
#    Given path 'bulk-edit', jobId, 'errors'
#    And param limit = 10
#    When method GET
#    Then status 200
#    And match $.errors.totalRecords == 0

  Scenario: test bulk-edit user update job (type BULK_EDIT_UPDATE) incorrect number of tokens
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And request userUpdateJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file editedCsvFile = { read: 'classpath:samples/user/csv/invalid-user-records-incorrect-number-of-tokens.csv', filename: 'invalid-user-records-incorrect-number-of-tokens.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '1'

    #trigger the job execution
    Given path 'bulk-edit', jobId, 'start'
    When method POST
    Then status 200

    #get job until status SUCCESSFUL and validate
    Given path data-export-spring/jobs', jobId
    And retry until $.status == 'FAILED'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present
    And match $.errorDetails == 'Incorrect number of tokens found in record: expected 25 actual 33 (IncorrectTokenCountException)'

    #verify preview is absent
    Given path 'bulk-edit', jobId, 'preview'
    And param limit = 10
    When method GET
    Then status 200
    And match $.totalRecords == 0

#    #verify errors presented
#    Given path 'bulk-edit', jobId, 'preview'
#    And param limit = 10
#    When method GET
#    Then status 200
#    And match $.totalRecords == 1

