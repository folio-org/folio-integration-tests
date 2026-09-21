Feature: Import of MARC with subfields that are not mapped to Instance fields

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

  Scenario: Test import of MARC with subfields that are not mapped to Instance fields - INTEGRATION
    * def createInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'

    # Import file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-1471', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify job execution for create instance
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify instance created
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == "CREATED"
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"

    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Retrieve instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    * def updatedInstance = response.instances[0]
    * eval updatedInstance['natureOfContentTermIds'] = ["96879b60-098b-453b-bf9a-c47866f1ab2a"]

    # Update nature of content
    Given path 'inventory/instances', updatedInstance.id
    And headers headersUser
    And request updatedInstance
    When method PUT
    Then status 204

    # Verify nature of content updated and 590$3 don't mapped to Instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And match response.instances[0].natureOfContentTermIds[0] == "96879b60-098b-453b-bf9a-c47866f1ab2a"
    And match each response.instances[0].notes..note != 'test'
