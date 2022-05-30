Feature: mod-gobi integration tests

  Background:
    * url baseUrl

    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  # Init global data
  Scenario: GOBI api tests
    Given call read('features/gobi-api-tests.feature')