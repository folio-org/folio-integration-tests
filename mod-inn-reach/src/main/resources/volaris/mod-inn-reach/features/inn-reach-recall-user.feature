@parallel=false
Feature: Inn reach recall user

  Background:
    * url baseUrl + '/inn-reach/central-servers'

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = get[0] response.centralServers[?(@.name == 'Central server 1')]
    * def centralServer2 = get[0] response.centralServers[?(@.name == 'Central server 2')]

    * def pathCentralServer1 = centralServer1.id + '/inn-reach-recall-user'
    * def pathCentralServer2 = centralServer2.id + '/inn-reach-recall-user'
    * def pathUnknownCentralServer = '8fbe6ffe-3809-451d-b34e-11ff01004396/inn-reach-recall-user'

  Scenario: Create and get recall user setting
    * print 'Create recall user'
    * def recallUserId = '98fe1416-e389-40cd-8fb4-cb1cfa2e3c55'
    Given path pathCentralServer1
    And request read(samplesPath + 'recall-user/recall-user.json')
    When method POST
    Then status 200
    And match response.userId == recallUserId

  Scenario: Not found recall user setting
    * print 'Recall user setting is not found'
    Given path pathCentralServer2
    When method GET
    Then status 200
    And match response.userId == null

  Scenario: Unknown central server
    * print 'Get recall user for unknown central server'
    Given path pathUnknownCentralServer
    When method GET
    Then status 404

  Scenario: Update central server recall user
    * print 'Update recall user'
    * def recallUserId = '4f5eb2a0-f3e1-4448-a5b3-8e4b0d4433b1'
    Given path pathCentralServer1
    And request read(samplesPath + 'recall-user/recall-user.json')
    When method PUT
    Then status 204

    Given path pathCentralServer1
    When method GET
    Then status 200
    And match response.userId == recallUserId

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')

