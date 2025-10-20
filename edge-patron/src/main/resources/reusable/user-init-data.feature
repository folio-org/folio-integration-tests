@ignore
Feature:

  Background:
    * url baseUrl

  @CreateGroup
  Scenario: Create User Group if not exists
    * def groupId = karate.get('id', java.util.UUID.randomUUID().toString())
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
        "id": "#(groupId)"
      }
      """
    When method POST
    * if (responseStatus == 201) karate.log('Group created')
    * if (responseStatus == 422 && response.errors && response.errors[0].message && response.errors[0].message.contains('value already exists')) karate.log('Group already exists, treat as success')
    * if (!(responseStatus == 201 || (responseStatus == 422 && response.errors && response.errors[0].message && response.errors[0].message.contains('value already exists')))) karate.fail('Unexpected error creating group: ' + response)
    * def result = { groupId: groupId }

  @CreateUser
  Scenario: Create User
    * def userId = karate.get('userId', 'd3803887-08fd-4876-9a73-5f6d78683890')
    * def firstName = karate.get('firstName', 'Elon')
    * def lastName = karate.get('lastName', 'Musk')
    * def userBarcode = karate.get('userBarcode', '12345612')
    * def userName = karate.get('userName', 'test')
    * def externalId = karate.get('externalId', 'bbef3f13-ea8e-42ab-9b76-6f746516ebdd')

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
        "patronGroup": "#(groupId)",
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
