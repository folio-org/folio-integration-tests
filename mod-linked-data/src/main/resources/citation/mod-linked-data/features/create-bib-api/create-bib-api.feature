Feature: Create Work and Instance resource using API & validate that they are created in mod-inventory and mod-search

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Create Work and Instance resource using API & validate that they are created in mod-inventory and mod-search
    * call read('create-resource.feature')
    * call read('inventory-outbound.feature')
    * call read('search-outbound.feature')