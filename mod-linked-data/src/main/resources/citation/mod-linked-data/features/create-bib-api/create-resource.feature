Feature: Create Work and Instance resource using API

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
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
    And match postInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'] contains only deep expectedInstanceResponse
    * def instanceId = postInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].id