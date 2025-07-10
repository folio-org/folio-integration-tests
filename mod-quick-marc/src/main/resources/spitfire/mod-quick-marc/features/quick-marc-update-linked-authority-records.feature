Feature: update of two authorities records linked to one instance tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure readTimeout = 65000
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

    * def authorityNaturalId1 = karate.properties['authorityNaturalId1']
    * def authorityNaturalId2 = karate.properties['authorityNaturalId2']
    * def authorityId1 = karate.properties['linkedAuthorityId1']
    * def authorityId2 = karate.properties['linkedAuthorityId2']
    * def instanceId = karate.properties['instanceId']

  Scenario: Should unlink bib record on first authority field update making it unlinkable
    # retrieve marc bib record and check it contains a link
    Given path '/source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].100 != null
    And match response.parsedRecord.content.fields[*].100.subfields[*].9 != []

    # save bib snapshotId to use for retry later
    * def bibSnapshotId = response.snapshotId

    # retrieve quick marc authority record
    Given path '/records-editor/records'
    And param externalId = authorityId1
    When method GET
    Then status 200

    # add new subfield to a linked field
    * def record = response
    * def field = karate.jsonPath(record, "$.fields[?(@.tag=='100')]")[0]
    * set field.content = '$a Johnson $t Some value'
    * remove record.fields[?(@.tag=='100')]
    * record.fields.push(field)
    * set record._actionType = 'edit'
    * set record.relatedRecordVersion = 1

    # update authority record
    Given path '/records-editor/records', record.parsedRecordId
    And request record
    When method PUT
    Then status 202

    # count links
    Given path '/links/authorities/bulk/count'
    And request {"ids": [#(authorityId1)]}
    And retry until response.links[0].totalLinks == 0
    When method POST
    Then status 200
    Then match response.links[0].totalLinks == 0

    # retrieve marc bib record
    Given path '/source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    And retry until response.snapshotId != bibSnapshotId
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].100 != null
    And match response.parsedRecord.content.fields[*].100.subfields[*].9 == []

    # retrieve quick marc authority record
    Given path '/records-editor/records'
    And param externalId = authorityId1
    When method GET
    Then status 200

    # rollback link deletion
    * set field.content = '$a Johnson'
    * remove record.fields[?(@.tag=='100')]
    * record.fields.push(field)
    * set record.relatedRecordVersion = 2
    Given path '/records-editor/records', record.parsedRecordId
    And request record
    When method PUT
    Then status 202

    Given path '/records-editor/records'
    And param externalId = instanceId
    When method GET
    Then status 200
    And def bibRecord = response
    * def linkContent = ' $0 ' + authorityNaturalId1 + ' $9 ' + authorityId1
    * def tag100 = {"tag": "100", "content":'#("$a Johnson" + linkContent)', "indicators": ["\\","1"], "linkDetails":{ "authorityId": #(authorityId1),"authorityNaturalId": #(authorityNaturalId1), "linkingRuleId": 1} }
    * bibRecord.fields = bibRecord.fields.filter(field => field.tag != "100")
    * bibRecord.fields.push(tag100)
    * set bibRecord.relatedRecordVersion = 7
    * set bibRecord._actionType = 'edit'
    Given path 'records-editor/records', bibRecord.parsedRecordId
    And request bibRecord
    When method PUT
    Then status 202

  Scenario: Should unlink bib record on second authority field update making it unlinkable
    # retrieve marc bib record and check it contains a link
    Given path '/source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].240 != null
    And match response.parsedRecord.content.fields[*].240.subfields[*].9 != []

    # save bib snapshotId to use for retry later
    * def bibSnapshotId = response.snapshotId

    # retrieve quick marc authority record
    Given path '/records-editor/records'
    And param externalId = authorityId2
    When method GET
    Then status 200

    # add new subfield to a linked field
    * def record = response
    * def field = karate.jsonPath(record, "$.fields[?(@.tag=='100')]")[0]
    * set field.content = '$a Johnson Updated'
    * remove record.fields[?(@.tag=='100')]
    * record.fields.push(field)
    * set record._actionType = 'edit'
    * set record.relatedRecordVersion = 1

    # update authority record
    Given path '/records-editor/records', record.parsedRecordId
    And request record
    When method PUT
    Then status 202

    # count links
    Given path '/links/authorities/bulk/count'
    And request {"ids": [#(authorityId2)]}
    And retry until response.links[0].totalLinks == 0
    When method POST
    Then status 200
    Then match response.links[0].totalLinks == 0

    # retrieve marc bib record
    Given path '/source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    And retry until response.snapshotId != bibSnapshotId
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].240 != null
    And match response.parsedRecord.content.fields[*].240.subfields[*].9 == []