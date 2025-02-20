Feature: Failed Fields State Management
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * if (!karate.get('failedFields')) karate.set('failedFields', [])

  Scenario: Add Failed Field
    * def columnName =  karate.get('columnName')
    * karate.set('failedFields', karate.appendTo(karate.get('failedFields'), columnName))
    * karate.set('result', karate.get('failedFields'))

  Scenario: Get Failed Fields
    * karate.set('result', karate.get('failedFields'))