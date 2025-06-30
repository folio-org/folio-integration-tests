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

    * call pause 120000
    # Waiting import results
    * def result = call read('classpath:folijet/data-import-large-scale-tests/global/get-completed-job-execution-for-key.feature@getJobsByKeyWhenStatusCompleted') { key: #(s3UploadKey) }
    * configure headers = result.headersUser
    * print 'Headers updated in main flow with new token.'

    * def jobExecutions = result.jobExecutions
    * match each jobExecutions contains { "status": "COMMITTED" }
    * match each jobExecutions contains { "uiStatus": "RUNNING_COMPLETE" }
    * match each jobExecutions contains { "runBy": "#present" }
    * match each jobExecutions contains { "progress": "#present" }

    # Verify that entities have been created
    * call pause 5000
    * def logEntriesLimit = 1000
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

    * call pause 120000
    # Waiting import results
    * def result = call read('classpath:folijet/data-import-large-scale-tests/global/get-completed-job-execution-for-key.feature@getJobsByKeyWhenStatusCompleted') { key: #(s3UploadKey) }
    * def jobExecutions = result.jobExecutions
    * match each jobExecutions contains { "status": "COMMITTED" }
    * match each jobExecutions contains { "uiStatus": "RUNNING_COMPLETE" }
    * match each jobExecutions contains { "runBy": "#present" }
    * match each jobExecutions contains { "progress": "#present" }

    # Verify that entities have been created
    * call pause 5000
    * def logEntriesLimit = 1000
    * def verifyHoldingsItemsCreated = function(job) { karate.call('@verifyHoldingsItemsCreated', { headersUser, jobId: job.id, limit: logEntriesLimit }) }
    * karate.forEach(jobExecutions, verifyHoldingsItemsCreated)

  @ignore
  @verifyHoldingsItemsCreated
  Scenario: Verify log entries that instances created
    * def result = call getJobLogEntriesByJobId { headersUser: #(headersUser), jobExecutionId: #(jobId), logEntriesLimit: #(limit) }
    * def logEntriesCollection = result.entries
    * assert logEntriesCollection.entries.length == limit
    * match each logEntriesCollection.entries..relatedHoldingsInfo.actionStatus contains 'CREATED'
    * match each logEntriesCollection.entries..relatedItemInfo.actionStatus contains 'CREATED'
    * match each logEntriesCollection.entries contains { "error": "" }