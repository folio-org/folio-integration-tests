Feature: Create instance

  Background:
    * url baseUrl
    * configure retry = { interval: 5000, count: 30 }

    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }

    * def defaultCreateInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'
    * def recordFilesDir = 'classpath:folijet/data-import-large-scale-tests/samples/records/marc/'
    * def importFile = read('classpath:folijet/data-import-large-scale-tests/global/import-file.feature')
    * def getJobExecutionsByUploadKey = read('classpath:folijet/data-import-large-scale-tests/global/get-completed-job-execution-for-key.feature@getJobsByKeyWhenStatusCompleted')
    * def getJobLogEntriesByJobId = read('classpath:folijet/data-import-large-scale-tests/global/data-import-logs.feature@getJobLogEntriesByJobId')

  Scenario: FAT-17607 Create instances and save MARC-BIB records
    * print 'FAT-17607 Create instances and save MARC-BIB records'

    * def fileName = 'FAT-17607_3000-records.mrc'
    * def filePath = recordFilesDir + fileName
    * def jobProfileInfo =
      """
      {
        "id": "#(defaultCreateInstanceJobProfileId)",
        "name": "Default - Create instance and SRS MARC Bib",
        "dataType": "MARC"
      }
      """

    * def result = call importFile { 'fileName': '#(fileName)', 'filePathFromSourceRoot' : '#(filePath)', 'jobProfileInfo': '#(jobProfileInfo)' }
    * def s3UploadKey = result.s3UploadKey

    * call pause 120000
    * def result = call getJobExecutionsByUploadKey { key: '#(s3UploadKey)' }
    * def jobExecutions = result.jobExecutions
    * match each jobExecutions contains { "status": "COMMITTED" }
    * match each jobExecutions contains { "uiStatus": "RUNNING_COMPLETE" }
    * match each jobExecutions contains { "runBy": "#present" }
    * match each jobExecutions contains { "progress": "#present" }

    # Verify that entities have been created
    * call pause 5000
    * def logEntriesLimit = 1000
    * def verifyLogsInstanceCreated = function(job) { karate.call('@verifyInstanceCreated', { headersUser: headersUser, jobId: job.id, limit: logEntriesLimit }) }
    * karate.forEach(jobExecutions, verifyLogsInstanceCreated)

  @ignore
  @verifyInstanceCreated
  Scenario: Verify log entries that instances created
    * def result = call getJobLogEntriesByJobId { headersUser: #(headersUser), jobExecutionId: #(jobId), logEntriesLimit: #(limit) }
    * def logEntriesCollection = result.jobLogEntries
    * assert logEntriesCollection.entries.length == limit
    * match each logEntriesCollection.entries contains { "sourceRecordActionStatus": "CREATED" }
    * match each logEntriesCollection.entries..relatedInstanceInfo.actionStatus contains 'CREATED'
    * match each logEntriesCollection.entries contains { "error": "" }
