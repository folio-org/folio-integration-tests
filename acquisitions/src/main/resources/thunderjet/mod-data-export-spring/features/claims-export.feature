Feature: Claims export with CSV and EDI for both FTP and SFTP uploads

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * def initData = read('util/export-claims/exportClaimUtils.feature@InitData')
    * def verifyFileContentCsv = read('util/export-claims/exportClaimUtils.feature@VerifyFileContentCsv')
    * def verifyFileContentEdi = read('util/export-claims/exportClaimUtils.feature@VerifyFileContentEdi')
    * def createPiecesForPoLine = read('util/export-claims/exportClaimUtils.feature@CreatePiecesForPoLine')
    * def getJobsByType = read('util/initData.feature@GetDataExportSpringJobsByType')

    * def convertStringToLines = function (file, sep) { return file.split(sep).filter(i => i.trim().length != 0); }
    * def jobSortKeyExporter = function(job) { return job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.configName; }
    * def uniqueJobFilter =
      """
      function(jobs, configIds) {
        var seen = {};
        return karate.filter(jobs, function(job) {
          if (configIds.indexOf(job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.id) >= 0) {
            if (!seen[job.id]) {
              seen[job.id] = true;
              return true;
            }
          }
          return false;
        });
      }
      """


    ### Before All ###
    # Set up fund and budget
    * def fundId = callonce uuid
    * def budgetId = callonce uuid1
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }


  @Positive
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
    * def v = call claimPieces { claimingPieceIds: "#([pieceId1, pieceId2])", claimingInterval: 1 }
    * call pause 10000

    # 3. Verify that 2 jobs are created for org 1 and 2 and completed successfully and check file contents
    * def jobs = call getJobsByType { exportType: 'CLAIMS' }
    * def configIds = ['#(configId1)', '#(configId2)']
    * def filteredJobsUnsorted = uniqueJobFilter(jobs.response.jobRecords, configIds)
    * def filteredJobs = karate.sort(filteredJobsUnsorted, jobSortKeyExporter)
    * table jobDetails
      | jobId              | _poLineNumber |
      | filteredJobs[0].id | "11111-1"     |
      | filteredJobs[1].id | "22222-1"     |
    * def v = call verifyExportJobFile jobDetails
    * def v = call verifyFileContentCsv jobDetails


    #4. Resend file from Minio to (S)FTP and verify job success
    * def v = call resendExportJobFile jobDetails
    * call pause 10000
    * def v = call verifyExportJobFile jobDetails


  @Positive
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
    * def filteredJobsUnsorted = uniqueJobFilter(jobs.response.jobRecords, configIds)
    * def filteredJobs = karate.sort(filteredJobsUnsorted, jobSortKeyExporter)
    * table jobDetails
      | jobId              | _jobName             | _poNumber | _poLineNumber |
      | filteredJobs[0].id | filteredJobs[0].name | "33333"   | "33333-1"     |
      | filteredJobs[1].id | filteredJobs[1].name | "44444"   | "44444-1"     |
    * def v = call verifyExportJobFile jobDetails
    * def v = call verifyFileContentEdi jobDetails

    #4. Resend file from Minio to (S)FTP and verify job success
    * def v = call resendExportJobFile jobDetails
    * call pause 10000
    * def v = call verifyExportJobFile jobDetails


  @Negative
  Scenario: Claiming pieces with no export config should not create any jobs
    # 1. Initialize data with 1 organization
    * def orgId = call uuid
    * def configId = call uuid
    * def pieceId = call uuid

    * table testData
      | orgId | orgCode   | accountNo | configId | configName | transMeth | fileFormat | ftpFormat | poNumber | poLineNumber | pieceId | fundId |
      | orgId | "ORG_NEG" | "ACC_NEG" | configId | "NEG"      | "FTP"     | "CSV"      | "FTP"     | "55555"  | "55555-1"    | pieceId | fundId |
    * def v = call initData testData

    # 2. Delete export config
    Given path 'data-export-spring/configs', configId
    When method DELETE
    Then status 204

    # 3. Send Claims for piece and verify error response
    Given path 'pieces/claim'
    And request { claimingPieceIds: "#([pieceId])", claimingInterval: 1 }
    When method POST
    Then status 422
    And match response.total_records == 1
    And match response.errors[0].code == 'unableToGenerateClaimsForOrgNoIntegrationDetails'


  @Positive
  Scenario: Export CLAIMS for 500 pieces as CSV and EDI
    # 1. Initialize data with 2 organizations with CSV and EDI configs
    * def orgId1 = call uuid
    * def orgId2 = call uuid
    * def configId1 = call uuid
    * def configId2 = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid

    * table testData
      | orgId  | orgCode    | accountNo  | configId  | configName | transMeth       | fileFormat | ftpFormat | poNumber | poLineNumber | pieceId  | fundId |
      | orgId1 | "ORG1_500" | "ACC1_500" | configId1 | "CSV1_500" | "File download" | "CSV"      | "FTP"     | "11250"  | "11250-1"    | pieceId1 | fundId |
      | orgId2 | "ORG2_500" | "ACC2_500" | configId2 | "EDI1_500" | "File download" | "EDI"      | "FTP"     | "22250"  | "22250-1"    | pieceId2 | fundId |
    * def v = call initData testData

    # 2. Create additional 249 pieces for each organization
    * def pieceIds1 = call uuids 249
    * def pieceIds2 = call uuids 249
    * table createPieceData
      | _poLineNumber | _pieceIds |
      | "11250-1"     | pieceIds1 |
      | "22250-1"     | pieceIds2 |
    * def v = call createPiecesForPoLine createPieceData

    # 3. Send Claims for piece
    * pieceIds1.push(pieceId1)
    * pieceIds2.push(pieceId2)
    * table claimPiecesData
      | claimingPieceIds | claimingInterval |
      | pieceIds1        | 1                |
      | pieceIds2        | 1                |
    * def v = call claimPieces claimPiecesData
    * call pause 60000

    # 4. Verify that 2 jobs are created for org 1 and 2 and completed successfully
    * def jobs = call getJobsByType { exportType: 'CLAIMS' }
    * def configIds = ['#(configId1)', '#(configId2)']
    * def filteredJobsUnsorted = uniqueJobFilter(jobs.response.jobRecords, configIds)
    * def filteredJobs = karate.sort(filteredJobsUnsorted, jobSortKeyExporter)
    * table jobDetails
      | jobId              |
      | filteredJobs[0].id |
      | filteredJobs[1].id |
    * def v = call verifyExportJobFile jobDetails