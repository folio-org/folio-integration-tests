Feature: Verify linked data graph using APIs

  Scenario: Vefify instance in mod-search
    * def expectedSearchResponse = read('samples/expected-search-response.json')
    * def searchCall = call searchLinkedDataWork
    * def searchResult = searchCall.response.content[0]
    * match searchResult.languages contains only expectedSearchResponse.languages
    * match searchResult.classifications contains only deep expectedSearchResponse.classifications
    * match searchResult.subjects contains only expectedSearchResponse.subjects
    * match searchResult.titles contains only deep expectedSearchResponse.titles
    * match searchResult.contributors contains only deep expectedSearchResponse.contributors
    * def expectedInstance = expectedSearchResponse.instances[0]
    * def actualInstance = searchResult.instances[0]
    * match actualInstance.identifiers contains only deep expectedInstance.identifiers
    * match actualInstance.titles contains only deep expectedInstance.titles
    * match actualInstance.publications contains only deep expectedInstance.publications
    * match actualInstance.notes contains only deep expectedInstance.notes

  Scenario: Verify work resource
    * def getWorkCall = call getResource { id: "#(searchResult.id)" }
    * def workTitles = getWorkCall.response.resource['http://bibfra.me/vocab/lite/Work']['http://bibfra.me/vocab/library/title']
    * def workMainTitleObj = workTitles.filter(x => x['http://bibfra.me/vocab/library/Title']).map(x => x['http://bibfra.me/vocab/library/Title'])[0]
    * match workMainTitleObj['http://bibfra.me/vocab/library/mainTitle'][0] == 'Silent storms,'

  @C627246
  Scenario: Verify that the creator has 'isPreferred' set to true as it is a controlled authority
    * def expectedCreator = [{ id: '#notnull', label: 'Edgell, David L., Sr., David Lee, 1938', isPreferred: true, type: 'http://bibfra.me/vocab/lite/Person', roles: ['http://bibfra.me/vocab/relation/author']}]
    * match getWorkCall.response.resource['http://bibfra.me/vocab/lite/Work']['_creatorReference'] == expectedCreator

  Scenario: Fetch the instance resource and validate
    * def getInstanceCall = call getResource { id: "#(searchResult.instances[0].id)" }
    * def instanceTitles = getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/library/title']
    * def instanceMainTitleObj = instanceTitles.filter(x => x['http://bibfra.me/vocab/library/Title']).map(x => x['http://bibfra.me/vocab/library/Title'])[0]
    * match instanceMainTitleObj['http://bibfra.me/vocab/library/mainTitle'][0] == 'Silent storms,'

    And match getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata ==
      """
      {
        "source": "LINKED_DATA",
        "inventoryId": "#notnull",
        "srsId": "#notnull"
      }
      """
    And match getInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].folioMetadata.inventoryId == inventoryInstanceIdFromSearchResponse
