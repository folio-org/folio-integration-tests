@ignore
Feature: MARC instance utilities for consortia tests

  Background:
    * url baseUrl
    * def samplesPath = 'classpath:promin/mod-inventory/samples/consortia/'

  # Creates a local MARC instance: the instance record plus its SRS MARC record pointing at it.
  # Expects 'instance' (instance body, source must be MARC) and 'headersUser' (headers of the owning tenant).
  # Returns 'instanceId' and 'instanceHrid' (assigned by the tenant's HRID settings).
  @CreateLocalMarcInstance
  Scenario: Create a local MARC instance with its SRS record
    Given path 'instance-storage/instances'
    And headers headersUser
    And request instance
    When method POST
    Then status 201
    * def instanceId = response.id
    * def instanceHrid = response.hrid

    * def snapshotId = uuid()
    Given path 'source-storage/snapshots'
    And headers headersUser
    # SRS accepts records only under a snapshot with a processing start date; it sets one itself for this status
    And request { jobExecutionId: '#(snapshotId)', status: 'PARSING_IN_PROGRESS' }
    When method POST
    Then status 201

    * def recordId = uuid()
    Given path 'source-storage/records'
    And headers headersUser
    And request read(samplesPath + 'marc-bib.json')
    When method POST
    Then status 201
