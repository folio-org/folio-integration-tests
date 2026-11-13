@ignore
Feature: delete test tenants (best effort)

  # Used by the afterScenario hooks of the mgr-tenants features to remove test data even if a scenario failed.
  # Parameters: tenantIds (array of tenant ids), masterToken
  # The status is intentionally not asserted, because a tenant may already have been deleted by the scenario.

  Background:
    * url baseUrl

  Scenario: delete every tenant in the list
    * def tenantIds = karate.get('tenantIds') || []
    * def masterToken = karate.get('masterToken')
    * configure headers = { 'Authorization': '#("Bearer " + masterToken)', 'X-Okapi-Token': '#(masterToken)' }
    * def deleteArgs = karate.map(tenantIds, function(id) { return { tenantId: id, masterToken: masterToken } })
    * call read('classpath:eureka/mgr-tenants/features/reusable/delete-tenant.feature') deleteArgs
