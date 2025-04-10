@ignore
Feature:

  Background:
    * url baseUrl
    * def resourceExists = read('classpath:common/resource-exists.feature')

  @CreateGroup
  Scenario: Create User Group if not exists
    * def id = karate.get('id', '3487f367-3c96-4b84-bf2b-20016a84ac55')
    * def group = karate.get('group', 'lib')
    * def tenantId = karate.get('tenantId', tenant)
    Given path 'groups'
    And header x-okapi-tenant = tenantId
    And request
      """
      {
        "group": "#(group)",
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
    * def userBarcode = karate.get('userBarcode', '12345612')
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
        "externalSystemId": "#(externalId)",
        "type": "staff"
      }
      """
    When method POST
    Then status 201

  @SetUserPatronGroup
  Scenario: Set user patron group
    Given path 'users', userId
    When method GET
    Then status 200
    And def userData = response
    * set userData.type = 'patron'
    * set userData.patronGroup = groupId

    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)', 'Accept': 'text/plain' }
    # update user
    Given path 'users', userId
    And header Accept = 'text/plain'
    And request userData
    When method PUT
    Then status 204
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)', 'Accept': 'application/json' }

    Given path 'users', userId
    When method GET
    Then status 200
    And retry until response.patronGroup == groupId
