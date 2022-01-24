# This should be executed with at least 5 threads
Feature: Create pieces for an open order in parallel (part 2)
  # parameters: pieceId1..5, poLineId1..5, titleId1..5, createPiece

  Background:
    * url baseUrl

  Scenario: Create piece 1
    * call createPiece { pieceId: "#(pieceId1)", poLineId: "#(poLineId1)", titleId: "#(titleId1)" }

  Scenario: Create piece 2
    * call createPiece { pieceId: "#(pieceId2)", poLineId: "#(poLineId2)", titleId: "#(titleId2)" }

  Scenario: Create piece 3
    * call createPiece { pieceId: "#(pieceId3)", poLineId: "#(poLineId3)", titleId: "#(titleId3)" }

  Scenario: Create piece 4
    * call createPiece { pieceId: "#(pieceId4)", poLineId: "#(poLineId4)", titleId: "#(titleId4)" }

  Scenario: Create piece 5
    * call createPiece { pieceId: "#(pieceId5)", poLineId: "#(poLineId5)", titleId: "#(titleId5)" }

