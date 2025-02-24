Feature: Failed Fields State Management

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * if (!karate.get('failedFields')) karate.set('failedFields', [])

  Scenario: Add Failed Field
    * def columnName = karate.get('columnName')
    * def failedFields = karate.get('failedFields')
    * karate.set('failedFields', karate.appendTo(failedFields, columnName))
    * print 'Updated failedFields:', karate.get('failedFields')

  Scenario: Get Failed Fields
    * def response = karate.get('failedFields')
    * print 'Current failedFields:', response
