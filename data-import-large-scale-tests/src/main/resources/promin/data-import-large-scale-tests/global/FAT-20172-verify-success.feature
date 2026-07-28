@ignore
Feature: Verify successful log entries

  Scenario:
    * configure headers = null
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }
    * configure headers = headersUser

    * print 'Verifying SUCCESS case for job:', jobId
    * def result = call getJobLogEntriesByJobId { headersUser: #(headersUser), jobExecutionId: #(jobId), logEntriesLimit: #(limit) }
    * def logEntriesCollection = result.jobLogEntries
    * assert logEntriesCollection.entries.length == limit

    * def holdingStatuses = karate.jsonPath(logEntriesCollection, "$.entries[*].relatedHoldingsInfo[*].actionStatus")
    * match each holdingStatuses == 'CREATED'

    * def itemStatuses = karate.jsonPath(logEntriesCollection, "$.entries[*].relatedItemInfo[*].actionStatus")
    * match each itemStatuses == 'CREATED'

    * def allErrors = karate.jsonPath(logEntriesCollection, "$..error")
    * match each allErrors == ''
