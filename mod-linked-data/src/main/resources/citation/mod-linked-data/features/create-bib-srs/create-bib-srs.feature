Feature: Integration with SRS for new Instances: Inbound

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Create Marc Bib in SRS and validate new Instance and Work in mod-linked-data
    # Create a new MARC bib record in SRS
    * def srsBibRequest = read('samples/srs-request.json')
    * call postBibToSrs

    # Search for the new instance in linked-data's mod-search
    * def query = 'title all "Silent storms"'
    * def expectedSearchResponse = read('samples/expected-search-response.json')
    * def searchCall = call searchLinkedDataWork
    * def searchResult = searchCall.response.content[0]
    * match searchResult contains expectedSearchResponse

    # Get the new work from mod-linked-data & validate it
    * def getWorkCall = call getResource { id: "#(searchResult.id)" }
    And match getWorkCall.response.resource['http://bibfra.me/vocab/lite/Work']['http://bibfra.me/vocab/marc/title'][0]['http://bibfra.me/vocab/marc/Title']['http://bibfra.me/vocab/marc/mainTitle'] == ['Silent storms,']

    # Get the new instance from mod-linked-data & validate it
    * def getInstanceCall = call getResource { id: "#(searchResult.instances[0].id)" }
    And match getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/marc/title'][0]['http://bibfra.me/vocab/marc/Title']['http://bibfra.me/vocab/marc/mainTitle'] == ['Silent storms,']
    And match getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata ==
    """
    {
      "source": "MARC",
      "inventoryId": "#notnull",
      "srsId": "#notnull"
    }
    """

    # Get the new instance from mod-inventory & validate it
    * def inventoryInstanceId = getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata.inventoryId
    * def getInventoryInstanceCall = call getInventoryInstance { id: "#(inventoryInstanceId)" }
    And match getInventoryInstanceCall.response.source == 'MARC'
    And match getInventoryInstanceCall.response.title == 'Silent storms, by Ernest Poole.'

    # Ensure that mod-linked-data is not sending a create instance message back to mod-inventory, which would have
    # resulted in a duplicate instance being created in mod-inventory
    # Do the search after 5 seconds to give enough time for the message to be processed, if it was sent
    * def query = 'title all "Silent storms"'
    * eval java.lang.Thread.sleep(5000)
    * def searchCall = call searchInventoryInstance
    * match searchCall.response.totalRecords == 1