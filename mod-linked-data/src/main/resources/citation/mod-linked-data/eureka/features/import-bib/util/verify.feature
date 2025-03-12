Feature: Util functions for verifying instance and work

  @verifyInventoryInstance
  Scenario: Validate instance in mod-inventory
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * def inventoryInstanceIdFromSearchResponse = searchCall.response.instances[0].id
    * def inventoryInstaceCall = call getInventoryInstance { id: "#(inventoryInstanceIdFromSearchResponse)" }
    And match inventoryInstaceCall.response.source == expectedSource

  @verifyInstanceImportIsSupported
  Scenario: Verify that instance can be imported into mod-linked-data
    * def supportCheckCall = call getResourceSupportCheck { inventoryId: "#(inventoryInstanceIdFromSearchResponse)"}
    And match supportCheckCall.response == true

  @verifyInstanceAndWork
  Scenario: Search for the new instance in linked-data's mod-search and validate work and instance from mod-linked-data
    * def expectedSearchResponse = read('samples/expected-search-response.json')
    * def searchCall = call searchLinkedDataWork
    * def searchResult = searchCall.response.content[0]
    * match searchResult contains expectedSearchResponse
    * def getWorkCall = call getResource { id: "#(searchResult.id)" }
    And match getWorkCall.response.resource['http://bibfra.me/vocab/lite/Work']['http://bibfra.me/vocab/marc/title'][0]['http://bibfra.me/vocab/marc/Title']['http://bibfra.me/vocab/marc/mainTitle'] == ['Silent storms,']
    * def getInstanceCall = call getResource { id: "#(searchResult.instances[0].id)" }
    And match getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/marc/title'][0]['http://bibfra.me/vocab/marc/Title']['http://bibfra.me/vocab/marc/mainTitle'] == ['Silent storms,']
    And match getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata ==
      """
      {
        "source": "LINKED_DATA",
        "inventoryId": "#notnull",
        "srsId": "#notnull"
      }
      """
    And match getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata.inventoryId == inventoryInstanceIdFromSearchResponse

  @verifyInventoryInstanceUpdated
  Scenario: Verify instance source is updated to LINKED_DATA
    * def getInventoryInstanceCall = call getInventoryInstance { id: "#(inventoryInstanceIdFromSearchResponse)" }
    And match getInventoryInstanceCall.response.source == 'LINKED_DATA'