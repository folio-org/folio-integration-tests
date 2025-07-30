Feature: FAT-1117
  # This feature tests the updating of default mapping rules and verifies the changes via data-import.
  # Due to this, it should not be run in parallel with other tests.
  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')
    * configure retry = { interval: 5000, count: 30 }

  Scenario: FAT-1117 Default mapping rules updating and verification via data-import
    * print 'FAT-1117 Default mapping rules updating and verification via data-import'

    * def fileName = 'FAT-1117.mrc'
    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-1117.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read(commonImportFeature) {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/FAT-1117.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def jobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And request
      """
      {
        "uploadDefinition": "#(result.uploadDefinition)",
        "jobProfileInfo": {
          "id": "e34d7b92-9b83-11eb-a8b3-0242ac130003",
          "name": "Default - Create instance and SRS MARC Bib",
          "dataType": "MARC"
        }
      }
      """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'CREATED'
    And match response.entries[0].error == ''
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify that real instance was created with specific fields in inventory and retrieve instance id
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].notes[0].note == 'Includes bibliographical references and index'
    And assert response.instances[0].notes[0].staffOnly == false
    And match response.instances[0].identifiers[*].value contains '9780784412763'
    And match response.instances[0].identifiers[*].value contains '0784412766'
    And match response.instances[0].subjects[*].value contains  "Electronic books"
    And match response.instances[0].subjects[*].value !contains "United States"

    # Update marc-bib rules
    Given path 'mapping-rules/marc-bib'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/FAT-1117-changed-marc-bib-rules.json')
    When method PUT
    Then status 200
    * call pause 5000

    * def randomNumber = callonce random
    * def fileName = 'FAT-1117.mrc'
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-1117.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read(commonImportFeature) {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/FAT-1117.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def jobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And request
      """
      {
        "uploadDefinition": "#(result.uploadDefinition)",
        "jobProfileInfo": {
          "id": "e34d7b92-9b83-11eb-a8b3-0242ac130003",
          "name": "Default - Create instance and SRS MARC Bib",
          "dataType": "MARC"
        }
      }
      """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'CREATED'
    And match response.entries[0].error == ''
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify that real instance was created with specific fields in inventory
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].notes[0].note == 'Includes bibliographical references and index'
    And assert response.instances[0].notes[0].staffOnly == false
    And match response.instances[0].identifiers[*].value contains '9780784412763'
    And match response.instances[0].identifiers[*].value contains '0784412766'
    And match response.instances[0].subjects[*].value contains  "Engineering collection. United States"
    And match response.instances[0].subjects[*].value !contains "Electronic books"

    # Revert marc-bib rules to default
    Given path 'mapping-rules/marc-bib/restore'
    And headers headersUser
    When method PUT
    Then status 200
