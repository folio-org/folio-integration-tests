Feature: LC user registration tests tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def createUserResponse = callonce read('classpath:vega/edge-patron/features/util/lc-initData.feature@PostPatronGroupAndUser')
    * print 'createUserResponse:', createUserResponse
    * def externalSystemIdPath = createUserResponse.createUserRequest.externalSystemId
    * def userId = createUserResponse.createUserRequest.id
    * def homeAddress = callonce read('classpath:vega/edge-patron/features/util/lc-initData.feature@CreateHomeAddressType')
    * def homeAddressTypeId = homeAddress.homeAddressTypeId
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
    * def LocalDate = Java.type('java.time.LocalDate')
    * def expectedEnrollmentDate = LocalDate.now()
    * def expectedExpirationDate = expectedEnrollmentDate.plusYears(2)

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
    And eval response.users.length > 0
    And match response.users[0].externalSystemId == externalIdBody
    And match response.users[0].personal.email == email
    And match response.users[0].personal.preferredContactTypeId == "002"
    And match response.users[0].active == true
    And match response.users[0].type == 'patron'
    And match response.users[0].enrollmentDate contains expectedEnrollmentDate.toString()
    And match response.users[0].expirationDate contains expectedExpirationDate.toString()
    And match response.users[0].personal.addresses[0].primaryAddress == true
    And match response.users[0].personal.addresses[0].addressTypeId == homeAddressTypeId

  Scenario: [Negative] Register a new LC user and error USER_ACCOUNT_INACTIVE
    * print '[Negative] Register a new LC user and error USER_ACCOUNT_INACTIVE'

    Given url baseUrl
    And path 'groups'
    And param query = 'group=Remote Non-circulating'
    And headers headers
    When method GET
    Then status 200
    And eval response.usergroups.length > 0
    And match response.usergroups[0].group == 'Remote Non-circulating'
    * def patronId = response.usergroups[0].id

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_USER_ACCOUNT_INACTIVE_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-inactive-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    * def externalId = externalIdBody
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 422
    And match response.errorMessage == 'USER_ACCOUNT_INACTIVE'

  Scenario: [Negative] Register a new LC user and error INVALID_PATRON_GROUP
    * print '[Negative] Register a new LC user and error INVALID_PATRON_GROUP'

    * def patronId = call random_uuid
    * def patronName = 'XYZ Patron Group'
    * def createPatronGroupRequest = read('samples/user/create-patronGroup-request.json')

    Given path 'groups'
    And headers headers
    And request createPatronGroupRequest
    When method POST
    Then status 201

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_INVALID_PATRON_GROUP_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201


    * def externalId = externalIdBody
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 422
    And match response.errorMessage == 'INVALID_PATRON_GROUP'

  Scenario: [Negative] Register a new LC user and Test if USER_ALREADY_EXIST
    * print '[Negative] Register a new LC user and Test if USER_ALREADY_EXIST'
    * def email = 'email_1_' + externalIdBody + '@test.com'
    * def externalId = externalIdBody + '_XYZ_RANDOM'
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 422
    And match response.errorMessage contains 'USER_ALREADY_EXIST'

  Scenario: [Negative] Register a new LC user and error MULTIPLE_USER_WITH_EMAIL
    * print '[Negative] Register a new LC user and error MULTIPLE_USER_WITH_EMAIL'

    Given url baseUrl
    And path 'groups'
    And param query = 'group=Remote Non-circulating'
    And headers headers
    When method GET
    Then status 200
    And eval response.usergroups.length > 0
    And match response.usergroups[0].group == 'Remote Non-circulating'
    * def patronId = response.usergroups[0].id

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_DUPLICATE1_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_DUPLICATE1_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    * def externalId = externalIdBody
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 422
    And match response.errorMessage == 'MULTIPLE_USER_WITH_EMAIL'

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
    And match response.errorMessage contains 'USER_NOT_FOUND'

  Scenario: [Negative] Get patron LC users by emailId and Test if MULTIPLE_USER_WITH_EMAIL
    * print '[Negative] Get patron LC users by emailId and Test if MULTIPLE_USER_WITH_EMAIL'

    Given url baseUrl
    And path 'groups'
    And param query = 'group=Remote Non-circulating'
    And headers headers
    When method GET
    Then status 200
    And eval response.usergroups.length > 0
    And match response.usergroups[0].group == 'Remote Non-circulating'
    * def patronId = response.usergroups[0].id

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_DUPLICATE22_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_DUPLICATE22_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    * def invalidEmailId = 'email_DUPLICATE22_' + externalIdBody + '@test.com'
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + invalidEmailId
    And param apikey = apikey
    When method GET
    Then status 422
    And match response.errorMessage contains 'MULTIPLE_USER_WITH_EMAIL'

  Scenario: [Negative] Get patron LC users by emailId and Test if 404 when invalid externalSystemId/createdBy passed in pathVariable
    * print '[Negative] Get patron LC users by emailId and Test if 404 when invalid externalSystemId/createdBy passed in pathVariable'
    * def externalSystemIdPathNew = callonce random_numbers
    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPathNew + '/by-email/' + email
    And param apikey = apikey
    When method GET
    Then status 404
    And match response.errorMessage contains 'Unable to find patron ' + externalSystemIdPathNew

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
    And match response.errorMessage contains 'USER_NOT_FOUND'

  Scenario: [Negative] Update a new LC user and Test if 422 when updating already existed email
    * print '[Negative] Update a new LC user and Test if 422 when updating already existed email'

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
    Then status 422
    And match response.errorMessage contains 'EMAIL_ALREADY_EXIST'

  Scenario: [Negative] Update a LC user and error MULTIPLE_USER_WITH_EMAIL
    * print '[Negative] Update a LC user and error MULTIPLE_USER_WITH_EMAIL'

    Given url baseUrl
    And path 'groups'
    And param query = 'group=Remote Non-circulating'
    And headers headers
    When method GET
    Then status 200
    And eval response.usergroups.length > 0
    And match response.usergroups[0].group == 'Remote Non-circulating'
    * def patronId = response.usergroups[0].id

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_DUPLICATE22_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_DUPLICATE22_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201


    * def externalId = externalIdBody
    * def firstName = 'firstName' + externalIdBody
    * def middleName = 'middleName' + externalIdBody
    * def lastName = 'lastName' + externalIdBody
    * def email = 'email_DUPLICATE22_' + externalIdBody + '@test.com'
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + email
    And param apikey = apikey
    And request createLCUserRequest
    When method PUT
    Then status 422
    And match response.errorMessage contains 'MULTIPLE_USER_WITH_EMAIL'

  Scenario: [Negative] Update a LC user and error PATRON_GROUP_NOT_APPLICABLE
    * print '[Negative] Update a LC user and error PATRON_GROUP_NOT_APPLICABLE'

    * def patronId = call random_uuid
    * def patronName = 'XYZ123 Patron Group'
    * def createPatronGroupRequest = read('samples/user/create-patronGroup-request.json')

    Given path 'groups'
    And headers headers
    And request createPatronGroupRequest
    When method POST
    Then status 201

    * def userBarcode = call random_numbers
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_string
    * def email = 'email_PATRON_GROUP_NOT_APPLICABLE_' + externalIdBody + '@test.com'
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    Given url baseUrl
    And path 'groups'
    And param query = 'group=Remote Non-circulating'
    And headers headers
    When method GET
    Then status 200
    And eval response.usergroups.length > 0
    And match response.usergroups[0].group == 'Remote Non-circulating'
    * def patronId = response.usergroups[0].id


    * def externalId = externalIdBody
    * def firstName = 'firstName' + externalIdBody
    * def middleName = 'middleName' + externalIdBody
    * def lastName = 'lastName' + externalIdBody
    * def email = 'email_PATRON_GROUP_NOT_APPLICABLE_' + externalIdBody + '@test.com'
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + email
    And param apikey = apikey
    And request createLCUserRequest
    When method PUT
    Then status 422
    And match response.errorMessage contains 'PATRON_GROUP_NOT_APPLICABLE'

  Scenario: [Positive] Update a new LC user and Test if user is being updated using update API
    * print '[Positive] Update a new LC user and Test if user is being updated using update API'

    * def externalId = externalIdBody + 'random123'
    * def firstName = 'firstName' + externalIdBody
    * def middleName = 'middleName' + externalIdBody
    * def lastName = 'lastName' + externalIdBody
    * def email = 'email_update_positive_' + externalIdBody + '@test.com'
    * def createLCUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath
    And param apikey = apikey
    And request createLCUserRequest
    When method POST
    Then status 201

    * createLCUserRequest.generalInfo.firstName = 'New First Name'

    Given url edgeUrl
    And path 'patron/account/' + externalSystemIdPath + '/by-email/' + email
    And param apikey = apikey
    And request createLCUserRequest
    When method PUT
    Then status 204

    Given url baseUrl
    And path 'users'
    And param query = 'personal.email=' + email
    And headers headers
    When method GET
    Then status 200
    And eval response.users.length > 0
    And match response.users[0].externalSystemId == externalId
    And match response.users[0].personal.firstName == 'New First Name'





