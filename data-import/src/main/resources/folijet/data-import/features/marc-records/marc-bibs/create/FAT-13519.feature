Feature: FAT-13519

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario:  FAT-13519 Import of file with 010$z should mapped for canceled LCCN in second position
    # Import file and create instance
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13519', jobName:'createInstance' }
    Then match status != 'ERROR'

    # Verify job execution for create instances
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"
    And def instanceHrid = response.entries[0].relatedInstanceInfo.hridList[0]

    # Get Cancelled LCCN identifier id
    Given path 'identifier-types'
    And headers headersUser
    And param query = 'name==Canceled LCCN'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def LCCNidentifierTypeId = response.identifierTypes[0].id

    # Verify Cancelled LCCN mapped to Instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    * def identifiers = response.instances[0].identifiers
    * def cancelledLCCN = karate.jsonPath(identifiers, "$[?(@.identifierTypeId=='" + LCCNidentifierTypeId + "')]")
    And match cancelledLCCN == '#present'
    And match cancelledLCCN[0].value == "70100621"
