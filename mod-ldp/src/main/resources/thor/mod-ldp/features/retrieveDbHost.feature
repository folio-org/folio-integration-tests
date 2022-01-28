Feature: Retrieve DB host

Background:
  * url baseUrl
  * callonce login admin
  * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

Scenario: Get the DB_Host environment variable from the supertenant
  * print "Get the DB_Host environment variable from the supertenant"
  Given path "_/env"
  # And header x-okapi-tenant = admin.tenant
  # And header x-okapi-token = okapiSuperToken
  When method GET
  Then status 200
