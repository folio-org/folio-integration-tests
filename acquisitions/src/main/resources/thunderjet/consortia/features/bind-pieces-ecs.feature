@parallel=false
Feature: Verify Bind Piece feature in ECS environment

  Background:
    * def bindPiecesFeatures = read('classpath:thunderjet/mod-orders/features/bind-piece.feature')

  Scenario: Test bind pieces features
    * def proxyConsortiaAdmin = { name: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def v = call bindPiecesFeatures { tenantId1: '#(centralTenantName)', tenantId2: '#(universityTenantName)', holdingId1: '#(centralHoldingId1)', holdingId2: '#(universityHoldingId1)', holdingId3: '#(centralHoldingId2)', testAdmin: '#(proxyConsortiaAdmin)', testUser: '#(proxyConsortiaAdmin)', testTenant: '#(centralTenantName)' }
