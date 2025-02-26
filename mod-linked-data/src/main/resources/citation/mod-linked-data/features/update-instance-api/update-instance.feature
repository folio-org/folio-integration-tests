Feature: Create new MARC bib record in SRS, import and update the instance through linked-data: Outbound

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Create new MARC bib record in SRS, import and update the instance through linked-data
    # Step 1: Create a new MARC bib record in SRS
    * def sourceRecordRequest = read('samples/srs-request.json')
    * call postSourceRecordToStorage

    # Step 2: Verify new instance in mod-inventory
    * def query = 'title all "Test Instance"'
    * callonce read('util/verify.feature@verifyInventoryInstance') { expectedSource: 'MARC' }

    # Step 3: Import instance
    * call postImport { inventoryId: "#(inventoryInstanceIdFromSearchResponse)" }

    # Step 4: Verify that an instance and work are created in linked-data
    * def expectedSource = 'LINKED_DATA'
    * callonce read('util/verify.feature@verifyInstanceAndWork') { expectedInstanceTitle: 'Test Instance', expectedWorkTitle: 'Test Instance' }

    # Step 5: Verify updated source of instance in mod-inventory
    Given path 'inventory/instances/' + inventoryInstanceIdFromSearchResponse
    And retry until response.source == expectedSource
    When method get
    Then status 200

    # Step 6: Update the instance in linked-data
    * def updateInstanceRequest = read('samples/update-instance-request.json')
    * call putResource { id: '#(instanceId)' , resourceRequest: '#(updateInstanceRequest)' }

    # Step 7: Verify that instance is updated in mod-linked-data
    * def query = 'title == "Updated Test Instance"'
    * callonce read('util/verify.feature@verifyInstanceAndWork') { expectedInstanceTitle: 'Updated Test Instance', expectedWorkTitle: 'Test Instance' }

    # Step 8: Verify updated instance in mod-inventory
    * callonce read('util/verify.feature@verifyInventoryInstance')

    # Step 9: Verify that the old instance no longer exists in linked-data's mod-search
    * def query = 'title == "Test Instance"'
    * def searchCall = call searchLinkedDataWork
    * match searchCall.response.totalRecords == 1

    # Step 10: Verify that the old instance no longer exists in mod-inventory's mod-search
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * match searchCall.response.instances[0].title == 'Updated Test Instance Updated John Doe'