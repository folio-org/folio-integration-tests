Feature: instance-links tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples'
    * def utilPath = 'classpath:spitfire/mod-entities-links/features/samples/util/base.feature'
    * callonce read(utilPath + '@Setup')

  @Positive
  Scenario: Put link - Should link authority to instance
    * def requestBody = read(samplePath + '/links/createLink.json')
    # put link authority to instance
    * def response = call read(utilPath + '@PutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }
    * def link0 = response.link.links[0];
    And match link0.authorityId == authorityId
    And match link0.instanceId == instanceId
    And match link0.bibRecordTag == '100'
    # remove links
    * call read(utilPath + '@RemoveLinks') { extInstanceId: #(instanceId) }

  @Positive
  Scenario: Put link - Should link one authority for two instances
    * def requestBody = read(samplePath + '/links/createLink.json')
    # put link authority for instanceId
    * call read(utilPath + '@PutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }
    # put link authority for secondInstanceId
    And set requestBody.links[0].instanceId = secondInstanceId
    * call read(utilPath + '@PutInstanceLinks') { extInstanceId: #(secondInstanceId), extRequestBody: #(requestBody) }

      # get and validate instance-authority links
    * call read(utilPath + '@GetInstanceLinks') { extInstanceId: #(instanceId) }
    * call read(utilPath + '@GetInstanceLinks') { extInstanceId: #(secondInstanceId) }

    # remove links
    * call read(utilPath + '@RemoveLinks') { extInstanceId: #(instanceId) }
    * call read(utilPath + '@RemoveLinks') { extInstanceId: #(secondInstanceId) }

  @Positive
  Scenario: Put link - Should update tag for existed links
    * def newBibRecordTag1 = '010'
    * def newBibRecordTag2 = '999'
    * def requestBody = read(samplePath + '/links/createTwoLinks.json')

    # first put link request
    * call read(utilPath + '@PutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }

    # second put link request with different bibRecordTag fields
    * requestBody.links[0].bibRecordTag = newBibRecordTag1
    * requestBody.links[1].bibRecordTag = newBibRecordTag2
    * call read(utilPath + '@PutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }

    # get and validate instance-authority links
    * call read(utilPath + '@GetInstanceLinks') { extInstanceId: #(instanceId) }
    And match response.links[0].bibRecordTag == newBibRecordTag1
    And match response.links[1].bibRecordTag == newBibRecordTag2

    # remove links
    * call read(utilPath + '@RemoveLinks') { extInstanceId: #(instanceId) }

  @Positive
  Scenario: Put link - Should save only new links
    * def requestBody1 = read(samplePath + '/links/createLink.json')
    * def requestBody2 = read(samplePath + '/links/createTwoLinks.json')

    * call read(utilPath + '@PutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody1) }
    * call read(utilPath + '@PutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody2) }

    # get and validate instance-authority links
    * call read(utilPath + '@GetInstanceLinks') { extInstanceId: #(instanceId) }
    And match response.totalRecords == 2

    # remove links
    * call read(utilPath + '@RemoveLinks') { extInstanceId: #(instanceId) }

  @Negative
  Scenario: Put link - instanceId not matched with link
    * def randomId = uuid()
    * def requestBody = read(samplePath + '/links/createLink.json')

    # try to put link
    * call read(utilPath + '@TryPutInstanceLinks') { extInstanceId: #(randomId), extRequestBody: #(requestBody) }
    Then match response.errors[0].message == 'Link should have instanceId = ' + randomId
    Then match response.errors[0].parameters[0].value == instanceId

  @Negative
  @Ignore #For now we can link non existed records
  Scenario: Put link - link non existed instance
    * def instanceId = uuid()
    * def requestBody = read(samplePath + '/links/createLink.json')

    # try to put link
    * call read(utilPath + '@TryPutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }
    Then match response.errors[0].message == 'Instance not exist'

  @Negative
  @Ignore #For now we can link non existed records
  Scenario: Put link - link non existed authority
    * def authorityId = uuid()
    * def requestBody = read(samplePath + '/links/createLink.json')

    # try to put link
    * call read(utilPath + '@TryPutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }
    Then match response.errors[0].message == 'Authority not exist'

  @Negative
  Scenario: Put link - bib record tag larger than 100
    * def requestBody = read(samplePath + '/links/createLink.json')

    # try to put link
    And set requestBody.links[0].bibRecordTag = 99999
    * call read(utilPath + '@TryPutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }
    Then match response.errors[0].message == 'must match \"^[0-9]{3}$\"'
    Then match response.errors[0].parameters[0].key == 'links[0].bibRecordTag'

  @Negative
  Scenario: Put link - empty subfields
    * def requestBody = read(samplePath + '/links/createLink.json')

    # try to put link
    And remove requestBody.links[0].bibRecordSubfields
    * call read(utilPath + '@TryPutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }
    Then match response.errors[0].message == 'size must be between 1 and 100'
    Then match response.errors[0].parameters[0].key == 'links[0].bibRecordSubfields'

  @Negative
  Scenario: Put link - subfield more than one character
    * def requestBody = read(samplePath + '/links/createLink.json')

    # try to put link
    And set requestBody.links[0].bibRecordSubfields[0] = 'ab'
    * call read(utilPath + '@TryPutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }
    Then match response.errors[0].message == 'Max Bib record subfield length is 1'
    Then match response.errors[0].parameters[0].key == 'bibRecordSubfields'

  @Positive
  Scenario: Post bulk count links - should count links for two authorities
    * def requestBody = read(samplePath + '/links/createTwoLinks.json')
    * def ids = read(samplePath + '/links/uuidCollection.json')
    # put instance link for two authorities(authorityId and secondAuthorityId)
    * call read(utilPath + '@PutInstanceLinks') { extInstanceId: #(instanceId), extRequestBody: #(requestBody) }

    # count links
    * call read(utilPath + '@PostCountLinks') { extIds: #(ids) }
    Then match response.links[0].totalLinks == 1
    Then match response.links[1].totalLinks == 1
    Then match response.links[*].id contains any [#(authorityId), #(secondAuthorityId)]

    # remove links
    * call read(utilPath + '@RemoveLinks') { extInstanceId: #(instanceId) }

  @Positive
  Scenario: Post bulk count links - should count as zero for non existing links
    * def ids = read(samplePath + '/links/uuidCollection.json')

    # count links
    * call read(utilPath + '@PostCountLinks') { extIds: #(ids) }
    Then match response.links[0].totalLinks == 0
    Then match response.links[1].totalLinks == 0
    Then match response.links[*].id contains any [#(authorityId), #(secondAuthorityId)]

  @Positive
  Scenario: Post bulk count links - empty ids array
    * def ids = {"ids": []}

    # count links
    * call read(utilPath + '@PostCountLinks') { extIds: #(ids) }
    Then match response.links == []