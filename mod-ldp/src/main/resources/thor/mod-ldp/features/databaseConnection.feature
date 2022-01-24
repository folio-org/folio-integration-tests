Feature: Database Connections

Background:
  * url baseUrl
  * callonce login testUser
  * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

Scenario: Query should return contents of user.groups table
  * def requestEntity = read('samples/user-groups-query.json')
  * configure headers = { 'Content-Type': 'application/json', 'x-okapi-url': '#(baseUrl)', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
  Given path 'ldp/db/query'
  When method POST
  Then status 200

