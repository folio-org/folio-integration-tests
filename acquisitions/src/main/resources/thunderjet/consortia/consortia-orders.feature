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
    #* call login testAdmin

    * callonce read('order-utils/inventory.feature')
    * callonce read('order-utils/inventory-college.feature')
    * callonce read('order-utils/configuration.feature')
    * callonce read('order-utils/finances.feature')
    * callonce read('order-utils/organizations.feature')
    * callonce read('order-utils/orders.feature')

    * callonce read('features/open-order-with-locations-from-different-tenants.feature')
