Feature: LC user registration tests tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * callonce read('classpath:vega/edge-patron/features/util/lc-initData.feature@PostPatronGroupAndUser')
    * def homeAddress = callonce read('classpath:vega/edge-patron/features/util/lc-initData1.feature@CreateHomeAddressType')
    * def homeAddressTypeId = homeAddress.homeAddressTypeId
    * print 'homeAddressTypeId:', homeAddress


  # POST
  Scenario: [Positive] POST:success:201 and Test if registered successfully
    * print '[Positive] Register a new staging-user user and Test if registered successfully'
    * def random_num = call random_numbers
    * def firstName = 'firstName' + random_num
    * def middleName = 'middleName' + random_num
    * def lastName = 'lastName' + random_num
    * def status = 'TIER-2'
    * def email = 'karate-' + random_num + '@karatetest.com'
    * def createStagingUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron'
    And param apikey = apikey
    And request createStagingUserRequest
    When method POST
    Then status 201


  Scenario: [Negative] POST:failed:400 and Test if 400 if pass invalid status enum
    * print '[Negative] Register a new staging-user user and Test if 400 if pass invalid status enum'
    * def random_num = call random_numbers
    * def firstName = 'firstName' + random_num
    * def middleName = 'middleName' + random_num
    * def lastName = 'lastName' + random_num
    * def status = 'INVALID_STATUS'
    * def email = 'karate-' + random_num + '@karatetest.com'
    * def createStagingUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron'
    And param apikey = apikey
    And request createStagingUserRequest
    When method POST
    Then status 400

  Scenario: [Negative] POST:failed:422 and Test if 422 if pass invalid status enum
    * print '[Negative] Register a new staging-user user and Test if 400 if pass invalid status enum'
    * def status = 'TIER-2'
    * def createStagingUserRequest = read('samples/user/create-lc-user-request.json')
    # pass invalid json key generalInfo1
    * createStagingUserRequest['generalInfo1'] = {};
    * createStagingUserRequest['generalInfo1']['firstName'] = 'NEW_FIRST_NAME'

    Given url edgeUrl
    And path 'patron'
    And param apikey = apikey
    And request createStagingUserRequest
    When method POST
    Then status 422


  # PUT API
  Scenario: [Positive] PUT:Success:201 and Test if updating successfully except externalSystemId
    * print '[Positive] Updating an existing staging-user and Test if updating successfully except externalSystemId'
    * def random_num = call random_numbers
    * def firstName = 'firstName' + random_num
    * def middleName = 'middleName' + random_num
    * def lastName = 'lastName' + random_num
    * def status = 'TIER-2'
    * def email = 'karate-' + random_num + '@karatetest.com'
    * def createStagingUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron'
    And param apikey = apikey
    And request createStagingUserRequest
    When method POST
    Then status 201

    * def oldExternalSystemId = response.externalSystemId
    * createStagingUserRequest.generalInfo.firstName = 'NEW_FIRST_NAME'
    * def newExternalSystemId = call random_uuid
    * createStagingUserRequest.externalSystemId = newExternalSystemId

    Given url edgeUrl
    And path 'patron/' + oldExternalSystemId
    And param apikey = apikey
    And request createStagingUserRequest
    When method PUT
    Then status 200
    And eval response.generalInfo.firstName == "NEW_FIRST_NAME"
    And eval response.externalSystemId == oldExternalSystemId


  Scenario: [Negative] PUT:failed:404 and Test if error STAGING_USER_NOT_FOUND when passing wrong externalSystemId
    * print '[Positive] Updating an existing staging-user and Test if updating successfully except externalSystemId'
    * def random_num = call random_numbers
    * def firstName = 'firstName' + random_num
    * def middleName = 'middleName' + random_num
    * def lastName = 'lastName' + random_num
    * def status = 'TIER-2'
    * def email = 'karate-' + random_num + '@karatetest.com'
    * def createStagingUserRequest = read('samples/user/create-lc-user-request.json')

    * def externalSystemId = call random_uuid

    Given url edgeUrl
    And path 'patron/' + externalSystemId
    And param apikey = apikey
    And request createStagingUserRequest
    When method PUT
    Then status 404
    And eval response.code == "STAGING_USER_NOT_FOUND"

  Scenario: [Positive] GET:success:200 and Test registration status if user found via email or extSysId
    * print '[Positive] GET:success:200 and Test registration status if user found via email or extSysId'

    Given url baseUrl
    And path 'groups'
    And param query = 'group=Remote Non-circulating'
    And headers headers
    When method GET
    Then status 200
    And eval response.usergroups.length > 0
    And match response.usergroups[0].group == 'Remote Non-circulating'
    * def patronId = response.usergroups[0].id

    * def random_num = call random_numbers
    * def lastName = 'lastName' + random_num
    * def firstName = 'firstName' + random_num
    * def email = 'karate-' + random_num + '@karatetest.com'
    * def userBarcode = 'barcode_' + random_num
    * def type = 'patron'
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_uuid
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    # Fetch registration status via email
    Given url edgeUrl
    And path 'patron/registration-status'
    And param apikey = apikey
    And param emailId = email
    When method GET
    Then status 200
    And match response.externalSystemId == externalId

    # Fetch registration status via externalId
    Given url edgeUrl
    And path 'patron/registration-status'
    And param apikey = apikey
    And param externalSystemId = externalId
    When method GET
    Then status 200
    And match response.personal.email == email



  Scenario: [Positive] GET:failed:400 and Test registration status if error MULTIPLE_USER_WITH_EMAIL
    * print '[Positive] GET:failed:400 and Test registration status if error MULTIPLE_USER_WITH_EMAIL'

    Given url baseUrl
    And path 'groups'
    And param query = 'group=Remote Non-circulating'
    And headers headers
    When method GET
    Then status 200
    And eval response.usergroups.length > 0
    And match response.usergroups[0].group == 'Remote Non-circulating'
    * def patronId = response.usergroups[0].id

    * def random_num = call random_numbers
    * def lastName = 'lastName' + random_num
    * def firstName = 'firstName' + random_num
    * def email = 'karate-' + random_num + '@karatetest.com'
    * def userBarcode = 'barcode_' + random_num
    * def type = 'patron'
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_uuid
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    * def random_num = call random_numbers
    * def userName = call random_uuid
    * def userId = call random_uuid
    * def userBarcode = 'barcode_' + random_num
    * def externalId = call random_uuid
    * createUserRequest.barcode = userBarcode
    * createUserRequest.username = userName
    * createUserRequest.id = userId
    * createUserRequest.externalSystemId = externalId

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    # Validate if 400 and MULTIPLE_USER_WITH_EMAIL
    Given url edgeUrl
    And path 'patron/registration-status'
    And param apikey = apikey
    And param emailId = email
    When method GET
    Then status 400
    And match response.code == 'MULTIPLE_USER_WITH_EMAIL'


  Scenario: [Positive] GET:failed:400 and Test registration status error if pass both emailId and externalSystemId
    * print '[Positive] GET:failed:400 and Test registration status error if pass both emailId and externalSystemId'

    # Validate if 400 and MULTIPLE_USER_WITH_EMAIL
    Given url edgeUrl
    And path 'patron/registration-status'
    And param apikey = apikey
    And param emailId = 'karate@test.com'
    And param externalSystemId = call random_uuid
    When method GET
    Then status 400

  Scenario: [Positive] GET:failed:400 and Test registration status error if not pass both emailId and externalSystemId
    * print '[Positive] GET:failed:400 and Test registration status error if not pass both emailId and externalSystemId'
    Given url edgeUrl
    And path 'patron/registration-status'
    And param apikey = apikey
    When method GET
    Then status 400

  # Merge API
  Scenario: [Positive] POST:success:201 and Test if registered successfully
    * print '[Positive] Register a new staging-user user and Test if registered successfully'

    # Creating patron group=Remote Non-circulating
    Given url baseUrl
    And path 'groups'
    And param query = 'group=Remote Non-circulating'
    And headers headers
    When method GET
    Then status 200
    And eval response.usergroups.length > 0
    And match response.usergroups[0].group == 'Remote Non-circulating'
    * def patronId = response.usergroups[0].id

    # creating main user
    * def random_num = call random_numbers
    * def lastName = 'lastName' + random_num
    * def firstName = 'firstName' + random_num
    * def email = 'karate-user' + random_num + '@karatetest.com'
    * def userBarcode = 'barcode_' + random_num
    * def type = 'patron'
    * def userName = call random_string
    * def userId = call random_uuid
    * def externalId = call random_uuid
    * def createUserRequest = read('samples/user/create-user-request.json')

    Given url baseUrl
    Given path 'users'
    And headers headers
    And request createUserRequest
    When method POST
    Then status 201

    # Creating staging-user
    * def random_num = call random_numbers
    * def firstName = 'firstName' + random_num
    * def middleName = 'middleName' + random_num
    * def lastName = 'lastName' + random_num
    * def status = 'TIER-2'
    * def email = 'karate-staging-user' + random_num + '@karatetest.com'
    * def createStagingUserRequest = read('samples/user/create-lc-user-request.json')


    Given url edgeUrl
    And path 'patron'
    And param apikey = apikey
    And request createStagingUserRequest
    When method POST
    Then status 201
    * def stagingUserId = response.id
    * def stagingExtSysId = response.externalSystemId

    # creating staging-user into main user
    Given url baseUrl
    And path 'staging-users/' + stagingUserId + '/mergeOrCreateUser'
    And param userId = userId
    And headers headers
    When method PUT
    Then status 200

    # Fetch registration status via externalId
    Given url edgeUrl
    And path 'patron/registration-status'
    And param apikey = apikey
    And param externalSystemId = stagingExtSysId
    When method GET
    Then status 200
    And match response.personal.email == email
    And match response.personal.firstName == firstName


  Scenario: [Positive] POST:failed:404 and Test if User not found error
    * print '[Positive] POST:failed:404 and Test if User not found error'
    # Creating staging-user
    * def random_num = call random_numbers
    * def firstName = 'firstName' + random_num
    * def middleName = 'middleName' + random_num
    * def lastName = 'lastName' + random_num
    * def status = 'TIER-2'
    * def email = 'karate-staging-user' + random_num + '@karatetest.com'
    * def createStagingUserRequest = read('samples/user/create-lc-user-request.json')

    Given url edgeUrl
    And path 'patron'
    And param apikey = apikey
    And request createStagingUserRequest
    When method POST
    Then status 201
    * def stagingUserId = response.id
    * def stagingExtSysId = response.externalSystemId

    * def invalidUserId = call random_uuid

    # try creating staging-user into main user
    Given url baseUrl
    And path 'staging-users/' + stagingUserId + '/mergeOrCreateUser'
    And param userId = invalidUserId
    And headers headers
    When method PUT
    Then status 404
    And match response contains 'user with id ' + invalidUserId + ' not found'

  Scenario: [Positive] POST:failed:404 and Test if Staging-User not found error
    * print '[Positive] POST:failed:404 and Test if Staging-User not found error'

    * def invalidStagingUserId = call random_uuid
    * def userId = call random_uuid

    # try merging staging-user into main user
    Given url baseUrl
    And path 'staging-users/' + invalidStagingUserId + '/mergeOrCreateUser'
    And param userId = userId
    And headers headers
    When method PUT
    Then status 404
    And match response contains 'staging user with id ' + invalidStagingUserId + ' not found'
