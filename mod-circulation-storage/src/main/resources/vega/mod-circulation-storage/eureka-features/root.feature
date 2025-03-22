Feature: Root feature that runs all other mod-circulation-storage features

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)','Accept': '*/*'  }

  Scenario: Run all mod-circulation features
    * call read('classpath:vega/mod-circulation-storage/eureka-features/request-policies.feature')
