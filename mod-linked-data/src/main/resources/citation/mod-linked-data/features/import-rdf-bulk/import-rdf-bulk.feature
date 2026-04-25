Feature: Import Bibframe2 RDF in bulk into linked data graph

  Background:
    * url baseUrl
    * configure retry = { count: 20, interval: 5000 }
    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * call login linkedDataBulkImportUser
    * def linkedDataBulkImportHeaders = { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  @C1046002
  Scenario: Run bulk RDF import
    # Step 1: Create authorities used by import and verify they are indexed
    * configure headers = testAdminHeaders
    * def sourceRecordRequest = read('samples/authority_person.json')
    * def postAuthorityPersonCall = call postSourceRecordToStorage
    * def query = '(lccn="n1058")'
    * call searchAuthority

    * def sourceRecordRequest = read('samples/authority_topic.json')
    * def postAuthorityTopicCall = call postSourceRecordToStorage
    * def query = '(lccn="sh1058")'
    * call searchAuthority

    * def sourceRecordRequest = read('samples/fast_authority_organization.json')
    * def postFastAuthorityCall = call postSourceRecordToStorage
    * def query = '(naturalId="fst1058")'
    * call searchAuthority

    # Step 2: Create a file with 100 valid RDF lines & three invalid lines
    * def rdfCount = 100
    * def invalidJsonLine = '[ {"field": "value"]'
    * def noInstanceRdfLine = '[{"@id":"_:someBlankNodeId","@type":["http://id.loc.gov/ontologies/bibframe/Place"],"http://www.w3.org/2000/01/rdf-schema#label":[{"@value":"Some place"}]}]'
    * def noTitleInstanceRdfLine = '[{"@id":"http://id.loc.gov/resources/instances/no_title_instance","@type":["http://id.loc.gov/ontologies/bibframe/Instance"]}]'
    * def invalidLines =
      """
      [
        { "lineNumber": 12, "json": "#(invalidJsonLine)" },
        { "lineNumber": 78, "json": "#(noInstanceRdfLine)" },
        { "lineNumber": 90, "json": "#(noTitleInstanceRdfLine)" }
      ]
      """

    * def generateRdfFileArgs = {}
    * set generateRdfFileArgs.lineCount = rdfCount
    * set generateRdfFileArgs.invalidLines = invalidLines
    * def generateRdfFileCall = call read('util/generate-rdf-bulk-jsonl.js') generateRdfFileArgs
    * def sourceFileName = generateRdfFileCall.sourceFileName
    * def generatedFilePathForUpload = 'file:' + generateRdfFileCall.generatedFilePathAbsolute

    # Step 3: Upload generated file to S3 bucket
    * configure headers = linkedDataBulkImportHeaders
    Given path '/linked-data-import/files'
    And multipart file file = { read: '#(generatedFilePathForUpload)', filename: '#(sourceFileName)', contentType: 'application/ld+json' }
    When method POST
    Then status 200
    * def uploadedFileName = response
    * match uploadedFileName == '#string'

    # Step 4: Start import job
    Given path '/linked-data-import/start'
    And param fileName = uploadedFileName
    And param contentType = 'application/ld+json'
    When method POST
    Then status 200
    * def jobExecutionId = response
    * match jobExecutionId == '#string'

    # Step 5: Poll job status until terminal state
    Given path '/linked-data-import/jobs/' + jobExecutionId
    And retry until response.savingComplete == true || response.status == 'FAILED'
    When method GET
    Then status 200
    * if (response.status == 'FAILED') karate.fail('Import job failed. jobExecutionId=' + jobExecutionId)
    * match response.status == 'COMPLETED'
    * match response.linesCreated == rdfCount
    * match response.linesFailedMapping == 2
    * match response.linesFailedSaving == 1
    * match response.linesMapped == rdfCount + 1
    * match response.linesRead == rdfCount + 3
    * match response.linesUpdated == 0

    # Step 6: Validate failed lines report & ensure that 3 invalid lines are present in the report
    Given path '/linked-data-import/jobs/' + jobExecutionId + '/failed-lines'
    When method GET
    Then status 200
    * def failedLinesResponse = response
    * def escapedInvalidJsonLine = invalidJsonLine.split('"').join('""')
    * def escapedNoInstanceRdfLine = noInstanceRdfLine.split('"').join('""')
    * def escapedNoTitleInstanceRdfLine = noTitleInstanceRdfLine.split('"').join('""')
    * match failedLinesResponse contains ('12;RDF parsing error;"' + escapedInvalidJsonLine + '"')
    * match failedLinesResponse contains ('78;Empty result returned by rdf4ld library;"' + escapedNoInstanceRdfLine + '"')
    * match failedLinesResponse contains ('90;Could not commit JPA transaction;"' + escapedNoTitleInstanceRdfLine + '"')

    # Step 7: Verify 100 works are created in linked data graph
    * configure headers = testUserHeaders
    * def query = 'title all "bulk import main title"'
    Given path 'search/linked-data/works'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords == rdfCount
    When method GET
    Then status 200
    * match response.totalRecords == rdfCount

    # Step 8: Verify 100 instances are created in inventory application
    Given path 'search/instances'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords == rdfCount
    When method GET
    Then status 200
    * match response.totalRecords == rdfCount
    * match response.instances == '#[10]'
    * def allInstanesHasLinkedDataId = karate.filter(response.instances, x => karate.filter(x.identifiers, i => i.value && i.value.startsWith('(ld) ')).length > 0).length == response.instances.length
    * match allInstanesHasLinkedDataId == true

    # Step 9: Verify one example instance in mod-inventory
    * def query = 'title all "1058 bulk import main title"'
    Given path 'search/instances'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * match response.totalRecords == 1
    * def inventoryInstanceId = response.instances[0].id
    * match inventoryInstanceId == '#string'

    # Step 10: Get the generated marc record for the example instance from srs and validate
    * configure headers = testAdminHeaders
    * def getSourceRecordFormattedCall = call getSourceRecordFormatted { inventoryId: '#(inventoryInstanceId)', idType: 'INSTANCE' }
    * def fields = getSourceRecordFormattedCall.response.parsedRecord.content.fields
    * match fields contains { 001: '#notnull' }
    * match fields contains { 005: '#notnull' }
    * match fields contains { 008: '#notnull' }
    * def field008Value = karate.filter(fields, x => x['008'] != null)[0]['008']
    * match field008Value.substring(7, 11) == '2026'
    * match field008Value.substring(15, 18) == 'cau'
    * match fields contains { 020: { subfields: [ { a: '1058 ISBN' }, { q: '1058 ISBN qualifier' } ], ind1: ' ', ind2: ' ' } }
    * match fields contains { 100: { subfields: [ { a: '1058 person name' }, { e: 'author' }, { '4': 'aut' } ], ind1: ' ', ind2: ' ' } }
    * match fields contains { 245: { subfields: [ { a: '1058 bulk import main title' }, { c: '1058 responsibility statement' } ], ind1: ' ', ind2: ' ' } }
    * match fields contains { 246: { subfields: [ { a: '1058 variant main title 2' } ], ind1: ' ', ind2: '0' } }
    * match fields contains { 264: { subfields: [ { a: 'San Francisco, CA' } ], ind1: ' ', ind2: '1' } }
    * match fields contains { 610: { subfields: [ { a: '1058 fast organization subject heading' }, { z: '1058 place subject heading' } ], ind1: ' ', ind2: ' ' } }
    * match fields contains { 650: { subfields: [ { a: 'Bull Run, 2d Battle, 1862.' }, { '0': 'http://id.loc.gov/authorities/subjects/sh1058' } ], ind1: ' ', ind2: ' ' } }
    * match fields contains { 700: { subfields: [ { a: 'Jones, James E.' }, { c: 'Jr.' }, { '0': 'http://id.loc.gov/authorities/names/n1058' }, { '9': '#notnull' } ], ind1: ' ', ind2: ' ' } }
    * match fields contains { 035: { subfields: [ { a: '#regex ^\\(ld\\) .+$' } ], ind1: 'f', ind2: 'f' } }
    * match fields contains { 999: { subfields: [ { s: '#notnull' }, { l: '#notnull' }, { i: '#(inventoryInstanceId)' } ], ind1: 'f', ind2: 'f' } }
