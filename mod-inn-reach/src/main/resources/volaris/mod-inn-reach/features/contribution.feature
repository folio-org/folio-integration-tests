#@ignore
@parallel=false
Feature: Cancel Current Contribution

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * callonce variables
    * def notExistedCentralServerId = globalCentralServerId1

  Scenario: Get current contribution by server id
    * print 'Get current contribution by server id'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/contributions/current'
    When method GET
    Then status 200
#
  Scenario: Cancel current contribution
    * call pause 10000
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/contributions/current'
    When method DELETE
    Then status 204

#
  # Negative Scenarios

  Scenario: Cancel current contribution
    * call pause 10000
    Given path '/inn-reach/central-servers/' + notExistedCentralServerId + '/contributions/current'
    When method DELETE
    Then status 204

