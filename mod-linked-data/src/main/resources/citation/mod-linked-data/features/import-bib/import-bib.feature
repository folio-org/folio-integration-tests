Feature: Integration with SRS for import flow

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Import MARC BIB record from SRS to linked-data
    # Step 1: Create a new MARC bib record in SRS
    * def sourceRecordRequest = read('samples/srs-request.json')
    * call postSourceRecordToStorage

    # Step 2: Verify new instance in mod-inventory
    * def query = 'title all "Silent storms"'
    * callonce read('util/verify.feature@verifyInventoryInstance') { expectedSource: 'MARC' }

    # Step 3: Ensure that resource is not created in linked-data
    # Do the call after 5 seconds to give enough time for the message to be processed, if it was sent
    * sleep(5)
    Given path '/linked-data/resource/metadata/' + inventoryInstanceIdFromSearchResponse + '/id'
    When method GET
    Then status 404

    # Step 4: Verify that instance can be imported
    * callonce read('util/verify.feature@verifyInstanceImportIsSupported')

    # Step 5: Preview resource
    * def getPreviewCall = call getResourcePreview { inventoryId: "#(inventoryInstanceIdFromSearchResponse)" }
    And match getPreviewCall.response.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/library/title'][0]['http://bibfra.me/vocab/library/Title']['http://bibfra.me/vocab/library/mainTitle'] == ["Silent storms,"]
    And match getPreviewCall.response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata ==
      """
      {
        "source": "MARC",
        "inventoryId": "#notnull",
        "srsId": "#notnull"
      }
      """

    # Step 6: Import instance
    * call postImport { inventoryId: "#(inventoryInstanceIdFromSearchResponse)" }

    # Step 7: Verify that an instance and work are created in linked-data
    * callonce read('util/verify.feature@verifyInstanceAndWork')

    # Step 8: Verify that source of instance is changed to LINKED_DATA
    * callonce read('util/verify.feature@verifyInventoryInstanceUpdated')

    # Step 9: Ensure that mod-linked-data is not sending a create instance message back to mod-inventory, which would have
    # resulted in a duplicate instance being created in mod-inventory
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1

