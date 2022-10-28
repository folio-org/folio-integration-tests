Feature: bulk-edit items update tests

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
    And request itemIdentifiersJob
    * def Thread = Java.type('java.lang.Thread')
    * Thread.sleep(300000)
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id
    * def Thread = Java.type('java.lang.Thread')
    * Thread.sleep(100000)

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/item/csv/get_item_records.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '2'


    #trigger the job execution
    Given path 'bulk-edit', jobId, 'start'
    And headers applicationJsonContentType
    When method POST
    Then status 200
    * def Thread = Java.type('java.lang.Thread')
    * Thread.sleep(100000)

    #get preview
    Given url baseUrl
    And path 'bulk-edit', jobId, 'preview/items'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And def expectedPreviewItemsJson = read('classpath:samples/item/expected_items_preview_after_identifiers_job.json')
    And def expected = karate.sort(expectedPreviewItemsJson.items, x => x.barcode)
    And def actual = karate.sort(response.items, x => x.barcode)
    And match $.totalRecords == 2
    And print 'actual: ', actual
    And print 'expected: ', expected
    # compare
    And match actual[0] contains deep expected[0]
    And match actual[1] contains deep expected[1]

    #get job until status SUCCESSFUL and validate
    Given path 'data-export-spring/jobs', jobId
    And headers applicationJsonContentType
    And retry until response.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And assert response.files.length == 1
    And def fileLink = $.files[0]

    #error logs should be empty

    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And match $.total_records == 0

      #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString('classpath:samples/item/csv/expected_items_from_barcode.csv')
    * string response = response
    * def fileMatches = userUtil.compareItemsCsvFilesString(expectedCsvFile, response);
    And match fileMatches == true

#    #uplaod file
    Given url baseUrl
    And path 'bulk-edit', jobId, 'item-content-update', 'upload'
    And headers applicationJsonContentType
    And request itemContentUpdates
    When method POST
    Then status 200
    And match response.items[0].permanentLocation.name == 'Popular Reading Collection'
    And match response.items[0].effectiveLocation.name == 'Popular Reading Collection'
    And match response.items[1].permanentLocation.name == 'Popular Reading Collection'
    And match response.items[1].effectiveLocation.name == 'Popular Reading Collection'

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
    And match $.progress contains { total: 2, processed: 2, progress: 100}
    * def Thread = Java.type('java.lang.Thread')
    * Thread.sleep(100000)

    #get preview
    Given path 'bulk-edit', jobId, 'preview/items'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And def expectedPreviewItemsJson = read('classpath:samples/item/expected_items_preview_after_update.json')
    And def expected = karate.sort(expectedPreviewItemsJson.items, x => x.barcode)
    And def actual = karate.sort(response.items, x => x.barcode)
    And print 'actual: ', actual
    And print 'expected: ', expected
    And match actual[0] contains deep expected[0]
    And match actual[1] contains deep expected[1]

    #error logs should be empty
    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And assert response.total_records >= 0
      #For snapshot env consecutive runs will result the totalRecords > 0

    #verify items was updated against identifiers job and expected items data csv file
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request itemIdentifiersJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id
    * def Thread = Java.type('java.lang.Thread')
    * Thread.sleep(100000)

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/item/csv/item_to_be_updated_with_barcode.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '6'

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
    And assert response.files.length == 1
    And def fileLink = $.files[0]

    #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString('classpath:samples/item/csv/expected_item_records_after_update.csv')
    * string response = response
    And print 'expected ', expectedCsvFile
    And print 'response ', response
    * def fileMatches = userUtil.compareItemsCsvFilesString(expectedCsvFile, response);
    And match fileMatches == true


#    # NEGATIVE SCENARIOS

  Scenario: test bulk-edit job type BULK_EDIT_IDENTIFIERS with errors
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request itemIdentifiersJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id
    * def Thread = Java.type('java.lang.Thread')
    * Thread.sleep(100000)

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/item/csv/invalid_item_identifiers.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '2'

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
    And assert response.files.length == 2
    And def fileLink = $.files[1]

    #verfiy downloaded file
    Given url fileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString('classpath:samples/item/csv/invalid_identifiers_expected_errors.csv')
    * string response = response
    And print 'response: ', response
    And print 'expected: ', expectedCsvFile
    And def fileMatches = userUtil.compareErrorsCsvFiles(expectedCsvFile, response);
    And match fileMatches == true

    #get preview
    Given url baseUrl
    And path 'bulk-edit', jobId, 'preview/items'
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
    And def expectedErrorsJson = read('classpath:samples/item/invalid_identifiers_expected_errors.json')
    And match $.total_records == 2
    And match $.errors contains deep expectedErrorsJson.errors[0]

  Scenario: test bulk-edit item update job (type BULK_EDIT_UPDATE) invalid UUID in a file
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request itemUpdateJobID
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/item/csv/invalid_item_uuid.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '2'

    #trigger the job execution
    Given path 'bulk-edit', jobId, 'start'
    And headers applicationJsonContentType
    When method POST
    Then status 200
#
    #get job until status SUCCESSFUL and validate
    Given path 'data-export-spring/jobs', jobId
    And headers applicationJsonContentType
    And retry until response.status == 'SUCCESSFUL'
    When method GET
    Then status 200
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And match $.progress contains { total: 2, processed: 2, progress: 100}
    And assert response.files.length == 2
    And def errorsFileLink = $.files[1]

    #verify errors file
    Given url errorsFileLink
    When method GET
    Then status 200
    And def expectedCsvFile = karate.readAsString('classpath:samples/item/csv/invalid_item_uuid_expected_errors.csv')
    * string response = response
    And print 'expected: ', expectedCsvFile
    And print 'response: ', response
    And def fileMatches = userUtil.compareErrorsCsvFiles(expectedCsvFile, response);
    And match fileMatches == true

    #get errors should return invalid UUID error
    Given url baseUrl
    And path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And def expectedErrorsJson = read('classpath:samples/item/invalid_uuid_upload_job_errors.json')
    And match $.total_records == 2
    And match $.errors contains deep expectedErrorsJson.errors[0]

  Scenario: test bulk-edit item update job (type BULK_EDIT_UPDATE) incorrect number of tokens
    #create bulk-edit job
    Given path 'data-export-spring/jobs'
    And headers applicationJsonContentType
    And request itemUpdateJob
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/item/csv/invalid_item_incorrect_number_of_tokens.csv', contentType: 'text/csv' }
    And headers multipartFromDataContentType
    When method POST
    Then status 200
    And string responseMessage = response
    And match responseMessage == '2'

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
    And match $.errorDetails == 'Incorrect number of tokens found in record: expected 48 actual 8 (IncorrectTokenCountException)'

    #verify empty errors response since the error was populated within the job field
    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    When method GET
    Then status 200
    And match $.total_records == 0