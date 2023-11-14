Feature: linking-records tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure readTimeout = 65000
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples'

    * def authorityNaturalId = karate.properties['authorityNaturalId']
    * def authorityId = karate.properties['linkedAuthorityId']
    * def instanceId = karate.properties['instanceId']

  @Positive
  Scenario: Update linking authority 100 - should update bib and instance record content
    # retrieve quick marc record
    Given path '/records-editor/records'
    And param externalId = authorityId
    When method GET
    Then status 200

    # replace new field
    * def record = response
    * set record.relatedRecordVersion = 1

    * def field = karate.jsonPath(record, "$.fields[?(@.tag=='100')]")[0]
    * set field.content = '$a Updated'
    * remove record.fields[?(@.tag=='100')]
    * record.fields.push(field)
    * set record._actionType = 'edit'

    # update authority record
    Given path '/records-editor/records', record.parsedRecordId
    And request record
    When method PUT
    Then status 202
    * sleep(5000)

    # retrieve bib record
    Given path '/source-storage/records'
    And param state = 'ACTUAL'
    When method GET
    Then status 200
    And def bibRecord = response.records.find(x => x.externalIdsHolder.instanceId==instanceId)
    And match bibRecord.parsedRecord.content.fields[*].100.subfields[*].a contains 'Updated'

    # retrieve instance record
    Given path '/instance-storage/instances', instanceId
    When method GET
    Then status 200
    And match response.contributors[*].name contains 'Updated'

  @Positive
  Scenario: Update linking authority 010 - should update $0 bib subfield
    # retrieve quick marc record
    Given path '/records-editor/records'
    And param externalId = authorityId
    When method GET
    Then status 200

    # replace new field
    * def record = response
    * set record.relatedRecordVersion = 2

    * def field = karate.jsonPath(record, "$.fields[?(@.tag=='010')]")[0]
    * set field.content = 'Updated'
    * remove record.fields[?(@.tag=='010')]
    * record.fields.push(field)
    * set record._actionType = 'edit'

    # update authority record
    Given path '/records-editor/records', record.parsedRecordId
    And request record
    When method PUT
    Then status 202

    # retrieve bib srs record
    Given path '/source-storage/records'
    And param state = 'ACTUAL'
    When method GET
    Then status 200
    And def bibRecord = response.records.find(x => x.externalIdsHolder.instanceId==instanceId)
    And match bibRecord.parsedRecord.content.fields[*].100.subfields[*].a contains 'Updated'

  @Positive
  Scenario: Delete linking authority - should remove $9 subfield from bib record
    # retrieve bib srs record - should have authority link
    Given path '/source-storage/records'
    And param state = 'ACTUAL'
    When method GET
    Then status 200
    And def bibRecord = response.records.find(x => x.externalIdsHolder.instanceId==instanceId)
    And match bibRecord.parsedRecord.content.fields[*].100 != null
    And match bibRecord.parsedRecord.content.fields[*].100.subfields[*].0 != []
    And match bibRecord.parsedRecord.content.fields[*].100.subfields[*].9 != []

    # delete linking authority
    Given path 'records-editor/records', authorityId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 408
    And eval if (responseStatus == 204) sleep(5000)
    And eval if (responseStatus == 408) sleep(20000)

    # retrieve bib srs record - should delete authority link
    Given path '/source-storage/records'
    And param state = 'ACTUAL'
    When method GET
    Then status 200
    And def bibRecord = response.records.find(x => x.externalIdsHolder.instanceId==instanceId)
    And match bibRecord.parsedRecord.content.fields[*].100 != []
 #  And match bibRecord.parsedRecord.content.fields[*].100.subfields[*].0 == []
    And match bibRecord.parsedRecord.content.fields[*].100.subfields[*].9 == []
    And match bibRecord.parsedRecord.content.fields[*].240 != []
 #  And match bibRecord.parsedRecord.content.fields[*].240.subfields[*].0 == []
    And match bibRecord.parsedRecord.content.fields[*].240.subfields[*].9 == []
