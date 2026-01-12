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

  @verifyInventoryInstanceUpdated
  Scenario: Verify instance source is updated to LINKED_DATA
    * def getInventoryInstanceCall = call getInventoryInstance { id: "#(inventoryInstanceIdFromSearchResponse)" }
    And match getInventoryInstanceCall.response.source == 'LINKED_DATA'