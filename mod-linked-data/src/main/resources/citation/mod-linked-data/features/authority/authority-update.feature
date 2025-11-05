Feature: Authority update

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: create authority and work, then update authority
    # Step 1: create an authority
    * def sourceRecordRequest = read('samples/authority_person.json')
    * def postAuthorityCall = call postSourceRecordToStorage
    And match postAuthorityCall.response.qmRecordId == '#notnull'

    # Step 2: search for the created authority
    * def query = 'headingRef < "PAVELTEST" or headingRef >= "PAVELTEST"'
    * def browseAuthorityCall = call browseAuthority
    And match browseAuthorityCall.response.items[0].authority.id == '#notnull'
    * def inventoryId = browseAuthorityCall.response.items[0].authority.id

    # Step 3: get SRS id of found authority
    * def idType = 'AUTHORITY'
    * def getAuthoritySrsCall = call getSourceRecordFormatted
    And match getAuthoritySrsCall.response.id == '#notnull'
    * def sourceRecordId = getAuthoritySrsCall.response.id

    # Step 4: create a work linking it to the authority by SrsId
    * def resourceRequest = read('samples/work_with_authority.json')
    * def postWorkCall = call postResource
    * def workResponse = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work']
    And match workResponse.id == '#notnull'
    And match workResponse._creatorReference[0].label == 'PAVELTEST'
    * def workId = workResponse.id

    # Step 5: update the authority adding a birth date
    * def sourceRecordUpdateRequest = read('samples/authority_person_update.json')
    * def putAuthorityCall = call putSourceRecordToStorage

    # Sleep for 5 seconds to let kafka messages be handled
    * sleep(5)

    # Step 6: get and check the initial authority graph
    * def resourceId = workResponse._creatorReference[0].id
    * def getCreatedAuthorityGraphCall = call getResourceGraph
    * def createdAuthorityGraphResponse = getCreatedAuthorityGraphCall.response
    And match createdAuthorityGraphResponse.label == 'PAVELTEST'
    And match createdAuthorityGraphResponse.doc['http://library.link/vocab/resourcePreferred'][0] == 'false'
    And match createdAuthorityGraphResponse.outgoingEdges.edges['https://bibfra.me/vocab/lite/replacedBy'][0] == '#notnull'
    * def updatedAuthorityId = createdAuthorityGraphResponse.outgoingEdges.edges['https://bibfra.me/vocab/lite/replacedBy'][0]

    # Step 7: get and check the updated authority graph
    * def resourceId = updatedAuthorityId
    * def getUpdatedAuthorityGraphCall = call getResourceGraph
    * def updatedAuthorityGraphResponse = getUpdatedAuthorityGraphCall.response
    And match updatedAuthorityGraphResponse.label == 'PAVELTEST, 1986'
    And match updatedAuthorityGraphResponse.doc['http://library.link/vocab/resourcePreferred'][0] == 'true'

    # Step 8: get the work and check it's returned with updated authority
    * def id = workId
    * def getWorkCall = call getResource
    * def workUpdatedResponse = getWorkCall.response.resource['http://bibfra.me/vocab/lite/Work']
    And match workUpdatedResponse._creatorReference[0].id == '#(updatedAuthorityId.toString())'



