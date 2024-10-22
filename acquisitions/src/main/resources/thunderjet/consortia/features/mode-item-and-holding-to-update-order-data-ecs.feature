Feature: Move Item and Holding to update order data

  Background:
    * def moveItemAndHoldingFeature = read('classpath:thunderjet/mod-orders/features/mode-item-and-holding-to-update-order-data.feature')

  Scenario: Test Moving Item and Holding to update order data in ECS environment
    * set consortiaAdmin.name = consortiaAdmin.username
    * table tenants
      | testAdmin      |
      | consortiaAdmin |
    * def v = call moveItemAndHoldingFeature tenants