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
    And match link0.linkingRuleId == 1
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