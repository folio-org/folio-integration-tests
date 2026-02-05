Feature: Create Work connected to Hubs via API
  Background:
    * url baseUrl

    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Create Hub resources, then create Work connected to Hub via API & verify
    # Create a new MARC BIB record in SRS. This MARC contains fields related to HUB (600 $t etc)
    * configure headers = testAdminHeaders
    * def sourceRecordRequest = read('samples/srs-request-with-hub.json')
    * call postSourceRecordToStorage

    # Import the MARC BIB record into Graph. This will create a HUB resource in the graph
    * configure headers = testUserHeaders
    * def query = 'title all "Trpʻoba camebultʻa"'
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * def inventoryInstanceIdFromSearchResponse = searchCall.response.instances[0].id
    * call postImport { inventoryId: "#(inventoryInstanceIdFromSearchResponse)" }

    # Search for the created Hub resource
    * def query = 'label="Barbakʻaże, Datʻo"'
    * def searchHubCall = call searchLinkedDataHub
    * def hubResourceId = searchHubCall.response.content[0].id

    # Create another Work resource via API connected to the newly created Hub resource
    * def workRequest = read('samples/work-request.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    * def workId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'].id

    # Create an Instance resource via API connected to the created Work
    * def instanceRequest = read('samples/instance-request.json')
    * def postInstanceCall = call postResource { resourceRequest: '#(instanceRequest)' }
    * def instance = postInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance']
    * def instanceId = instance.id

    # Verify that the derived MARC fields contains marc 240
    * def getMarcCall = call getDerivedMarc { resourceId:  '#(instanceId)' }
    * def fields = getMarcCall.response.parsedRecord.content.fields
    * match fields contains { "240": { "subfields": [ { "a": "Barbakʻaże, Datʻo. 1966-. Trpʻoba camebultʻa" }, { "a": "Trpʻoba camebultʻa" } ], "ind1": " ", "ind2": " " } }