# https://folio-org.atlassian.net/browse/MODORGSTOR-164
Feature: Audit events for Organization

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables
    * def orgId = callonce uuid

  Scenario: Creating Organization should produce "Create" event
    * table organizationData
      | id    | name       | code | status   |
      | orgId | "Test Org" | "TO" | "Active" |
    * def v = call createOrganization organizationData

    * table eventData
      | resourcePath   | eventEntityId | eventType | eventCount |
      | "organization" | orgId         | "Create"  | 1          |
    * def v = call verifyResourceAuditEvents eventData

  Scenario: Updating Organization should produce "Edit" event
    * def orgIds = [{'resourcePath': 'organizations/organizations', 'resourceId': "#(orgId)"}]
    * def v = call updateResource orgIds

    * table eventData
      | resourcePath   | eventEntityId | eventType | eventCount |
      | "organization" | orgId         | "Edit"    | 2          |
    * def v = call verifyResourceAuditEvents eventData

  Scenario: Update Organization 50 times
    * def orgIds = []
    * def populateOrgIds =
      """
      function() {
        for (let i = 0; i < 50; i++) {
          orgIds.push({'resourcePath': 'organizations/organizations', 'resourceId': orgId});
        }
      }
      """
    * eval populateOrgIds()
    * def v = call updateResource orgIds

    * table eventData
      | resourcePath   | eventEntityId | eventType | eventCount |
      | "organization" | orgId         | "Edit"    | 52         |
    * def v = call verifyResourceAuditEvents eventData