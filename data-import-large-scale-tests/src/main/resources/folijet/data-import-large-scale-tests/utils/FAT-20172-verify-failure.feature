@ignore
Feature: Verify and report failure log entries (advanced)

  Scenario:
    * configure headers = null
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }
    * configure headers = headersUser

    * print 'Verifying FAILURE case for job:', jobId
    * def result = call getJobLogEntriesByJobId { headersUser: #(headersUser), jobExecutionId: #(jobId), logEntriesLimit: #(limit) }
    * def logEntriesCollection = result.jobLogEntries
    * assert logEntriesCollection != null

    * assert logEntriesCollection.entries.length == limit

    * def allErrors = karate.jsonPath(logEntriesCollection, "$..error")
    * def nonEmptyErrors = allErrors.filter(x => x && x.trim() !== '')

    * print 'FOUND ALL ERROR MESSAGES (from all levels):', nonEmptyErrors

    * karate.fail('Test failed because the job execution status was not COMMITTED. See all error messages printed above.')