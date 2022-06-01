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
