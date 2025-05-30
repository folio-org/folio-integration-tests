Feature: Move Item and Holding to update order data

  Background:
    * def moveItemAndHoldingFeature = read('classpath:thunderjet/mod-orders/features/move-item-and-holding-to-update-order-data.feature')

  Scenario: Test Moving Item and Holding to update order data in ECS environment
    * def proxyConsortiaAdmin = {name: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)'}
    * def v = call moveItemAndHoldingFeature {testAdmin: '#(proxyConsortiaAdmin)', testUser: '#(proxyConsortiaAdmin)', testTenant: '#(centralTenantName)'}