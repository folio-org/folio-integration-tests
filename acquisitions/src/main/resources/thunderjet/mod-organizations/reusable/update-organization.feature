@ignore
Feature: Update Organization
  # parameters: orgId

  Background:
    * url baseUrl

  Scenario: updateOrganization
    Given path 'organizations/organizations', orgId
    When method GET
    Then status 200
    * def org = response

    Given path 'organizations/organizations', orgId
    And request org
    When method PUT
    Then status 204
