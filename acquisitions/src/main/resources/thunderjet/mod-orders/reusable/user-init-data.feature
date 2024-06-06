Feature:

  Background:
    * url baseUrl

  @CreateGroup
  Scenario: Create User Group
    * def id = karate.get('id', '3487f367-3c96-4b84-bf2b-20016a84ac55')
    Given path 'groups'
    And request
      """
      {
        "group": "lib",
        "desc": "For Testing",
        "expirationOffsetInDays": "60",
        "id": "#(id)"
      }
      """
    When method POST
    Then status 201

  @CreateUser
  Scenario: Create User
    * def userId = karate.get('userId', 'd3803887-08fd-4876-9a73-5f6d78683890')
    * def firstName = karate.get('firstName', 'Elon')
    * def lastName = karate.get('lastName', 'Musk')
    * def userBarCode = karate.get('userBarCode', '12345612')
    * def userName = karate.get('userName', 'test')
    * def externalId = karate.get('externalId', 'bbef3f13-ea8e-42ab-9b76-6f746516ebdd')
    * def patronId = karate.get('patronId', null)

    Given path 'users'
    And request
      """
      {
        "active": "true",
        "personal": {
          "firstName": "#(firstName)",
          "preferredContactTypeId": "002",
          "lastName": "#(lastName)",
          "preferredFirstName": "X",
          "email": "test@mail.com"
        },
        "patronGroup": "#(patronId)",
        "barcode": "#(userBarcode)",
        "id": "#(userId)",
        "username": "#(userName)",
        "departments": [],
        "externalSystemId": "#(externalId)"
      }
      """
    When method POST
    Then status 201