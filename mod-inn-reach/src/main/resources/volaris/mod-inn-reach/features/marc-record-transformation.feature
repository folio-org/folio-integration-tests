@ignore
@parallel=false
Feature: MARC record transformation

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]

  Scenario: Transform MARC record
    * print 'Transform MARC record'
    * def instanceId = '601a8dc4-dee7-48eb-b03f-d02fdf0debd0'

    Given path 'inn-reach/central-servers/' + centralServer1.id + '/marc-record-transformation/' + instanceId
    When method GET
    Then status 200
    And match response == read(samplesPath + 'marc-transformation/transformed-marc-record.json')

  Scenario: Transform MARC record - unknown instance
    * print 'Transform MARC record - unknown instance'
    * def instanceId = uuid()

    Given path 'inn-reach/central-servers/' + centralServer1.id + '/marc-record-transformation/' + instanceId
    When method GET
    Then status 500

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')
