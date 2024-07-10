Feature: Integration with mod-invetnory: Outbound

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Should create instance in mod-inventory
    # Create Work in linked data
    * def workRequest = read('samples/work-request.json')
    * call postResource { resourceRequest: '#(workRequest)' }
    * call searchWork { query: 'title == "The main title"', validateInstance: false }

    # Create Instance in linked data
    * def instanceRequest = read('samples/instance-request.json')
    * call postResource { resourceRequest: '#(instanceRequest)' }

    # Search Instance in mod-search and retrieve ID of the instance created
    * def query = 'title all "title"'
    * def searchCall = call searchInventory
    * print searchCall.response
    * match searchCall.response.totalRecords == 1

    * def instance = searchCall.response.instances[0]
    * print instance
    * match instance contains { source: 'LINKED_DATA' }