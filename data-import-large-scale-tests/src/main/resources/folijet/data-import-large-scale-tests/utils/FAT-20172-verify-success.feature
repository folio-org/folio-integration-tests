@ignore
Feature: Verify successful log entries

  Scenario:
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
