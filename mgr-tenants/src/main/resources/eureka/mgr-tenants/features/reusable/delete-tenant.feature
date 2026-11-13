@ignore
Feature: delete a test tenant (best effort)

  # Parameters: tenantId, masterToken
  # The status is intentionally not asserted, because the tenant may already have been deleted by the scenario.

  Background:
    * url baseUrl

  Scenario: delete tenant
    * def tenantId = karate.get('tenantId')
    * def masterToken = karate.get('masterToken')
    * configure headers = { 'Authorization': '#("Bearer " + masterToken)', 'X-Okapi-Token': '#(masterToken)' }

    Given path 'tenants', tenantId
    When method delete
