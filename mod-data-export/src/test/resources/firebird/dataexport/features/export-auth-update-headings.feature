Feature: Test Data Export Spring API

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * def filePath = 'classpath:samples/'
    * def equalsCsv = 'export-auth-update-headings.feature@EqualsCsv'

  @Ignore
  @EqualsCsv
  Scenario: Equals csv results
    Given path 'data-export-spring/jobs', jobId
    And retry until response.status == 'SUCCESSFUL' || response.status == 'FAILED'
    When method GET
    Then status 200
    And match $.status == 'SUCCESSFUL'
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And assert response.files.length == 1

    Given path 'data-export-spring/jobs', jobId, 'download'
    When method GET
    Then status 200
    And def dateAndTimeRegex = '\\b(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}.\\d{3}\\w)'
    And string response = response
    And def actualCsvFile = replaceRegex(response, dateAndTimeRegex, 'replacedDate')

    And def expectedCsvFile = karate.readAsString(filePath +'csv/' + expectedFileName)

    And def csvLineSeparator = '\n'
    And def systemLineSeparator = java.lang.System.lineSeparator()
    And match expectedCsvFile.split(systemLineSeparator) == actualCsvFile.split(csvLineSeparator)
    
  @Positive
  @ExportAuthUpdateHeadings
  Scenario: UpsertJob should return job with status 201. Then get id job from response.id with status 200
    * def date = getCurrentDate()
    * def requestBody = read(filePath + 'auth_update_headings.json')
    And set requestBody.exportTypeSpecificParameters.authorityControlExportConfig.fromDate = date
    And set requestBody.exportTypeSpecificParameters.authorityControlExportConfig.toDate = date

    Given path 'data-export-spring/jobs'
    And request read(filePath + 'auth_update_headings.json')
    When method POST
    Then status 201
    And match response.type == 'AUTH_HEADINGS_UPDATES'

    * def jobId = $.id
    * call read(equalsCsv) {expectedFileName: 'authUpdateHeadersNoRecords.csv'}

  @Positive
  Scenario: Should update record without any errors
    * def testAuthorityId = 'c32a3b93-b459-4bd4-a09b-ac1f24c7b999'
    * def instanceId = '993ccbaf-903e-470c-8eca-02d3b4f8ac54'

    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    When method GET
    Then status 200

    # replace new field
    * def record = response
    * set record.relatedRecordVersion = 1

    * def field = karate.jsonPath(record, "$.fields[?(@.tag=='100')]")[0]
    * set field.content = '$a Updated'
    * remove record.fields[?(@.tag=='100')]
    * record.fields.push(field)

    # update authority record
    Given path 'records-editor/records', record.parsedRecordId
    And request record
    When method PUT
    Then status 202

    # export & check updated record
    * call read('export-auth-update-headings.feature@ExportAuthUpdateHeadings')

  @Positive
  Scenario: Test data-export-spring. Gets job list by limit of 1 items with status 200
    Given path 'data-export-spring/jobs'
    And param limit = 1

    When method GET
    Then status 200
    And assert karate.sizeOf(response.jobRecords) == 1


  @Negative
  Scenario: UpsertJob. Empty date from & to. Should fail and return job with status 400 BadRequest.
    * def requestBody = read(filePath + 'auth_update_headings.json')

    Given path 'data-export-spring/jobs'
    And set requestBody.exportTypeSpecificParameters = null
    And request requestBody
    When method POST
    Then status 400
    And assert karate.sizeOf(response.errors) > 0

  @Negative
  Scenario: UpsertJob. Wrong date format. Should fail and return job with status 400 BadRequest.
    * def requestBody = read(filePath + 'auth_update_headings.json')

    Given path 'data-export-spring/jobs'
    And set requestBody.exportTypeSpecificParameters.authorityControlExportConfig.fromDate = "2023/02/15"
    And set requestBody.exportTypeSpecificParameters.authorityControlExportConfig.toDate = "2023/02/15"
    And request requestBody
    When method POST
    Then status 400
    And assert karate.sizeOf(response.errors) > 0

  @Negative
  Scenario: UpsertJob. Empty type of job. Should fail and return job with status 400 BadRequest.
    * def requestBody = read(filePath + 'auth_update_headings.json')

    Given path 'data-export-spring/jobs'
    And set requestBody.type = null
    And request requestBody
    When method POST
    Then status 400
    And assert karate.sizeOf(response.errors) > 0