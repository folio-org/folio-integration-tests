Feature: Claims export with CSV and EDI for both FTP and SFTP uploads

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * def verifyFileContentCsv = read('@VerifyFileContentCsv')
    * def verifyFileContentEdi = read('@VerifyFileContentEdi')
    * def initData = read('util/export-claims/initData.feature')
    * def convertStringToLines = function (file, sep) { return file.split(sep).filter(i => i.trim().length != 0); }
    * def getJobsByType = read('util/initData.feature@GetDataExportSpringJobsByType')
    * def jobSortKeyExporter = function(job) { return job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.configName; }
    * def jobFilter =
      """
      function(configIds, job) {
        const jobConfigId = job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId;
        return job.status = "SUCCESS" && configIds.includes(jobConfigId);
      }
      """

    # Replace these 2 lines to remove date and time constraints, but match with file ids
    * def interchangeHeaderRegexTemplte = "UNB\\+UNOC:3\\+LIB-EDI-CODE:31B\\+VENDOR-EDI-CODE:31B\\+\\d{6}:\\d{4}\\+{fileId}'"
    * def interchangeHeaderSampleTemplate = "UNB+UNOC:3+LIB-EDI-CODE:31B+VENDOR-EDI-CODE:31B+150125:1249+{fileId}'"
    * def orderDateRegex = "DTM\\+137:\\d{8}:102'"
    * def orderDateSample = "DTM+137:20250115:102'"

    ### Before All ###
    # Set up fund and budget
    * def fundId = callonce uuid
    * def budgetId = callonce uuid1
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }


  Scenario: Export CLAIMS as CSV to FTP and SFTP
    # 1. Initialize data with 2 organizations with CSV configs
    * def orgId1 = call uuid
    * def orgId2 = call uuid
    * def configId1 = call uuid
    * def configId2 = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid

    * table testData
      | orgId  | orgCode | accountNo | configId  | configName | transMeth | fileFormat | ftpFormat | poNumber | poLineNumber | pieceId  | fundId |
      | orgId1 | "ORG1"  | "ACC1"    | configId1 | "CSV1"     | "FTP"     | "CSV"      | "FTP"     | "11111"  | "11111-1"    | pieceId1 | fundId |
      | orgId2 | "ORG2"  | "ACC2"    | configId2 | "CSV2"     | "FTP"     | "CSV"      | "SFTP"    | "22222"  | "22222-1"    | pieceId2 | fundId |
    * def v = call initData testData

    # 2. Send Claims for piece 1 and 2
    * def v = call claimPieces { claimingPieceIds: "#([pieceId1, pieceId2])", claimingInterval: 1 }=
    * call pause 10000

    # 3. Verify that 2 jobs are created for org 1 and 2 and completed successfully and check file contents
    * def jobs = call getJobsByType { exportType: 'CLAIMS' }
    * def configIds = ['#(configId1)', '#(configId2)']
    * def filteredJobsUnsorted = karate.filter(jobs.response.jobRecords, function(job) { return jobFilter(configIds, job); })
    * def filteredJobs = karate.sort(filteredJobsUnsorted, jobSortKeyExporter)
    * table jobDetails
      | jobId             | _poLineNumber |
      | filteredJobs[0].id | "11111-1"     |
      | filteredJobs[1].id | "22222-1"     |
    * def v = call verifyExportJobFile jobDetails
    * def v = call verifyFileContentCsv jobDetails


  Scenario: Export CLAIMS as EDI to FTP and SFTP
    # 1. Initialize data with 2 organizations with EDI configs
    * def orgId3 = call uuid
    * def orgId4 = call uuid
    * def configId3 = call uuid
    * def configId4 = call uuid
    * def pieceId3 = call uuid
    * def pieceId4 = call uuid

    * table testData
      | orgId  | orgCode | accountNo | configId  | configName | transMeth | fileFormat | ftpFormat | poNumber | poLineNumber | pieceId  | fundId |
      | orgId3 | "ORG3"  | "ACC3"    | configId3 | "EDI3"     | "FTP"     | "EDI"      | "FTP"     | "33333"  | "33333-1"    | pieceId3 | fundId |
      | orgId4 | "ORG4"  | "ACC4"    | configId4 | "EDI4"     | "FTP"     | "EDI"      | "SFTP"    | "44444"  | "44444-1"    | pieceId4 | fundId |
    * def v = call initData testData

    # 2. Send Claims for piece 3 and 4
    * def v = call claimPieces { claimingPieceIds: "#([pieceId3, pieceId4])", claimingInterval: 1 }
    * call pause 10000

    # 3. Verify that 2 jobs are created for org 3 and 4 and completed successfully and check file contents
    * def jobs = call getJobsByType { exportType: 'CLAIMS' }
    * def configIds = ['#(configId3)', '#(configId4)']
    * def filteredJobsUnsorted = karate.filter(jobs.response.jobRecords, function(job) { return jobFilter(configIds, job); })
    * def filteredJobs = karate.sort(filteredJobsUnsorted, jobSortKeyExporter)
    * table jobDetails
      | jobId             | _jobName             | _poNumber | _poLineNumber |
      | filteredJobs[0].id | filteredJobs[0].name | "33333"   | "33333-1"     |
      | filteredJobs[1].id | filteredJobs[1].name | "44444"   | "44444-1"     |
    * def v = call verifyExportJobFile jobDetails
    * def v = call verifyFileContentEdi jobDetails


  @ignore @VerifyFileContentCsv
  Scenario: verifyFileContentCsv
    # parameters: jobId, _poLineNumber

    * def fileLineSeparator = '\n'
    * def systemLineSeparator = java.lang.System.lineSeparator()
    * table replacements
      | regex            | newString     |
      | '{poLineNumber}' | _poLineNumber |
    * def expectedCsvFile = karate.readAsString('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/claims.csv')
    * def expectedCsv = replaceRegex(expectedCsvFile, replacements)
    * def expectedCsv = convertStringToLines(expectedCsv, systemLineSeparator)

    Given path 'data-export-spring/jobs', jobId, 'download'
    When method GET
    Then status 200
    And string actualCsvFile = response
    * def actualCsv = replaceRegex(actualCsvFile, replacements)
    * def actualCsv = convertStringToLines(actualCsv, fileLineSeparator)
    * match expectedCsv == actualCsv


  @ignore @VerifyFileContentEdi
  Scenario: verifyFileContentEdi
    # parameters: jobId, _jobName, _poNumber, _poLineNumber

    * def fileLineSeparator = '\n'
    * def systemLineSeparator = java.lang.System.lineSeparator()

    # Get correct regex pattern and sample for interchange header with actual file id (job name)
    * table interchangeReplacements
      | regex                  | newString               |
      | '{fileId}'             | _jobName                |
    * def interchangeHeaderRegex = replaceRegex(interchangeHeaderRegexTemplte, interchangeReplacements)
    * def interchangeHeaderSample = replaceRegex(interchangeHeaderSampleTemplate, interchangeReplacements)
    * table replacements
      | regex                  | newString               |
      | '{fileId}'             | _jobName                |
      | '{poNumber}'           | _poNumber               |
      | '{poLineNumber}'       | _poLineNumber           |
      | interchangeHeaderRegex | interchangeHeaderSample |
      | orderDateRegex         | orderDateSample         |
    * def expectedEdiFile = karate.readAsString('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/claims.edi')
    * def expectedEdi = replaceRegex(expectedEdiFile, replacements)
    * def expectedEdi = convertStringToLines(expectedEdi, systemLineSeparator)

    Given path 'data-export-spring/jobs', jobId, 'download'
    When method GET
    Then status 200
    And string actualEdiFile = response
    * def actualEdi = replaceRegex(actualEdiFile, replacements)
    * def actualEdi = convertStringToLines(actualEdi, fileLineSeparator)
    * match expectedEdi == actualEdi