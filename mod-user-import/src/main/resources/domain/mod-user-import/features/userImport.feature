Feature: User import

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Import without users
    Given path 'user-import'
    And header Content-Type = 'application/json'
    And header X-Okapi-Url = baseUrl
    And request
    """
    {
      "totalRecords": 0,
      "users": []
    }
    """
    When method POST
    Then status 200

  @Undefined
  Scenario: Import with address type response error
    * print 'undefined'

  @Undefined
  Scenario: Import with patron group response error
    * print 'undefined'

  @Undefined
  Scenario: Import with user creation
    * print 'undefined'

  @Undefined
  Scenario: Import with user creation without personal data
    * print 'undefined'

  @Undefined
  Scenario: Import with user creation with non existing patron group
    * print 'undefined'

  @Undefined
  Scenario: Import with user without external system id
    * print 'undefined'

  @Undefined
  Scenario: Import with user with empty external system id
    * print 'undefined'

  @Undefined
  Scenario: Import with user without username
    * print 'undefined'

  @Undefined
  Scenario: Import with user creation and permission error
    * print 'undefined'

  @Undefined
  Scenario: Import with user search error
    * print 'undefined'

  @Undefined
  Scenario: Import with user creation error
    * print 'undefined'

  @Undefined
  Scenario: Import with more user creation
    * print 'undefined'

  @Undefined
  Scenario: Import with user update
    * print 'undefined'

  @Undefined
  Scenario: Import with user update and wrong schema in user search result
    * print 'undefined'

  @Undefined
  Scenario: Import with user update and wrong schema in user search result with deactivation
    * print 'undefined'

  @Undefined
  Scenario: Import with user update error
    * print 'undefined'

  @Undefined
  Scenario: Import with more user update and deactivation
    * print 'undefined'

  @Undefined
  Scenario: IMport with more user update
    * print 'undefined'

  @Undefined
  Scenario: Import with user address update
    * print 'undefined'

  @Undefined
  Scenario: Import with existing user address
    * print 'undefined'

  @Undefined
  Scenario: Import with user address add
    * print 'undefined'

  @Undefined
  Scenario: Import with user address rewrite
    * print 'undefined'

  @Undefined
  Scenario: Import with prefixed user creation
    * print 'undefined'

  @Undefined
  Scenario: Import with prefixed user update
    * print 'undefined'

  @Undefined
  Scenario: Import with deactivate in source type
    * print 'undefined'

  @Undefined
  Scenario: Import with deactivate in source type
    * print 'undefined'

  @Undefined
  Scenario: Import with deactivate in source type with deactivation error
    * print 'undefined'

  @Undefined
  Scenario: Import with no need to deactivate
    * print 'undefined'

  @Undefined
  Scenario: Import with user search error when deactivating
    * print 'undefined'

  @Undefined
  Scenario: Import with user creation error when deactivating
    * print 'undefined'

  @Undefined
  Scenario: Import with service points response error
    * print 'undefined'

  @Undefined
  Scenario: Import with new preference creation
    * print 'undefined'

  @Undefined
  Scenario: Import with user preference delivery is false and fulfillment specified
    * print 'undefined'

  @Undefined
  Scenario: Import with user preference delivery is false and address type specified
    * print 'undefined'

  @Undefined
  Scenario: Import with user preference invalid default service point
    * print 'undefined'

  @Undefined
  Scenario: Import with user preference delivery is true and invalid address type
    * print 'undefined'

  @Undefined
  Scenario: Import with user preference default service point not found
    * print 'undefined'

  @Undefined
  Scenario: Import with user preference delivery is true and address type not found
    * print 'undefined'

  @Undefined
  Scenario: Import with user update and new preference creation
    * print 'undefined'

  @Undefined
  Scenario: Import with user update and existing preference update
    * print 'undefined'

  @Undefined
  Scenario: Import user with no preference with update only present field and existing preference not delete
    * print 'undefined'

  @Undefined
  Scenario: Import user with no preferences without update only present field and existing preferences delete
    * print 'undefined'

  @Undefined
  Scenario: Import with user update and wrong preference address type
    * print 'undefined'

  @Undefined
  Scenario: Import with user update with no preference
    * print 'undefined'

  @Undefined
  Scenario: Import with departments response error
    * print 'undefined'

  @Undefined
  Scenario: Import with departments on new user creation
    * print 'undefined'

  @Undefined
  Scenario: Import departments on user update
    * print 'undefined'

  @Undefined
  Scenario: Import with departments creation
    * print 'undefined'

  @Undefined
  Scenario: Import with departments updating
    * print 'undefined'

  @Undefined
  Scenario: Import with departments that not existed
    * print 'undefined'

  @Undefined
  Scenario: Import user with not existed custom field options
    * print 'undefined'

  @Undefined
  Scenario: Import with users with multifield options one of is not exist
    * print 'undefined'

  @Undefined
  Scenario: Import users with custom field options with request error
    * print 'undefined'

  @Undefined
  Scenario: Import users with custom field and trying update not existed custom field
    * print 'undefined'




