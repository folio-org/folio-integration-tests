
@parallel=false
Feature: Contribution

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def centralServer2 = response.centralServers[1]

  @Undefined
  Scenario: Get current contribution by server id
    * print 'Get current contribution by server id'

  Scenario: Get empty contribution history by server id

    * print 'Get empty contribution history by server id'
    Given path '/inn-reach/central-servers/' + centralServer2.id + '/contributions/history'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  @Undefined
  Scenario: Start initial contribution
    * print 'Start initial contribution'
