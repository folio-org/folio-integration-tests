Feature: Source-Record-Manager

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }


  @Undefined
  Scenario: Test init job execution with 1 file
    * print 'Test init job execution with 1 file'

  @Undefined
  Scenario: Test init job execution with multiple files
    * print 'Test init job execution with multiple files'

  @Undefined
  Scenario: Test return of children job executions for multiple files
    * print 'Init job execution with multiple files, get children of that job execution'

  @Undefined
  Scenario: Test update of a status of job execution
    * print 'Init job execution, update its status'

  @Undefined
  Scenario: Test completed date and total for job execution when status is updated to ERROR
    * print 'Init job execution, update its status to ERROR, verify completed date is set and total is set to zero'

  @Undefined
  Scenario: Test processing of a chunk of raw records
    * print 'Init job execution, post chunk of raw records'

  @Undefined
  Scenario: Test return of journal records sorted by source record order and action CREATED
    * print 'This scenario might be a part of integration - importing a file and then querying the metadata provider API'

  @Undefined
  Scenario: Test return of journal records sorted by source record order and action UPDATED
    * print 'This scenario might be a part of integration - importing a file and then querying the metadata provider API'
