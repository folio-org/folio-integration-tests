Feature: Integration with mod-invetnory: Outbound

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Should create instance in mod-inventory
    # Search Instance in mod-search and retrieve ID of the instance created
    * def query = 'title all "title"'
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1
    * def instanceId = searchCall.response.instances[0].id

    # Assert contents of the newly created instance
    * def expectedInventoryResponse = read('../samples/inventory-expected-response.json')
    Given path 'inventory/instances/' + instanceId
    When method get
    Then status 200
    And match response contains expectedInventoryResponse