Feature: Patron blocks limits

  Background:
    * url baseUrl
    * def admin = { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * call login admin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  # CRUD

  Scenario: Get non-existent limit
    Given path 'patron-block-limits', '20fb8c3c-5a95-4272-b1e6-7d8ad35868dd'
    When method GET
    Then status 404

  Scenario: Create a limit
    Given path 'patron-block-limits'
    And request
    """
    {
       "patronGroupId":"3684a786-6671-4268-8ed0-9db82ebca60b",
       "conditionId":"3d7c52dc-c732-4223-8bf8-e5917801386f",
       "value":10,
       "id":"d81a39bb-b8cb-49bd-bfe9-d7451277edb5"
    }
    """
    When method POST
    Then status 201
    # verify that metadata was added to limit record
    And match $.metadata == '#notnull'

  Scenario: Get limit
    Given path 'patron-block-limits', 'd81a39bb-b8cb-49bd-bfe9-d7451277edb5'
    When method GET
    Then status 200
    And match $.id == 'd81a39bb-b8cb-49bd-bfe9-d7451277edb5'

  @Undefined
  Scenario: Get a list of patron block limits
    * print 'undefined'

  Scenario: Update limit
    Given path 'patron-block-limits', 'd81a39bb-b8cb-49bd-bfe9-d7451277edb5'
    And request
    """
    {
       "patronGroupId":"3684a786-6671-4268-8ed0-9db82ebca60b",
       "conditionId":"3d7c52dc-c732-4223-8bf8-e5917801386f",
       "value":100,
       "id":"d81a39bb-b8cb-49bd-bfe9-d7451277edb5"
    }
    """
    When method PUT
    Then status 204

    # verify that limit was updated
    Given path 'patron-block-limits', 'd81a39bb-b8cb-49bd-bfe9-d7451277edb5'
    When method GET
    Then match $.value == 100

  Scenario: Delete limit
    Given path 'patron-block-limits', 'd81a39bb-b8cb-49bd-bfe9-d7451277edb5'
    When method DELETE
    Then status 204

  @Undefined
  Scenario: Can not create patron block limit with invalid integer limit
    * print 'undefined'

  @Undefined
  Scenario: Should create patron block limit with zero limit
    * print 'undefined'

  @Undefined
  Scenario: Can not create patron block limit with double limit out of range
    * print 'undefined'

  @Undefined
  Scenario: Should update patron block limit with zero value
    * print 'undefined'