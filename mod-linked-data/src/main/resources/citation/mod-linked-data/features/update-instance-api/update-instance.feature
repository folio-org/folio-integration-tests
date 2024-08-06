Feature: Create new MARC bib record in SRS and update the instance through linked-data: Outbound

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Create new MARC bib record in SRS and update the instance through linked-data
    # Step 1: Create a new MARC bib record in SRS
    * def srsBibRequest = read('samples/srs-request.json')
    * call postBibToSrs

    # Step 2: Verify that an instance and work are created in linked-data
    * def query = 'title all "Test Instance"'
    * def expectedSource = 'MARC'
    * callonce read('util/verify.feature@verifyInstanceAndWork') { expectedInstanceTitle: 'Test Instance', expectedWorkTitle: 'Test Instance' }

    # Step 3: Verify new instance in mod-inventory
    * callonce read('util/verify.feature@verifyInventoryInstance')

    # Step 4: Update the instance in linked-data
    * def updateInstanceRequest = read('samples/update-instance-request.json')
    * call putResource { id: '#(instanceId)' , resourceRequest: '#(updateInstanceRequest)' }

    # Step 5: Verify that instance is updated in mod-linked-data
    * def query = 'title == "Updated Test Instance"'
    * def expectedSource = 'LINKED_DATA'
    * callonce read('util/verify.feature@verifyInstanceAndWork') { expectedInstanceTitle: 'Updated Test Instance', expectedWorkTitle: 'Test Instance' }

    # Step 6: Verify updated instance in mod-inventory
    * callonce read('util/verify.feature@verifyInventoryInstance')

    # Step 7: Verify that the old instance no longer exists in linked-data's mod-search
    * def query = 'title == "Test Instance"'
    * def searchCall = call searchLinkedDataWork
    * match searchCall.response.totalRecords == 1

    # Step 8: Verify that the old instance no longer exists in mod-inventory's mod-search
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * match searchCall.response.instances[0].title == 'Updated Test Instance Updated John Doe'