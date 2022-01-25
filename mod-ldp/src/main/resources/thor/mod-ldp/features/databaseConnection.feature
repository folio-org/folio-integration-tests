Feature: Database Connections

Background:
  * url baseUrl
  * callonce login testUser
  * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

Scenario: Can set ldp endpoint in app settings
  * configure headers = { 'Content-Type': 'application/json', 'x-okapi-url': '#(baseUrl)', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
  Given path 'ldp/config/dbinfo'
  And request
  """
  {
    "value" : "{\"pass\":\"diku_ldp9367\",\"user\":\"ldp\",\"url\":\"jdbc:postgresql://10.36.1.60:5432/ldp\"}",
    "tenant" : "diku",
    "key" : "dbinfo"
  }
  """
  When method PUT
  Then status 200

Scenario: Query should return contents of user.groups table
  * configure headers = { 'Content-Type': 'application/json', 'x-okapi-url': '#(baseUrl)', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
  Given path 'ldp/db/query'
  And request
  """
    {
      "tables": [
        {
          "columnFilters": [],
          "limit": 101,
          "orderBy": [],
          "schema": "public",
          "showColumns": [],
          "tableName": "user_groups"
        }
      ]
    }
  """
  When method POST
  Then status 200

