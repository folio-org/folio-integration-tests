Feature: bulk-edit items update status tests

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
    When method POST
    Then status 201
    And match $.status == 'SCHEDULED'
    And def jobId = $.id

    #uplaod file and trigger the job automatically
    Given path 'bulk-edit', jobId, 'upload'
    And multipart file file = { read: 'classpath:samples/item/csv/get_item_status_records.csv', contentType: 'text/csv' }
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

    #post content update
    Given path 'bulk-edit', jobId, 'items-content-update/upload'
    And headers applicationJsonContentType
    And def itemStatusUpdate = read('classpath:samples/item/json/item_status_content_update.json')
    And request itemStatusUpdate
    When method POST
    Then status 200
    And karate.log("item status response",response)

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

        #get preview
    Given url baseUrl
    And path 'bulk-edit', jobId, 'preview/items'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And def expectedPreviewItemsJson = read('classpath:samples/item/json/expected_items_status_preview_after_update.json')
    And match $.totalRecords == 2
    And match $.items[0] contains deep expectedPreviewItemsJson.items[0]
    And match $.items[1] contains deep expectedPreviewItemsJson.items[1]

    #error logs should be empty
    Given path 'bulk-edit', jobId, 'errors'
    And param limit = 10
    And headers applicationJsonContentType
    When method GET
    Then status 200
    And match $.total_records == 0

