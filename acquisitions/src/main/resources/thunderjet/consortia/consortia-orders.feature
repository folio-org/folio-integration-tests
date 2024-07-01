# MODORDSTOR-402
Feature: Open ongoing order

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    # load global variables
    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

  Scenario: init global data
    * callonce read('order-utils/inventory.feature')
    * callonce read('order-utils/inventory-university.feature')
    * callonce read('order-utils/configuration.feature')
    * callonce read('order-utils/finances.feature')
    * callonce read('order-utils/organizations.feature')
    * callonce read('order-utils/orders.feature')

  Scenario: Test open order with locations from different tenants
    Given call read('features/open-order-with-locations-from-different-tenants.feature')

  Scenario: Test cross-tenant inventory objects creation when working with pieces
    Given call read("features/pieces-api-test-for-cross-tenant-envs.feature")