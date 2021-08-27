Feature:

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def group = read('samples/group-entity.json')
    * def user = read('samples/user-entity.json')

    Scenario: Create a group and a user
      * group.patronGroupId = patronGroupId
      * user.id = userId
      * user.barcode = userBarcode
      * print group
      * print user

      Given path 'groups'
      And request group
      When method POST
      Then status 201

      Given path 'users'
      And request user
      When method POST
      Then status 201
