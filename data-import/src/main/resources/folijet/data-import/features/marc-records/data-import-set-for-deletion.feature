Feature: Set for deletion logic

  Background:
    * url baseUrl
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def commonImportFeature = 'classpath:folijet/data-import/global/common-data-import.feature'
    * def completeExecutionFeature = 'classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted'
    * def samplePath = 'classpath:folijet/data-import/samples/'

    * def javaDemo = Java.type('test.java.WriteData')


  Scenario: Create instance using marc with deleted leader
    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@ImportRecordAndVerify') { fileName: 'marcBibDeletedLeader', jobName: 'createInstance', actionStatus: 'CREATED' }
    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@VerifyInstanceAndRecordMarkedAsDeleted')

  Scenario: Update instance using marc with deleted leader
    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@ImportRecordAndVerify') { fileName: 'marcBib', jobName: 'createInstance', actionStatus: 'CREATED' }

    * def fileName = 'updateMarcBibDeletedLeader'
    * def filePathFromSourceRoot = 'file:target/' + fileName + '.mrc'
    * def marcRecord = read('classpath:folijet/data-import/samples/mrc-files/marcBibDeletedLeader.mrc')
    * def updatedMarcRecord = javaDemo.modifyMarcRecord(marcRecord, '001', ' ', ' ', ' ', instanceHrid)

    * javaDemo.writeByteArrayToFile(updatedMarcRecord, 'target/' + fileName + '.mrc')

    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@SetupUpdateJobProfile') { profileName: 'Update deleted' }
    * def jobProfileId = updateJobProfileId

    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@ImportRecordAndVerify') { fileName: '#(fileName)', jobName: 'customJob', filePathFromSourceRoot: '#(filePathFromSourceRoot)', actionStatus: 'UPDATED' }
    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@VerifyInstanceAndRecordMarkedAsDeleted')

  Scenario: Unmark deleted instance
    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@ImportRecordAndVerify') { fileName: 'marcBibDeletedLeader', jobName: 'createInstance', actionStatus: 'CREATED' }

    * def fileName = 'unmarkDeleted'
    * def filePathFromSourceRoot = 'file:target/' + fileName + '.mrc'
    * def marcRecord = read('classpath:folijet/data-import/samples/mrc-files/marcBib.mrc')
    * def updatedMarcRecord = javaDemo.modifyMarcRecord(marcRecord, '001', ' ', ' ', ' ', instanceHrid)

    * javaDemo.writeByteArrayToFile(updatedMarcRecord, 'target/' + fileName + '.mrc')

    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@SetupUpdateJobProfile') { profileName: 'Unmark deleted' }
    * def jobProfileId = updateJobProfileId

    Given call read('this:helpers/data-import-set-for-deletion-utils.feature@ImportRecordAndVerify') { fileName: '#(fileName)', jobName: 'customJob', filePathFromSourceRoot: '#(filePathFromSourceRoot)', actionStatus: 'UPDATED' }

    # Retrieve instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    * def createdInstance = response.instances[0]

    # Verify instance mark as deleted
    And assert createdInstance.staffSuppress == true
    And assert createdInstance.discoverySuppress == true
    And assert createdInstance.deleted == false

    # Retrieve source record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.deleted == false
    And match response.additionalInfo.suppressDiscovery == true
    And match response.state == 'ACTUAL'
    And match response.leaderRecordStatus == 'c'
