@ignore
Feature: Util feature to print job summary and error log entries for a job execution
  # parameters: jobId
  # Diagnostics only: never fails on its own, so the original assertion stays the reported failure.

  Background:
    * url baseUrl
    * configure headers = null
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(tenant)', 'Accept': '*/*' }
    * configure headers = headersUser

  @reportJobFailureDetails
  Scenario: Print summary and errors of a failed job
    * print 'Collecting failure details for job:', jobId

    # Job summary: per-entity success/error counts
    Given path 'metadata-provider/jobSummary', jobId
    When method GET
    * print 'Job summary status:', responseStatus
    * print 'Job summary for', jobId, ':', karate.pretty(response)

    # Log entries: print only entries that carry an error
    Given path 'metadata-provider/jobLogEntries', jobId
    And param limit = 1000
    When method GET
    * print 'Job log entries status:', responseStatus
    * def entries = (responseStatus == 200 && response.entries) ? response.entries : []
    * def hasError =
      """
      function(entry) {
        var errors = karate.jsonPath(entry, '$..error');
        return errors.some(function(e) { return e && ('' + e).trim() !== ''; });
      }
      """
    * def failedEntries = entries.filter(hasError)
    * print 'Job', jobId, ': entries with errors =', failedEntries.length, 'of', entries.length
    * print 'First error entries:', karate.pretty(failedEntries.slice(0, 5))
