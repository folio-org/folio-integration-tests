Feature: edge-dematic sample data

  Background:
    * url baseUrl
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

    * callonce variables

  Scenario: create user1
    Given path 'users'
    And request
    """
    {
      "active" : true,
      "personal" : {
        "preferredContactTypeId" : "002",
        "lastName" : "User1",
        "firstName" : "Sample",
        "email" : "sample.user1@folio.org"
      },
      "username" : "sample_user1",
      "patronGroup" : "503a81cd-6c26-400f-b620-14c08943697c",
      "expirationDate" : "2022-03-15T00:00:00.000Z",
      "id" : "#(user1Id)",
      "barcode" : "#(user1Barcode)",
      "departments":[]
    }
    """
    When method POST
    Then status 201

  Scenario: create user2
    Given path 'users'
    And request
    """
    {
      "active" : true,
      "personal" : {
        "preferredContactTypeId" : "002",
        "lastName" : "User2",
        "firstName" : "Sample",
        "email" : "sample.user2@folio.org"
      },
      "username" : "sample_user2",
      "patronGroup" : "503a81cd-6c26-400f-b620-14c08943697c",
      "expirationDate" : "2022-03-15T00:00:00.000Z",
      "id" : "#(user2Id)",
      "barcode" : "#(user2Barcode)",
      "departments":[]
    }
    """
    When method POST
    Then status 201