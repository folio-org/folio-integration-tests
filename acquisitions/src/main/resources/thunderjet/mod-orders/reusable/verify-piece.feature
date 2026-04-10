@ignore
Feature: Collection of different verification of encumbrance transaction

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  @ignore @VerifyPieceReceivingStatus
  Scenario: Verify Piece receiving status
    Given path 'orders/pieces', _pieceId
    When method GET
    Then status 200
    And match response.receivingStatus == _receivingStatus

  @ignore @VerifyPieceAuditEvents
  Scenario: Verify Piece receiving status
    Given path '/audit-data/acquisition/piece/' + _pieceId + '/status-change-history'
    And retry until response.totalItems == _eventCount
    When method GET
    Then status 200
    And match response.pieceAuditEvents[*].pieceId contains _pieceId
    And match response.pieceAuditEvents[*].action contains "Edit"
    And match response.pieceAuditEvents[*].pieceSnapshot.map.receivingStatus contains _receivingStatus
