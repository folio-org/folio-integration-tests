Feature: Create Work and Instance resource using API

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: create work and instance resources through API
    * def workRequest = read('samples/work-request.json')
    * def expectedWorkResponse = read('samples/work-expected-response.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    And match postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'] contains only deep expectedWorkResponse
    * def workId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'].id

    * def instanceRequest = read('samples/instance-request.json')
    * def expectedInstanceResponse = read('samples/instance-expected-response.json')
    * def postInstanceCall = call postResource { resourceRequest: '#(instanceRequest)' }
    * def instance = postInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance']
    * match instance contains only deep expectedInstanceResponse
    * def instanceId = instance.id
    * def instanceMainTitleId = instance['http://bibfra.me/vocab/library/title'].find(x => x['http://bibfra.me/vocab/library/Title'])['http://bibfra.me/vocab/library/Title'].id