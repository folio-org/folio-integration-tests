Feature: Packages

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/export/'
    * def equalsCsv = 'export-for-e-holdings.feature@EqualsCsv'
    * def equalsError = 'export-for-e-holdings.feature@EqualsErrorMessage'

    * def packageId = karate.properties['packageId']
    * def resourceId = karate.properties['resourceId']

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
    And def fileLink = $.files[0]

    Given url fileLink
    When method GET
    Then status 200
    And def dateAndTimeRegex = '\\b(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}.\\d{3}\\w)'
    And def expectedCsvFile = read(samplesPath+'csv/'+expectedFileName)
    And def actualCsvFile = replaceRegex(response, dateAndTimeRegex, 'replacedDate')

    And def csvLineSeparator = '\n'
    And def systemLineSeparator = java.lang.System.lineSeparator()
    And match expectedCsvFile.split(systemLineSeparator) == actualCsvFile.split(csvLineSeparator)

  @Ignore
  @EqualsErrorMessage
  Scenario: Equals error message
    Given path 'data-export-spring/jobs', jobId
    And retry until response.status == 'SUCCESSFUL' || response.status == 'FAILED'
    When method GET
    Then status 200
    And match $.status == 'FAILED'
    And match $.startTime == '#present'
    And match $.endTime == '#present'
    And match $.errorDetails contains expectedErrorMessage

#   ================= Positive test cases =================

  Scenario: Export package with titles
    And def recordId = packageId
    And def recordType = 'PACKAGE'

    Given path 'data-export-spring/jobs'
    And request read(samplesPath + 'job.json')
    When method POST
    Then status 201

    * def jobId = $.id
    * call read(equalsCsv) {expectedFileName: 'packageWithTitles.csv'}

  Scenario: Export package with only selected titles
    And def recordId = packageId
    And def recordType = 'PACKAGE'
    And def filters = 'filter[selected]=true'

    Given path 'data-export-spring/jobs'
    And request read(samplesPath + 'job.json')
    When method POST
    Then status 201

    * def jobId = $.id
    * call read(equalsCsv) {expectedFileName: 'packageWithSelectedTitles.csv'}

  Scenario: Export package with titles, should ignore invalid filters
    And def recordId = packageId
    And def recordType = 'PACKAGE'
    And def filters = 'filter[invalid]=true&InvalidFilter'

    Given path 'data-export-spring/jobs'
    And request read(samplesPath + 'job.json')
    When method POST
    Then status 201

    * def jobId = $.id
    * call read(equalsCsv) {expectedFileName: 'packageWithTitles.csv'}

  Scenario: Export single package
    And def recordId = packageId
    And def recordType = 'PACKAGE'
    And def job = read(samplesPath + 'job.json')
    And set job.exportTypeSpecificParameters.eHoldingsExportConfig.titleFields = []

    Given path 'data-export-spring/jobs'
    And request job
    When method POST
    Then status 201

    * def jobId = $.id
    * call read(equalsCsv) {expectedFileName: 'singlePackage.csv'}

  Scenario: Export resource
    And def recordId = resourceId
    And def recordType = 'RESOURCE'

    Given path 'data-export-spring/jobs'
    And request read(samplesPath + 'job.json')
    When method POST
    Then status 201

    * def jobId = $.id
    * call read(equalsCsv) {expectedFileName: 'resources.csv'}


#   ================= Negative test cases =================

  Scenario: Should failed if export fields are empty
    And def recordId = resourceId
    And def recordType = 'RESOURCE'
    And def job = read(samplesPath + 'job.json')
    And set job.exportTypeSpecificParameters.eHoldingsExportConfig.packageFields = []
    And set job.exportTypeSpecificParameters.eHoldingsExportConfig.titleFields = []

    Given path 'data-export-spring/jobs'
    And request job
    When method POST
    Then status 201

    * def jobId = $.id
    * call read(equalsError) {expectedErrorMessage: 'Export fields are empty'}

  Scenario: Should failed if recordId is invalid
    And def recordId = 'wrongId'
    And def recordType = 'RESOURCE'
    And def job = read(samplesPath + 'job.json')
    And set job.exportTypeSpecificParameters.eHoldingsExportConfig.packageFields = []
    And set job.exportTypeSpecificParameters.eHoldingsExportConfig.titleFields = []

    Given path 'data-export-spring/jobs'
    And request job
    When method POST
    Then status 201

    * def jobId = $.id
    * call read(equalsError) {expectedErrorMessage: 'Package and provider id are required'}

  Scenario: Should failed if recordType is invalid
    And def recordId = packageId
    And def recordType = 'wrongType'
    And def errorMessage = 'problem: Unexpected value \'wrongType\';'

    Given path 'data-export-spring/jobs'
    And request read(samplesPath + 'job.json')
    When method POST
    Then status 400
    And match $.errors[0].message contains errorMessage
