Feature: Test MARC records literal dollar in subfield
  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

  Scenario: Check marc bib literal dollar in subfield
    * def marcBib = call read('setup/setup.feature@CreateMarcBibRecord')
    * def marcBibRecord = marcBib.response
    * def marcBibId = marcBibRecord.externalId
    * def field905 = marcBibRecord.fields.find(f => f.tag == "905")
    * match field905.content == "$a The book costs {dollar}560.00"

    * def srsRecord = call read('setup/setup.feature@GetSRSRecord') {recordId: '#(marcBibId)', idType: 'INSTANCE'}
    * def record = srsRecord.response.parsedRecord.content
    * def field905 = record.fields.find(f => f['905'])
    * def subfieldA = field905['905'].subfields[0]['a']
    * match subfieldA == "The book costs $560.00"

    * print "Update subfields for 905 field"
    * marcBibRecord.fields[30].content = "$a Daniela Andrade - {dollar}{dollar}{dollar} $b song lyrics"
    * set marcBibRecord._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(marcBibRecord.parsedRecordId)', record: '#(marcBibRecord)' }

    * print "Check marcBib/SRS record 905 tag after subfield update"
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcBibId)' }
    And def quickMarcJson = record.response
    And def marcBibId = quickMarcJson.externalId
    * def field905 = quickMarcJson.fields.find(f => f.tag == "905")
    * match field905.content == "$a Daniela Andrade - {dollar}{dollar}{dollar} $b song lyrics"

    * def srsRecord = call read('setup/setup.feature@GetSRSRecord') {recordId: '#(marcBibId)', idType: 'INSTANCE' }
    * def record = srsRecord.response.parsedRecord.content
    * def field905 = record.fields.find(f => f['905'])
    * def subfieldA = field905['905'].subfields[0]['a']
    * match subfieldA == "Daniela Andrade - $$$"

  Scenario: Check marc authority literal dollar in subfield
    * def marcAuthority = call read('setup/setup.feature@CreateMarcAuthorityRecord')
    * def authorityRecord = marcAuthority.response
    * def marcAuthorityId = authorityRecord.externalId
    * def field551 = authorityRecord.fields.find(f => f.tag == "551")
    * match field551.content == "$a Test Ke{dollar}ha"

    * def srsRecord = call read('setup/setup.feature@GetSRSRecord') {recordId: '#(marcAuthorityId)', idType: 'AUTHORITY' }
    * def record = srsRecord.response.parsedRecord.content
    * def field551 = record.fields.find(f => f['551'])
    * def subfieldA = field551['551'].subfields[0]['a']
    * match subfieldA == "Test Ke$ha"

    * print "Update subfield for 551 field"
    * authorityRecord.fields[5].content = "$a Test Ke{dollar}ha {dollar}100"
    * set authorityRecord._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(authorityRecord.parsedRecordId)', record: '#(authorityRecord)' }

    * print "Check marcAuthority/SRS record 551 tag content after update"
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcAuthorityId)' }
    And def quickMarcJson = record.response
    And def marcBibId = quickMarcJson.externalId
    * def field551 = quickMarcJson.fields.find(f => f.tag == "551")
    * match field551.content == "$a Test Ke{dollar}ha {dollar}100"

    * def srsRecord = call read('setup/setup.feature@GetSRSRecord') {recordId: '#(marcBibId)', idType: 'AUTHORITY' }
    * def record = srsRecord.response.parsedRecord.content
    * def field551 = record.fields.find(f => f['551'])
    * def subfieldA = field551['551'].subfields[0]['a']
    * match subfieldA == "Test Ke$ha $100"

  Scenario: Check marc holding literal dollar in subfield
    * def marcHolding = call read('setup/setup.feature@CreateHoldingRecord')
    * def marcHoldingRecord = marcHolding.response
    * def marcHoldingId = marcHoldingRecord.externalId
    * def field852 = marcHoldingRecord.fields.find(f => f.tag == "852")
    * match field852.content == "$b MARC tag 852 $a {dollar}1"

    * def srsRecord = call read('setup/setup.feature@GetSRSRecord') {recordId: '#(marcHoldingId)', idType: 'HOLDINGS' }
    * def record = srsRecord.response.parsedRecord.content
    * def srsField852 = record.fields.find(f => f['852'])
    * def subfieldA = srsField852['852'].subfields.find(s => s['a'])
    * match subfieldA['a'] == "$1"

    * print "Update subfield for 852 field"
    * marcHoldingRecord.fields[5].content = "$b MARC tag $a{dollar}1 {dollar}{dollar}2"
    * set marcHoldingRecord._actionType = 'edit'
    * call read('setup/setup.feature@PutRecord') {parsedRecordId: '#(marcHoldingRecord.parsedRecordId)', record: '#(marcHoldingRecord)' }

    * print "Check marcHolding/SRS record 852 tag content after update"
    * def record = call read('setup/setup.feature@GetRecordById') {recordId: '#(marcHoldingId)' }
    And def quickMarcJson = record.response
    * def field852 = quickMarcJson.fields.find(f => f.tag == "852")
    * match field852.content == "$b MARC tag $a {dollar}1 {dollar}{dollar}2"

    * def srsRecord = call read('setup/setup.feature@GetSRSRecord') {recordId: '#(marcHoldingId)', idType: 'HOLDINGS' }
    * def record = srsRecord.response.parsedRecord.content
    * def srsField852 = record.fields.find(f => f['852'])
    * def subfieldA = srsField852['852'].subfields.find(s => s['a'])
    * match subfieldA['a'] == "$1 $$2"