Feature: Create Work and Instance resource using API

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: create work and instance resources
    * def workRequest = read('samples/work-request.json')
    * def expectedWorkResponse = read('samples/work-expected-response.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    And match postWorkCall.response contains expectedWorkResponse

    * def instanceRequest = read('samples/instance-request.json')
    * def expectedInstanceResponse = read('samples/instance-expected-response.json')
    * def postInstanceCall = call postResource { resourceRequest: '#(instanceRequest)' }
    And match postInstanceCall.response contains expectedInstanceResponse