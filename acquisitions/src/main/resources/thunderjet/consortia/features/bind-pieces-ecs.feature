Feature: Verify Bind Piece feature in ECS environment

  Background:
    * def bindPiecesFeatures = read('classpath:thunderjet/mod-orders/features/bind-piece.feature')

  Scenario: Test bind pieces features
    * set consortiaAdmin.name = consortiaAdmin.username
    * set centralUser1.name = centralUser1.username
    * table tenants
      | tenantId1     | tenantId2        | adminUser      | regularUser    | holdingId1        | holdingId2           | holdingId3        |
      | centralTenant | universityTenant | consortiaAdmin | consortiaAdmin | centralHoldingId1 | universityHoldingId1 | centralHoldingId2 |
    * def v = call bindPiecesFeatures tenants