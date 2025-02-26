Feature: Integration with mod-invetnory for new Instances: Outbound

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Should create instance in mod-inventory
    # Search Instance in mod-search and retrieve ID of the instance created
    * def query = 'title all "create-bib-title"'
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * def inventoryInstanceId = searchCall.response.instances[0].id

    # Assert contents of the newly created instance
    * def expectedInventoryResponse = read('samples/inventory-expected-response.json')
    * def getInventoryInstanceCall = call getInventoryInstance { id: '#(inventoryInstanceId)' }
    * def hrid = getInventoryInstanceCall.response.hrid
    And match getInventoryInstanceCall.response contains expectedInventoryResponse

  Scenario: Instance ID in datagraph should be same as the instance ID in mod-inventory
    * def query = 'title all "create-bib-title"'
    * def searchCall = call searchInventoryInstance
    * def instanceIdInInventory = searchCall.response.instances[0].id

    * def searchLinkedDataCall = call searchLinkedDataWork
    * def resourceId = searchLinkedDataCall.response.content[0].instances[0].id
    * def getResourceCall = call getResource { id: "#(resourceId)" }
    * def instanceIdInDatGraph = getResourceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata.inventoryId

    * match instanceIdInInventory == instanceIdInDatGraph