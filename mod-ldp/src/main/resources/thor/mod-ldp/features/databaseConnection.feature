Feature: Database Connections

Background:
  * url baseUrl
  * callonce login testUser
  * def hostEnv = callonce read("retrieveDbHost.feature")
  * def dbHost = karate.jsonPath(hostEnv.response, "$..[?(@.name=='DB_HOST')].value")
  * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

Scenario: Set the LDP database endpoint
  * configure headers = { 'Content-Type': 'application/json', 'x-okapi-url': '#(baseUrl)', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
  * def ldpConfig = '{"pass":"diku_ldp9367","user":"ldp","url":"jdbc:postgresql://' + dbHost + '/ldp"}'
  Given path 'ldp/config/dbinfo'
  And request
  """
  {
    "value" : #(ldpConfig),
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

