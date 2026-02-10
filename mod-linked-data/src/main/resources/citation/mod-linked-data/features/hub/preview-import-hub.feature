Feature: Preview and import Hub from a remote RDF URL
  Background:
    * url baseUrl

    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Preview and import Hub, then verify it is indexed
    # Step 1: Setup - Create a new MARC authority person record, who is the creator of the Hub
    * configure headers = testAdminHeaders
    * def sourceRecordRequest = read('samples/authority_person-eckardt.json')
    * def postAuthorityCall = call postSourceRecordToStorage
    * match postAuthorityCall.response.qmRecordId == '#notnull'
    * def query = '(lccn="no98031922")'
    * call searchAuthority

    # Step 2: Preview the Hub
    * configure headers = testUserHeaders
    * def hubUri = 'https://id.loc.gov/resources/hubs/0f11341f-5bb5-9e64-110f-6bb4782fc615.json'
    * def preveHubCall = call previewHub { hubUri: '#(hubUri)' }
    * match preveHubCall.response.resource['http://bibfra.me/vocab/lite/Hub']['http://bibfra.me/vocab/library/title'][0]['http://bibfra.me/vocab/library/Title']['http://bibfra.me/vocab/library/mainTitle'][0] == 'Pulse-echo'
    * def creator = preveHubCall.response.resource['http://bibfra.me/vocab/lite/Hub']['_creatorReference'][0]
    * match creator.label == 'Eckardt, Jason, 1971'
    * match creator.type == 'http://bibfra.me/vocab/lite/Person'
    * match creator.isPreferred == true

    # Wait for 5 seconds and ensure that Hub is not avaiable in search results before import
    * sleep(5)
    * def query = 'label="Eckardt, Jason, 1971-. Pulse-echo"'
    Given path 'search/linked-data/hubs'
    And param query = query
    And param limit = 10
    And param offset = 0
    And response.totalRecords == 0

    # Step 3: Import the Hub
    * def importHubCall = call importHub { hubUri: '#(hubUri)' }
    * match importHubCall.response.resource['http://bibfra.me/vocab/lite/Hub']['http://bibfra.me/vocab/library/title'][0]['http://bibfra.me/vocab/library/Title']['http://bibfra.me/vocab/library/mainTitle'][0] == 'Pulse-echo'
    * def creator = importHubCall.response.resource['http://bibfra.me/vocab/lite/Hub']['_creatorReference'][0]
    * match creator.label == 'Eckardt, Jason, 1971'
    * match creator.type == 'http://bibfra.me/vocab/lite/Person'
    * match creator.isPreferred == true

    * def searchHubCall = call searchLinkedDataHub