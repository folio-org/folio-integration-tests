Feature: Common Consortia Headers

  Scenario: Define common consortia headers
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)' }
    * def headersUniversity = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(universityTenantName)' }
    * def headersCentralConsortium = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }

