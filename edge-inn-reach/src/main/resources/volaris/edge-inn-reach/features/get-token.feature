@ignore
@parallel=false
Feature: Get Token

  Background:
    * callonce variables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]

  @Undefined
  Scenario: Test
    * print 'Test'

  @Undefined
  Scenario: call central server
    * callonce
    * print 'Test'
