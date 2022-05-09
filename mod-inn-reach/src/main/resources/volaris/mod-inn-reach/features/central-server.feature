@parallel=false
Feature: Central server

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_inn_reach_integration2'}
#    * callonce login testAdmin
#    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
#    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def mockServer = karate.start(mockPath + 'central-server/central-server-mock.feature')
    * def port = mockServer.port

    * def notExistedCentralServerId1 = globalCentralServerId1

  Scenario: Check not existed central server
    * configure headers = headersUser
    * print 'Check not existed central server'
    Given path '/inn-reach/central-servers', notExistedCentralServerId1
    * configure headers = headersUser
    When method GET
    Then status 404
    
  Scenario: Test mock
    * print 'Testing mock'
    Given url 'http://localhost:' + port + '/non-existing'
    When method GET
    Then status 404
