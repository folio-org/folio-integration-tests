Feature: Create Work and Instance resource using API

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: create work and instance resources
    # Create work
    * def workRequest = read('../samples/work-request.json')
    * def expectedWorkResponse = read('../samples/work-expected-response.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    And match postWorkCall.response contains expectedWorkResponse
    * call searchLinkedDataWork { query: 'title == "The main title"', validateInstance: false }

    # Create instance
    * def instanceRequest = read('../samples/instance-request.json')
    * def expectedInstanceResponse = read('../samples/instance-expected-response.json')
    * def postInstanceCall = call postResource { resourceRequest: '#(instanceRequest)' }
    And match postInstanceCall.response contains expectedInstanceResponse