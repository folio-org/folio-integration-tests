Feature: LC user registration tests tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def createUserResponse = callonce read('classpath:vega/edge-patron/features/util/lc-initData.feature@PostPatronGroupAndUser')
    * print 'createUserResponse:', createUserResponse
    * def externalSystemIdPath = createUserResponse.createUserRequest.externalSystemId
    * def userId = createUserResponse.createUserRequest.id
    * callonce read('classpath:vega/edge-patron/features/util/lc-initData.feature@CreateHomeAddressType')
    * def ext_random_number = callonce random_numbers
    * def externalIdBody = 'ext-' + ext_random_number
    * def firstName = 'firstName' + externalIdBody
    * def middleName = 'middleName' + externalIdBody
    * def lastName = 'lastName' + externalIdBody
    * def email = 'email_1_' + externalIdBody + '@test.com'

    * print 'externalSystemIdPath:', externalSystemIdPath
    * print 'externalIdBody:', externalIdBody
    * print 'userId:', userId


  Scenario: [Positive] Register a new LC user and Test if registered successfully
    * print '[Positive] Register a new LC user and test if registered successfully'
    * def externalId = externalIdBody
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 201

    Given url baseUrl
    And path 'users'
    And param query = 'externalSystemId=' + externalIdBody
    And headers headers
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].externalSystemId == externalIdBody

  Scenario: [Negative] Register a new LC user and Test if externalSystemId already exist with different email
    * print '[Negative] Register a new LC user and test if externalSystemId already exist with different email'
    * def email = 'email_2_' + externalIdBody + '@test.com'
    * def externalId = externalIdBody
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 500
    And match response.errorMessage contains 'violates unique constraint'

  Scenario: [Negative] Register a new LC user and Test if email/user already exist
    * print '[Negative] Register a new LC user and Test if email/user already exist'
    * def email = 'email_1_' + externalIdBody + '@test.com'
    * def externalId = externalIdBody + '_XYZ_RANDOM'
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 422
    And match response.errorMessage contains 'User already exists'

  Scenario: [Negative] Register a new LC user and Test if more than 3 preferredEmailCommunication enum values
    * print '[Negative] Register a new LC user and Test if invalid preferredEmailCommunication enum value'
    * def email = 'email_99_' + externalIdBody + '@test.com'
    * def externalId = externalIdBody + '_XYZ_RANDOM'
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')
    * def preferredEmailCommunicationArray = ['Support','Programs','Service', 'Service']
    * createLCUserRequest.preferredEmailCommunication = preferredEmailCommunicationArray

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 500
    And match response.errorMessage contains 'PreferredEmailCommunication'

  Scenario: [Negative] Register a new LC user and Test if invalid preferredEmailCommunication enum value
    * print '[Negative] Register a new LC user and Test if invalid preferredEmailCommunication enum value'
    * def email = 'email_99_' + externalIdBody + '@test.com'
    * def externalId = externalIdBody + '_XYZ_RANDOM'
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')
    * def preferredEmailCommunicationArray = ['Support','Programs','Service', 'XYZ']
    * createLCUserRequest.preferredEmailCommunication = preferredEmailCommunicationArray

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 400
    And match response.errorMessage contains 'PreferredEmailCommunication'


  Scenario: [Negative] Get LC users and test if 404 when invalid externalSystemId/createdBy passed in pathVariable
    * print '[Negative] Get LC users and test if 404 when invalid externalSystemId/createdBy passed in pathVariable'
    * def externalSystemIdPathNew = callonce random_numbers
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPathNew + '/external-patrons'
    And param apikey = apikey
    And param expired = false
    When method GET
    Then status 404
    And match response.errorMessage contains 'Unable to find patron ' + externalSystemIdPathNew


  Scenario: [Positive] Get expired patron LC users
    * print '[Positive] Get expired patron LC users'
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/external-patrons'
    And param apikey = apikey
    And param expired = true
    When method GET
    Then status 200

  Scenario: [Negative] Get expired patron LC users, Test if 404 when invalid externalSystemId/createdBy passed in pathVariable
    * print '[Negative] Get expired patron LC users, Test if 404 when invalid externalSystemId/createdBy passed in pathVariable'
    * def externalSystemIdPathNew = callonce random_numbers
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPathNew + '/external-patrons'
    And param apikey = apikey
    And param expired = true
    When method GET
    Then status 404
    And match response.errorMessage contains 'Unable to find patron ' + externalSystemIdPathNew


  Scenario: [Positive] Get patron LC users by emailId
    * print '[Positive] Get patron LC users by emailId'
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + email
    And param apikey = apikey
    When method GET
    Then status 200
    And assert response.generalInfo.externalSystemId == externalIdBody

  Scenario: [Negative] Get patron LC users by emailId and Test if 404 when pass un-registered email Id
    * print '[Negative] Get patron LC users by emailId and Test if 404 when pass un-registered email Id'
    * def invalidEmailId = 'email_invalid_' + externalIdBody + '@test.com'
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + invalidEmailId
    And param apikey = apikey
    When method GET
    Then status 404
    And match response.errorMessage contains 'User not found'

  Scenario: [Negative] Get patron LC users by emailId and Test if 404 when invalid externalSystemId/createdBy passed in pathVariable
    * print '[Negative] Get patron LC users by emailId and Test if 404 when invalid externalSystemId/createdBy passed in pathVariable'
    * def externalSystemIdPathNew = callonce random_numbers
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPathNew + '/by-email/' + email
    And param apikey = apikey
    When method GET
    Then status 404
    And match response.errorMessage contains 'Unable to find patron ' + externalSystemIdPathNew


  Scenario: [Positive] Update a new LC user and Test if user is being updated using update API
    * print '[Positive] Register a new LC user and Test if user is being updated using update API'
    * def externalId = externalIdBody
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')
    * createLCUserRequest.generalInfo.firstName = 'New First Name'

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + email
    And param apikey = apikey
    And request createLCUserRequest
    When method PUT
    Then status 204

    Given url baseUrl
    And path 'users'
    And param query = 'externalSystemId=' + externalIdBody
    And headers headers
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].externalSystemId == externalIdBody
    And match response.users[0].personal.firstName == 'New First Name'

  Scenario: [Negative] Update a new LC user and Test if 500 when updating already existed email
    * print '[Negative] Update a new LC user and Test if 500 when updating already existed email'

    * def ext_random_number = callonce random_numbers
    * def externalId = 'txt-' + ext_random_number
    * def email = 'email_test_1_' + externalIdBody + '@test.com'
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 201


    * createLCUserRequest.contactInfo.email = 'email_1_' + externalIdBody + '@test.com'
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + email
    And param apikey = apikey
    And request createLCUserRequest
    When method PUT
    Then status 400
    And match response.errorMessage contains 'User already exist with email provided in payload'


  Scenario: [Negative] Update a new LC user and Test if 404 when pass un-registered emailId
    * print '[Negative] Update a new LC user and Test if 404 when pass un-registered emailId'
    * def externalId = externalIdBody
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')
    * createLCUserRequest.generalInfo.firstName = 'New First Name'
    * def invalidEmailId = 'email_invalid_' + externalIdBody + '@test.com'

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + invalidEmailId
    And param apikey = apikey
    And request createLCUserRequest
    When method PUT
    Then status 404
    And match response.errorMessage contains 'user does not exist'