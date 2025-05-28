Feature: consortia orders integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    # Create tenants and users, initialize data
    * callonce read('classpath:thunderjet/consortia/init-consortia-orders.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('destroy-data.feature'); }


  Scenario: Bind pieces features in ECS environment
    * call read('features/bind-pieces-ecs.feature')

  Scenario: Move Item and Holding to update order data in ECS environment
    * call read('features/move-item-and-holding-to-update-order-data-ecs.feature')

  Scenario: Open order with locations from different tenants
    * call read('features/open-order-with-locations-from-different-tenants.feature')

  Scenario: Piece Api Test for cross tenant envs
    * call read('features/pieces-api-test-for-cross-tenant-envs.feature')

  Scenario: Performance Open order with many locations from different tenants
    * call read('features/prf-open-order-with-many-locations-from-different-tenants.feature')

  Scenario: Reopen order and change instance connection orderLine
    * call read('features/reopen-and-change-instance-connection-order-with-locations-from-different-tenants.feature')

  Scenario: Update inventory ownership changes order data
    * call read('features/update-inventory-ownership-changes-order-data.feature')

  Scenario: Update unaffiliated PoLine locations
    * call read('features/update-unaffiliated-pol-locations.feature')
