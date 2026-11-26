@ignore
Feature: delete a test application (best effort)

  # Used by the afterScenario hooks of the mgr-applications features to remove test data even if a scenario failed.
  # The status is intentionally not asserted, because the application may already have been deleted by the scenario.

  Background:
    * url baseUrl

  Scenario: delete application
    * def applicationId = karate.get('applicationId')
    * def masterToken = karate.get('masterToken')
    * configure headers = { 'Authorization': '#("Bearer " + masterToken)', 'X-Okapi-Token': '#(masterToken)' }

    Given path 'applications', applicationId
    When method delete
