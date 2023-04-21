Feature: Root feature that runs all other mod-data-export-spring features

  Background:
    * url baseUrl
    * callonce login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * callonce variables

  Scenario: Run all mod-data-export-spring features
    * call read('classpath:thunderjet/mod-data-export-spring/features/edifact-orders-export.feature')