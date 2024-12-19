Feature: Tenant object in mod-consortia

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }


  Scenario: Index instances

    Given path '/search/index/instance-records/reindex/full'
    When method POST
