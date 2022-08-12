Feature: Global variables

  Scenario: load test variables
    * def userIdentifiersJob =
    """
    {
      "name" : "bulk edit get users job",
      "identifierType" : "BARCODE",
      "entityType" : "USER",
      "type" : "BULK_EDIT_IDENTIFIERS",
      "exportTypeSpecificParameters" : {}
    }
    """

    * def userUpdateJob =
    """
    {
      "name" : "bulk edit get users job",
      "identifierType": "BARCODE",
      "entityType" : "USER",
      "type" : "BULK_EDIT_UPDATE",
      "exportTypeSpecificParameters" : {}
    }
    """

    * def itemIdentifiersJob =
    """
    {
      "name" : "bulk edit get items job",
      "identifierType" : "BARCODE",
      "entityType" : "ITEM",
      "type" : "BULK_EDIT_IDENTIFIERS",
      "exportTypeSpecificParameters" : {}
    }
    """

    * def itemUpdateJob =
    """
    {
      "name" : "bulk edit get items job",
      "identifierType": "BARCODE",
      "entityType" : "ITEM",
      "type" : "BULK_EDIT_UPDATE",
      "exportTypeSpecificParameters" : {}
    }
    """
    * def itemIdentifiersUUIDJob =
    """
    {
      "name" : "bulk edit get items job",
      "identifierType" : "ID",
      "entityType" : "ITEM",
      "type" : "BULK_EDIT_IDENTIFIERS",
      "exportTypeSpecificParameters" : {}
    }
    """

    * def itemIdentifiersHRIDJob =
    """
    {
      "name" : "bulk edit get items job",
      "identifierType" : "HRID",
      "entityType" : "ITEM",
      "type" : "BULK_EDIT_IDENTIFIERS",
      "exportTypeSpecificParameters" : {}
    }
    """

    * def itemIdentifiersHoldingsHRIDJob =
    """
    {
      "name" : "bulk edit get items job",
      "identifierType" : "HOLDINGS_RECORD_ID",
      "entityType" : "ITEM",
      "type" : "BULK_EDIT_IDENTIFIERS",
      "exportTypeSpecificParameters" : {}
    }
    """

    * def itemIdentifiersAccessionJob =
    """
    {
      "name" : "bulk edit get items job",
      "identifierType" : "ACCESSION_NUMBER",
      "entityType" : "ITEM",
      "type" : "BULK_EDIT_IDENTIFIERS",
      "exportTypeSpecificParameters" : {}
    }
    """


