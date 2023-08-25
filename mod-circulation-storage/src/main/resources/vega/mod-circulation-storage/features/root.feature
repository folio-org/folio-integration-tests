Feature: Root feature that runs all other mod-circulation features

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Run all mod-circulation features
    * call read('classpath:vega/mod-circulation-storage/features/request-policies.feature')
