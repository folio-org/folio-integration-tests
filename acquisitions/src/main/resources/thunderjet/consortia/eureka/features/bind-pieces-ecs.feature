Feature: Verify Bind Piece feature in ECS environment

  Background:
    * def bindPiecesFeatures = read('classpath:thunderjet/mod-orders/eureka/features/bind-piece.feature')

  Scenario: Test bind pieces features
    * table tenants
      | tenantId1     | tenantId2        | holdingId1        | holdingId2           | holdingId3        |
      | centralTenant | universityTenant | centralHoldingId1 | universityHoldingId1 | centralHoldingId2 |
    * def proxyConsortiaAdmin = {name: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)'}
    * def v = call bindPiecesFeatures {tenantId1: '#(centralTenant)', tenantId2: '#(universityTenant)', holdingId1: '#(centralHoldingId1)', holdingId2: '#(universityHoldingId1)', holdingId3: '#(centralHoldingId2)', testAdmin: '#(proxyConsortiaAdmin)', testTenant: '#(centralTenant)'}