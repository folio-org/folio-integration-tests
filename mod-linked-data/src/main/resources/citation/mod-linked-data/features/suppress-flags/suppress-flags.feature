Feature: Suppress Flags in Inventory

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Create an instance in Inventory, change Suppress Flags and check their values in search index
    # Create a new instance in Linked data
    * def workRequest = read('samples/create-work-request.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    * def workId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'].id
    * def resourceRequest = read('samples/create-instance-request.json')
    * call postResource

    # Search for the new instance in Inventory's search
    * def query = 'title all "suppress_flags"'
    * def inventoryInstanceSearchResponse = call searchInventoryInstance
    * def instanceSearch = inventoryInstanceSearchResponse.response.instances[0]
    * def inventoryInstanceId = instanceSearch.id

    # Update suppress flags
    * def getInventoryInstanceResponse = call getInventoryInstance { id: "#(inventoryInstanceId)" }
    * def inventoryInstance = getInventoryInstanceResponse.response
    * eval inventoryInstance['staffSuppress'] = true
    * eval inventoryInstance['discoverySuppress'] = true
    * call putInventoryInstance

    # Search the Check Suppress Flags values
    Given path 'search/linked-data/works'
    And param query = query
    And retry until response.content[0].instances[0].suppress && response.content[0].instances[0].suppress.staff == true && response.content[0].instances[0].suppress.fromDiscovery == true
    When method GET
    Then status 200
