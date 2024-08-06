Feature: Util functions for verifying instance and work
  @verifyInstanceAndWork
  Scenario: Verify instance and work in mod-linked-data
    * def searchCall = call searchLinkedDataWork
    * def searchResult = searchCall.response.content[0]
    * match searchResult.titles[0].value == expectedWorkTitle
    * match searchResult.instances[0].titles[0].value == expectedInstanceTitle
    * def workId = searchResult.id
    * def instanceId = searchResult.instances[0].id
    * def getInstanceCall = call getResource { id: "#(instanceId)" }
    * match getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].instanceMetadata.source == expectedSource
    * def inventoryInstanceId = getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].instanceMetadata.inventoryId

  @verifyInventoryInstance
  Scenario: Veriry instance in mod-inventory
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * def inventoryInstanceIdFromSearchResponse = searchCall.response.instances[0].id
    * match inventoryInstanceIdFromSearchResponse == inventoryInstanceId
    * def inventoryInstaceCall = call getInventoryInstance {id: "#(inventoryInstanceId)"}
    And match inventoryInstaceCall.response.source == expectedSource
