Feature: linking-records tests

  Background:
    * url baseUrl
    * call login testUser
    * configure readTimeout = 65000
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

    * def authorityId = karate.properties['linkedAuthorityId1']
    * def authorityNaturalId1 = karate.properties['authorityNaturalId1']

    # Create a fresh bib with 100+600 links for this scenario so generation tracking is not needed
    * def newBibId = uuid()
    * def newBibHrid = 'linking-test-' + newBibId
    * def instanceId = newBibId
    * def instanceHrid = newBibHrid
    * def recordId = uuid()
    * def snapshotId = '7dbf5dcf-f46c-42cd-924b-04d99cd410b9'

    Given path 'instance-storage/instances'
    And request read('classpath:spitfire/mod-quick-marc/features/setup/samples/setup-records/instance.json')
    When method POST
    Then status 201

    Given path 'source-storage/records'
    And request read('classpath:spitfire/mod-quick-marc/features/setup/samples/setup-records/marc-bib.json')
    When method POST
    Then status 201

    Given path 'records-editor/records'
    And param externalId = newBibId
    And retry until response.updateInfo.recordState == 'ACTUAL'
    When method GET
    Then status 200
    * def bibRecord = response

    * def linkContent = ' $0 ' + authorityNaturalId1 + ' $9 ' + authorityId
    * def tag100 = {"tag": "100", "content":'#("$a Johnson" + linkContent)', "indicators": ["\\","1"], "isProtected": false, "linkDetails":{"authorityId":#(authorityId), "authorityNaturalId":#(authorityNaturalId1), "linkingRuleId": 1, "status": "NEW"}}
    * def tag600 = {"tag": "600", "content":'#("$a Johnson" + linkContent)', "indicators": ["\\","\\"], "isProtected": false, "linkDetails":{"authorityId":#(authorityId), "authorityNaturalId":#(authorityNaturalId1), "linkingRuleId": 8, "status": "NEW"}}
    * bibRecord.fields = bibRecord.fields.filter(f => f.tag != '100')
    * bibRecord.fields.push(tag100)
    * bibRecord.fields.push(tag600)
    * set bibRecord._actionType = 'edit'

    Given path 'records-editor/records', bibRecord.parsedRecordId
    And request bibRecord
    When method PUT
    Then status 202

    Given path 'links/instances', newBibId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

  @Positive
  Scenario: Update linking authority 100 - should update bib and instance record content
    # retrieve quick marc record
    Given path '/records-editor/records'
    And param externalId = authorityId
    When method GET
    Then status 200

    # replace new field
    * def record = response

    * def field = karate.jsonPath(record, "$.fields[?(@.tag=='100')]")[0]
    * set field.content = '$a Updated'
    * remove record.fields[?(@.tag=='100')]
    * record.fields.push(field)
    * set record._actionType = 'edit'

    # save current bib snapshotId before update
    Given path '/source-storage/records', newBibId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    * def bibSnapshotId = response.snapshotId

    # update authority record
    Given path '/records-editor/records', record.parsedRecordId
    And request record
    When method PUT
    Then status 202
    * sleep(5000)

    # retrieve bib record
    Given path '/source-storage/records', newBibId, 'formatted'
    And param idType = 'INSTANCE'
    And retry until response.snapshotId != bibSnapshotId
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].100.subfields[*].a contains 'Updated'

    # retrieve instance record
    Given path '/instance-storage/instances', newBibId
    And retry until response.contributors.some(x => x.name == 'Updated')
    When method GET
    Then status 200

  @Positive
  Scenario: Update linking authority 010 - should update $0 bib subfield
    # retrieve quick marc record
    Given path '/records-editor/records'
    And param externalId = authorityId
    When method GET
    Then status 200

    # replace new field
    * def record = response

    * def field = karate.jsonPath(record, "$.fields[?(@.tag=='010')]")[0]
    * set field.content = '$a n 00001265'
    * remove record.fields[?(@.tag=='010')]
    * record.fields.push(field)
    * set record._actionType = 'edit'

    # save current bib snapshotId before update
    Given path '/source-storage/records', newBibId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    * def bibSnapshotId = response.snapshotId

    # update authority record
    Given path '/records-editor/records', record.parsedRecordId
    And request record
    When method PUT
    Then status 202

    # retrieve bib srs record
    Given path '/source-storage/records', newBibId, 'formatted'
    And param idType = 'INSTANCE'
    And retry until response.snapshotId != bibSnapshotId
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].100.subfields[*].0 contains 'http://id.loc.gov/authorities/names/n00001265'

  @Positive
  Scenario: Delete linking authority - should remove $9 subfield from bib record
    # retrieve bib srs record - should have authority link
    Given path '/source-storage/records', newBibId, 'formatted'
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].100 != null
    And match response.parsedRecord.content.fields[*].100.subfields[*].0 != []
    And match response.parsedRecord.content.fields[*].100.subfields[*].9 != []

    # save current bib snapshotId before deletion
    * def bibSnapshotId = response.snapshotId

    # delete linking authority
    Given path 'authority-storage/authorities', authorityId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 408
    And eval if (responseStatus == 204) sleep(5000)
    And eval if (responseStatus == 408) sleep(20000)

    # retrieve bib srs record - should delete authority link
    Given path '/source-storage/records', newBibId, 'formatted'
    And param idType = 'INSTANCE'
    And retry until response.snapshotId != bibSnapshotId
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].100 != []
    And match response.parsedRecord.content.fields[*].100.subfields[*].9 == []
