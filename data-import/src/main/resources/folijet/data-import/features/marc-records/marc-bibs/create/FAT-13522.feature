Feature: FAT-13522

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario: FAT-13522 Test import of file with 035 OCLC field with prefix and leading zeros with duplicates and additional subfields
    # Import file and create instance
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13522', jobName:'createInstance' }
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

    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"
    And def instanceId = response.entries[0].relatedInstanceInfo.idList[0]
    And def instanceHrid = response.entries[0].relatedInstanceInfo.hridList[0]
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Get OCLC identifier id
    Given path 'identifier-types'
    And headers headersUser
    And param query = 'name==OCLC'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def OCLCidentifierTypeId = response.identifierTypes[0].id

    # Get Cancelled System Control Number identifier id
    Given path 'identifier-types'
    And headers headersUser
    And param query = 'name==Cancelled system control number'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def cancelledSystemNumberIdentifyreTypeId = response.identifierTypes[0].id

    * def expectedIdentifiers =
      """
      [
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)123456"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)64758"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)976939443"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)1001261435"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)120194933"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)tfe501056183"
        },
        {
          "identifierTypeId": "#(cancelledSystemNumberIdentifyreTypeId)",
          "value": "(OCoLC)12345678"
        }
      ]
      """

    # Verify ISRI
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    * def identifiers = response.instances[0].identifiers
    * def actualIdentifiers = karate.jsonPath(identifiers, "$[?(@.identifierTypeId=='" + cancelledSystemNumberIdentifyreTypeId + "' || @.identifierTypeId=='" + OCLCidentifierTypeId + "')]")
    And match actualIdentifiers == '#present'
    And match actualIdentifiers contains only expectedIdentifiers

    * def expected035s =
      """
      [
        {
          "ind1": " ",
          "ind2": " ",
          "subfields": [
            {
              "a": "(Sirsi) i9781845902919"
            }
          ]
        },
        {
          "ind1": " ",
          "ind2": " ",
          "subfields": [
            {
              "a": "(LTSCA)303845"
            }
          ]
        },
        {
          "ind1": " ",
          "ind2": " ",
          "subfields": [
            {
              "a": "(OCoLC)123456"
            },
            {
              "a": "(OCoLC)64758"
            },
            {
              "a": "(OCoLC)976939443"
            },
            {
              "a": "(OCoLC)1001261435"
            },
            {
              "a": "(OCoLC)120194933"
            },
            {
              "a": "(OCoLC)tfe501056183"
            },
            {
              "z": "(OCoLC)12345678"
            }
          ]
        }
      ]
      """

    # Retrieve instance source
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    * def parsedRecord = response.parsedRecord
    And match parsedRecord.content.fields[*].035 contains only expected035s

    * def expectedQuickMarc035s =
      """
      [
        {
          "tag": "035",
          "content": "$a (Sirsi) i9781845902919",
          "indicators": [
            "\\",
            "\\"
          ],
          "isProtected": false
        },
        {
          "tag": "035",
          "content": "$a (OCoLC)123456 $a (OCoLC)64758 $a (OCoLC)976939443 $a (OCoLC)1001261435 $a (OCoLC)120194933 $a (OCoLC)tfe501056183 $z (OCoLC)12345678",
          "indicators": [
            "\\",
            "\\"
          ],
          "isProtected": false
        },
        {
          "tag": "035",
          "content": "$a (LTSCA)303845",
          "indicators": [
            "\\",
            "\\"
          ],
          "isProtected": false
        }
      ]
      """

    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    And match karate.jsonPath(response, "$.fields[?(@.tag=='035')]") == expectedQuickMarc035s
