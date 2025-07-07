Feature: data-import-large-scale-tests create-electronic-only-match integration tests

  Background:
    * url baseUrl
    * configure retry = { interval: 5000, count: 30 }

    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }
    * configure headers = headersUser

    * def defaultCreateInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'
    * def recordFilesDir = 'classpath:folijet/data-import-large-scale-tests/samples/records/marc/'
    * def importFile = read('classpath:folijet/data-import-large-scale-tests/global/import-file.feature')
    * def getJobLogEntriesByJobId = read('classpath:folijet/data-import-large-scale-tests/global/data-import-logs.feature@getJobLogEntriesByJobId')

  Scenario: FAT-20172 Create Electronic only match
    * print 'FAT-20172-create-electronic-only-match.feature'

    * def updateProfileSnapshot = read('classpath:folijet/data-import-large-scale-tests/samples/profiles/FAT-20172-create-electronic-only-match.json')
    Given path 'data-import-profiles/profileSnapshots'
    And request updateProfileSnapshot
    When method POST
    Then status 201
    * def importedProfileName = $.content.name

    #Find the imported Job Profile by name
    Given path 'data-import-profiles/jobProfiles'
    And param query = 'name=="' + importedProfileName + '"'
    When method GET
    Then status 200
    * def importedProfileId = $.jobProfiles[0].id

    * print 'Imported profile ID: ' + importedProfileId
    * print 'Imported profile name: ' + importedProfileName

    * def jobProfileInfo =
      """
      {
        "id": "#(defaultCreateInstanceJobProfileId)",
        "name": "Default - Create instance and SRS MARC Bib",
        "dataType": "MARC"
      }
      """

    # Import a file using the default profile: "Default - Create instance and SRS MARC Bib"
    * def fileName = 'FAT-20172_20K_marc_bib_create.mrc'
    * def filePath = recordFilesDir + fileName
    * def result = call importFile { fileName: #(fileName), filePathFromSourceRoot : #(filePath), jobProfileInfo: #(jobProfileInfo) }
    * def s3UploadKey = result.s3UploadKey

    * call pause 480000
    # Waiting import results
    * def result = call read('classpath:folijet/data-import-large-scale-tests/global/get-completed-job-execution-for-key.feature@getJobsByKeyWhenStatusCompleted') { key: #(s3UploadKey) }
    * def jobExecutions = result.jobExecutions
    * match each jobExecutions contains { "status": "COMMITTED" }
    * match each jobExecutions contains { "uiStatus": "RUNNING_COMPLETE" }
    * match each jobExecutions contains { "runBy": "#present" }
    * match each jobExecutions contains { "progress": "#present" }

    # Update headers with new token after import
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }
    * configure headers = headersUser
    * print 'Headers updated in main flow with new token.'

    # Verify that entities have been created
    * call pause 5000
    * def logEntriesLimit = jobExecutions[0].progress.current
    * print 'Log entries limit: ' + logEntriesLimit
    * def verifyLogsInstanceCreated = function(job) { karate.call('classpath:folijet/data-import-large-scale-tests/features/marc-bib/create/create-instance.feature@verifyInstanceCreated', { headersUser, jobId: job.id, limit: logEntriesLimit }) }
    * karate.forEach(jobExecutions, verifyLogsInstanceCreated)

    # Import a file using the imported profile
    * def updatedJobProfileInfo =
      """
      {
        "id": "#(importedProfileId)",
        "name": "#(importedProfileName)",
        "dataType": "MARC"
      }
      """

    * def result = call importFile { fileName: #(fileName), filePathFromSourceRoot: #(filePath), jobProfileInfo: #(updatedJobProfileInfo) }
    * def s3UploadKey = result.s3UploadKey

    * call pause 480000
    # Waiting import results
    * def result = call read('classpath:folijet/data-import-large-scale-tests/global/get-completed-job-execution-for-key.feature@getJobsByKeyWhenStatusCompleted') { key: #(s3UploadKey) }
    * def jobExecutions = result.jobExecutions
    * print 'Verifying the content of "jobExecutions" array:', jobExecutions

    * def checkResult =
      """
      function(jobs) {
        if (!jobs || jobs.length === 0) {
          return { pass: false, reason: 'Jobs array is empty' };
        }
        for (let i = 0; i < jobs.length; i++) {
          let job = jobs[i];
          if (job.status !== 'COMMITTED' || job.uiStatus !== 'RUNNING_COMPLETE') {
            karate.log('Check failed at index ' + i + '. Actual status: ' + job.status + ', Actual uiStatus: ' + job.uiStatus);
            return { pass: false, reason: 'Status mismatch at index ' + i };
          }
        }
        return { pass: true };
      }
      """

    * def statusCheck = checkResult(jobExecutions)

    # Verify that entities have been created
    * call pause 5000
    * def verificationType = statusCheck.pass ? 'SUCCESS' : 'FAILURE'
    * print 'Job status check passed:', statusCheck.pass, '| Verification type:', verificationType

    * def logEntriesLimit = jobExecutions[0].progress.current
    * print 'Log entries limit: ' + logEntriesLimit
    * def parentJobExecutionId = jobExecutions[0].id
    * if (statusCheck.pass) { karate.call('classpath:folijet/data-import-large-scale-tests/utils/FAT-20172-verify-success.feature', { headersUser, jobId: parentJobExecutionId, limit: logEntriesLimit }) } else { karate.call('classpath:folijet/data-import-large-scale-tests/utils/FAT-20172-verify-failure.feature', { headersUser, jobId: parentJobExecutionId, limit: logEntriesLimit }) }
