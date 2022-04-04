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
      "name" : "bulk edit update users job",
      "entityType" : "USER",
      "type" : "BULK_EDIT_IDENTIFIERS",
      "BULK_EDIT_UPDATE" : {}
    }
    """
