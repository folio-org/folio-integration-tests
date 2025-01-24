Feature: Create new resource in Linked Data and update it through API

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Create new resource in Linked Data and update it through API
    # Step 1: Create work and instance
    * def workRequest = read('samples/work-request.json')
    * def workResponse = call postResource { resourceRequest: '#(workRequest)' }
    * def workId = workResponse.response.resource['http://bibfra.me/vocab/lite/Work'].id

    * def instanceRequest = read('samples/instance-request.json')
    * def instanceResponse = call postResource { resourceRequest: '#(instanceRequest)' }

    # Step 2: Verify that instance is created in mod-inventory
    * def query = 'title == "api-update Instance main title"'
    * call searchInventoryInstance

    # Step 3: Update the instance in linked-data
    * def instanceId = instanceResponse.response.resource['http://bibfra.me/vocab/lite/Instance'].id
    * def updateInstanceRequest = read('samples/update-instance-request.json')
    * call putResource { id: '#(instanceId)' , resourceRequest: '#(updateInstanceRequest)' }

    # Step 4: Verify that instance is updated in mod-linked-data
    * def query = 'title == "Updated api-update Instance main title"'
    * def searchCall = call searchLinkedDataWork
    * def searchResult = searchCall.response.content[0]
    * match searchResult.titles[0].value == 'api-update Work main title'
    * match searchResult.instances[0].titles[0].value == 'Updated api-update Instance main title'

    # Step 5: Verify updated instance in mod-inventory
    * call searchInventoryInstance

    # Step 6: Verify that the old instance no longer exists in linked-data's mod-search
    * def query = 'title == "api-update Work main title"'
    * def searchCall = call searchLinkedDataWork
    * match karate.sizeOf(searchCall.response.content[0].instances) == 1
    * match searchCall.response.content[0].instances[0].titles[0].value == 'Updated api-update Instance main title'

    # Step 7: Verify that the old instance no longer exists in mod-inventory's mod-search
    * def query = 'title == "api-update Instance main title"'
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * match searchCall.response.instances[0].title == 'Updated api-update Instance main title'