Feature: Consortia User Tenant associations api tests

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Authtoken-Refresh-Cache': 'true', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 1000 }

  Scenario: Create a user called 'centralUser1' in 'centralTenant' and verify there are following records:
    # create user called 'centralUser1' in 'centralTenant'
    * call read('classpath:common-consortia/initData.feature@PostUser') centralUser1

    # 1. 'centralUser1' has been saved in 'users' table in 'central_mod_users'

    # 2. 'centralUser1' has been saved in 'user_tenant' table in 'central_mod_users'
    * def queryParams = { username: '#(centralUser1.username)', userId: '#(centralUser1.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].barcode == '#notnull'
    And match response.userTenants[0].externalSystemId == '#uuid'
    And match response.userTenants[0].phoneNumber == centralUser1.phone
    And match response.userTenants[0].mobilePhoneNumber == centralUser1.mobilePhone
    And match response.userTenants[0].consortiumId == consortiumId
    And match response.userTenants[0].centralTenantId == centralTenant

    # 3. primary affiliation for 'centralUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { username: '#(centralUser1.username)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == centralUser1.id
    And match response.userTenants[0].isPrimary == true

  # We have 'centralUser1' in 'centralTenant'
  Scenario: POST, DELETE, re-POST non-primary affiliation for 'centralUser1' verify there are following records (con-7):
    # POST non-primary affiliation for 'centralUser1' (for 'universityTenant')
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(centralUser1.id)', tenantId :'#(universityTenant)'}
    When method POST
    Then status 200
    And match response.userId == centralUser1.id
    And match response.username contains centralUser1.username
    And match response.tenantId == universityTenant
    And match response.isPrimary == false

    * def shadowCentralUser1Username = response.username
    * def shadowCentralUser1Id = centralUser1.id

    # 1. shadow 'centralUser1' has been saved in 'users' table in 'university_mod_users'
    Given path 'users'
    And param query = 'username=' + shadowCentralUser1Username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].id == centralUser1.id
    And match response.users[0].active == true

    # 2. shadow 'centralUser1' has empty permissions (in 'universityTenant')
    Given path 'perms/users'
    And param query = 'userId=' + shadowCentralUser1Id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

    # DELETE non-primary affiliation for 'centralUser1' (for 'universityTenant')
    * def queryParams = { userId: '#(shadowCentralUser1Id)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method DELETE
    Then status 204

    # 3. shadow 'centralUser1' has been deactivated (in 'users' table in 'university_mod_users')
    Given path 'users'
    And param query = 'username=' + shadowCentralUser1Username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].id == centralUser1.id
    And match response.users[0].active == false

    # re-POST non-primary affiliation for 'centralUser1' (for 'universityTenant')
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(centralUser1.id)', tenantId :'#(universityTenant)'}
    When method POST
    Then status 200
    And match response.userId == centralUser1.id
    And match response.username contains centralUser1.username
    And match response.tenantId == universityTenant
    And match response.isPrimary == false

    # 4. shadow 'centralUser1' has been reactivated (in 'users' table in 'university_mod_users')
    Given path 'users'
    And param query = 'username=' + shadowCentralUser1Username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].id == centralUser1.id
    And match response.users[0].active == true

  # We have shadow 'centralUser1' in 'universityTenant' with 'active'=true, and empty permission
  Scenario: Verify DELETE, re-POST of non-primary affiliation does not affect permissions of the user (con-8):
    * def shadowCentralUser1Id = centralUser1.id

    # get shadow 'centralUser1's' username
    * def queryParams = { userId: '#(shadowCentralUser1Id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(userTenant) {return  userTenant.tenantId == universityTenant }
    * def userTenants = karate.filter(response.userTenants, fun)

    And assert karate.sizeOf(userTenants) == 1
    And match userTenants[0].username contains centralUser1.username
    And match userTenants[0].isPrimary == false

    * def shadowCentralUser1Username = userTenants[0].username

    # 1. add non-empty permission to shadow 'centralUser1'
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { id: '#(shadowCentralUser1Id)', tenant: '#(universityTenant)', desiredPermissions: ['consortia.all']}

    # 2. get updated permissions of shadow 'centralUser1'
    Given path 'perms/users'
    And param query = 'userId=' + shadowCentralUser1Id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions != []
    * def updatedNonEmptyPermissionsOfShadowCentralUser1 = response.permissionUsers[0].permissions

    # DELETE non-primary affiliation for 'centralUser1' (for 'universityTenant')
    * def queryParams = { userId: '#(shadowCentralUser1Id)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method DELETE
    Then status 204

    # re-POST non-primary affiliation for 'centralUser1' (for 'universityTenant')
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(centralUser1.id)', tenantId :'#(universityTenant)'}
    When method POST
    Then status 200
    And match response.userId == centralUser1.id
    And match response.username contains centralUser1.username
    And match response.tenantId == universityTenant
    And match response.isPrimary == false

    # 3. verify that permissions of shadow 'centralUser1' after re-POST is not changes
    Given path 'perms/users'
    And param query = 'userId=' + shadowCentralUser1Id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == updatedNonEmptyPermissionsOfShadowCentralUser1

  # We have 'centralUser1' in 'centralTenant' and shadow 'centralUser1' in 'universityTenant'
  Scenario: If we DELETE real user all records related to this user should be deleted (con-9):
    # DELETE 'centralUser1'
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/plain' }
    Given path 'users', centralUser1.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)' }
    When method DELETE
    Then status 204

    # 1. verify there is no record in 'users' table in 'central_mod_users' for 'centralUser1'
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

    # 2. verify there is no record in 'user_tenant' table in 'central_mod_users' for 'centralUser1'
    * def queryParams = { userId: '#(centralUser1.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 0
    When method GET
    Then status 200

    # 3. verify there is no record in 'user_tenant' table in 'central_mod_consortia' for 'centralUser1'
    # (both primary and non-primary)
    * def queryParams = { userId: '#(centralUser1.id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until responseStatus == 404
    When method GET
    And match response.errors[0].message == 'Object with userId [' + centralUser1.id +'] was not found'
    And match response.errors[0].type == '-1'
    And match response.errors[0].code == 'NOT_FOUND_ERROR'

    # 4. verify there is no record in 'users' table in 'university_mod_users' for 'centralUser1'
    Given path 'users', centralUser1.id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until responseStatus == 404
    When method GET

  Scenario: Create a user called 'universityUser2' in 'universityTenant' and verify there are following records (con-10):
    # create user called 'universityUser2' in 'universityTenant'
    * call read('classpath:common-consortia/initData.feature@PostUser') universityUser2

    # 1. 'universityUser2' has been saved in 'users' table in 'university_mod_users'
    Given path 'users'
    And param query = 'username=' + universityUser2.username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.users[0].id == universityUser2.id

    # 2. 'universityUser2' has been saved in 'user_tenant' table in 'central_mod_users'
    * def queryParams = { username: '#(universityUser2.username)', userId: '#(universityUser2.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == universityTenant

    # 3. primary affiliation for 'universityUser2' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { username: '#(universityUser2.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == universityUser2.id
    And match response.userTenants[0].isPrimary == true

    # 4. shadow 'universityUser2' has been saved in 'users' table in 'central_mod_users'
    Given path 'users', universityUser2.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    Given path 'users', universityUser2.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == universityUser2.id
    And match response.username contains universityUser2.username
    And match response.active == true

    # 5. non-primary affiliation for shadow 'universityUser2' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { userId: '#(universityUser2.id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(userTenant) {return  userTenant.tenantId == centralTenant }
    * def userTenants = karate.filter(response.userTenants, fun)

    And assert karate.sizeOf(userTenants) == 1
    And match userTenants[0].username contains universityUser2.username
    And match userTenants[0].isPrimary == false

    # 6. shadow 'universityUser2' has empty permissions (in 'centralTenant')
    Given path 'perms/users'
    And param query = 'userId=' + universityUser2.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

  # We have 'universityUser2' in 'universityTenant' and shadow 'universityUser2' in 'centralTenant'
  Scenario: If we DELETE real user all records related to this user should be deleted (con-11):
    # DELETE 'universityUser2'
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/plain' }
    Given path 'users', universityUser2.id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)' }
    When method DELETE
    Then status 204

    # 1. verify there is no record in 'users' table in 'central_mod_users' for 'universityUser2'
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    Given path 'users', universityUser2.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until responseStatus == 404
    When method GET

    # 2. verify there is no record in 'user_tenant' table in 'central_mod_users' for 'universityUser2'
    * def queryParams = { userId: '#(universityUser2.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 0
    When method GET
    Then status 200

    # 3. verify there is no record in 'user_tenant' table in 'central_mod_consortia' for 'universityUser2'
    # (both primary and non-primary)
    * def queryParams = { userId: '#(universityUser2.id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until responseStatus == 404
    When method GET
    And match response.errors[0].message == 'Object with userId [' + universityUser2.id +'] was not found'
    And match response.errors[0].type == '-1'
    And match response.errors[0].code == 'NOT_FOUND_ERROR'

    # 4. verify there is no record in 'users' table in 'university_mod_users' for 'universityUser2'

  Scenario: Verify there are following records for 'universityUser1' (con-3):
    # 1. 'universityUser1' has been saved in 'users' table in 'university_mod_users'

    # 2. 'universityUser1' has been saved in 'user_tenant' table in 'central_mod_users'
    * def queryParams = { username: '#(universityUser1.username)', userId: '#(universityUser1.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == universityTenant
    And match response.userTenants[0].barcode == '#notnull'
    And match response.userTenants[0].externalSystemId == '#uuid'
    And match response.userTenants[0].phoneNumber == universityUser1.phone
    And match response.userTenants[0].mobilePhoneNumber == universityUser1.mobilePhone
    And match response.userTenants[0].consortiumId == consortiumId
    And match response.userTenants[0].centralTenantId == centralTenant

    # 3. primary affiliation for 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { username: '#(universityUser1.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == universityUser1.id
    And match response.userTenants[0].isPrimary == true

    * def shadowUniversityUser1Id = universityUser1.id

    # 4. shadow 'universityUser1' has been saved in 'users' table in 'central_mod_users'
    Given path 'users', universityUser1.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == universityUser1.id
    And match response.username contains universityUser1.username
    And match response.active == true
    And match response.customFields.originaltenantid == universityTenant
    * def shadowUniversityUser1Username = response.username

    # 5. non-primary affiliation for shadow 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { username: '#(shadowUniversityUser1Username)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == shadowUniversityUser1Id
    And match response.userTenants[0].isPrimary == false

    # 6. shadow 'universityUser1' has empty permissions (in 'centralTenant')
    Given path 'perms/users'
    And param query = 'userId=' + shadowUniversityUser1Id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

  @Positive
  Scenario: Create and verify all details of shadow user
    * def userWithFullDetailsId = 'fc20092e-629b-4451-9631-a22f8bdeda4d'
    * def userWithFullDetailsUsername = 'userwithfulldetails'
    * def userWithFullDetailsFirstname = 'firstname'
    * def userWithFullDetailsLastname = 'lastname'
    * def userWithFullDetailsEmail = 'x@gmail.com'
    * def userWithFullDetailsPreferredContactTypeId = 'email'

    # 1. create user in centralTenant
    Given path 'users'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
      "active": true,
      "personal": {
        "firstName": "#(userWithFullDetailsFirstname)",
        "lastName": "#(userWithFullDetailsLastname)",
        "preferredContactTypeId": "#(userWithFullDetailsPreferredContactTypeId)",
        "email": "#(userWithFullDetailsEmail)"
      },
      "username": "#(userWithFullDetailsUsername)",
      "id": "#(userWithFullDetailsId)",
      "departments": [],
      "type": "staff"
    }
    """
    When method POST
    Then status 201

    # 2. check user details in central tenant
    Given path 'users'
    And param query = 'username=' + userWithFullDetailsUsername
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.users[0].id == userWithFullDetailsId
    And match response.users[0].username == userWithFullDetailsUsername
    And match response.users[0].active == true

    # 2.1 Check that user primary affiliation of 'userWithFullDetailsUsername' exists in user-tenant table
    * def queryParams = { username: '#(userWithFullDetailsUsername)', userId: '#(userWithFullDetailsId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    # 3. POST non-primary affiliation for 'userwithfulldetails' (for 'universityTenant')
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(userWithFullDetailsId)', tenantId :'#(universityTenant)'}
    When method POST
    Then status 200
    And match response.userId == userWithFullDetailsId
    And match response.username contains userWithFullDetailsUsername
    And match response.tenantId == universityTenant
    And match response.isPrimary == false

    * def userWithFullDetails1Username = response.username

    # 4. verify that shadow 'userwithfulldetails' has been saved in 'users' table in 'university_mod_users'
    Given path 'users'
    And param query = 'username=' + userWithFullDetails1Username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].id == userWithFullDetailsId
    And match response.users[0].username contains userWithFullDetailsUsername
    And match response.users[0].personal.firstName == userWithFullDetailsFirstname
    And match response.users[0].personal.lastName == userWithFullDetailsLastname
    And match response.users[0].personal.email == userWithFullDetailsEmail
    And match response.users[0].personal.preferredContactTypeId == userWithFullDetailsPreferredContactTypeId
    And match response.users[0].type == 'shadow'
    And match response.users[0].active == true

  @Positive
  Scenario: Verify that after soft deletion of tenant, user tenant, associating with the tenant, must not show
    # 1. we will check three cases and we will check again after soft deletion
    * def queryParams = { limit: 999}
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.userTenants contains deep {tenantId: '#(universityTenant)'}
    * def sizeOfActualUserTenant = response.totalRecords

    * def queryParams = { username: '#(universityUser1.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    Given path 'consortia', consortiumId, '_self'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.userTenants contains deep {tenantId: '#(universityTenant)'}
    And match response.totalRecords == 3

    # 2. Soft delete 'universityTenant' (isCentral = false)
    Given path 'consortia', consortiumId, 'tenants', universityTenant
    When method DELETE
    Then status 204

    # 3. Check again, there must not be any record based on shown condition below
    * def queryParams = { limit: 999}
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords != sizeOfActualUserTenant

    * def queryParams = { username: '#(universityUser1.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(   okapitoken)'}
    When method GET
    Then status 404

    Given path 'consortia', consortiumId, '_self'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 2

  @Positive
  Scenario: Verify that after re-adding soft deleted tenant, user tenant associations must be shown
    # 1.  re-post 'universityTenant' (isCentral = false) it should be re-enabled
    #     previous code or name can be used to re-add tenant (name 'University tenants name 2' is already used by itself as soft deleted tenant)
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(universityTenant)', code: 'FOL', name: 'University tenants name 2', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(universityTenant)', code: 'FOL', name: 'University tenants name 2', isCentral: false, isDeleted:false }

    # 2. Check again, there must be records which relate to 'universityTenant'
    * def queryParams = { limit: 999}
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == sizeOfActualUserTenant
    When method GET
    Then status 200
    And match response.userTenants contains deep {tenantId: '#(universityTenant)'}
    And match response.totalRecords == sizeOfActualUserTenant

    * def queryParams = { username: '#(universityUser1.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    Given path 'consortia', consortiumId, '_self'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.userTenants contains deep {tenantId: '#(universityTenant)'}
    And match response.totalRecords == 3