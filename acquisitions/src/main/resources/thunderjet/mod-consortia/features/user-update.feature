Feature: Consortia User update api tests

  Background:
    * url baseUrl
    * configure retry = { count: 10, interval: 1000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    * def universityUser3 = { id: '6a4a5e12-0559-4869-a495-f35832fda797', username: 'university_user3', password: 'university_user3_password', tenant: '#(universityTenant)'}
    * def newUsername = 'universityUserNEW'
    * def newEmail = 'newUser@gmail.com'
    * def phone = '54321'
    * def mobilePhone = '12345'

  # There will be only one admin user, so need to add permissions of 'consortiaAdmin' to shadow 'consortiaAdmin'
  Scenario: Add permissions of 'consortiaAdmin' to shadow 'consortiaAdmin' (con-5)
    * print "Add permissions of 'consortiaAdmin' to shadow 'consortiaAdmin' (con-5)"
    # get permissions of 'consortiaAdmin'
    * print "login1"
    * call read(login) consortiaAdmin
    Given path 'perms/users'
    And param query = 'userId=' + id
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def newPermissions = $.permissionUsers[0].permissions

    # get permissions of shadow 'consortiaAdmin'
    * print "login2"
    * call read(login) consortiaAdmin
    * print "get permissions of shadow consortiaAdmin"
    Given path 'perms/users'
    And param query = 'userId=' + id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    # add required permissions to shadow user
    * def permissionEntry = $.permissionUsers[0]
    * def updatedPermissions = karate.append(newPermissions, permissionEntry.permissions)
    And set permissionEntry.permissions = updatedPermissions

    # update permissions of shadow 'consortiaAdmin'
    Given path 'perms/users', permissionEntry.id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request permissionEntry
    When method PUT
    Then status 200

    # pause
    * call pause 70000

  Scenario: Create a user called 'universityUser3' in 'universityTenant' and verify there are following records (con-10):
    # create user called 'universityUser3' in 'universityTenant'
    * print "login3"
    * call read(login) consortiaAdmin
    * call read('features/util/initData.feature@PostUser') universityUser3

    # 1. 'universityUser3' has been saved in 'users' table in 'university_mod_users'
    * print "login4"
    * call read(login) consortiaAdmin
    Given path 'users'
    And param query = 'username=' + universityUser3.username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.users[0].id == universityUser3.id

    # 2. 'universityUser3' has been saved in 'user_tenant' table in 'central_mod_users'
    * print "login5"
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(universityUser3.username)', userId: '#(universityUser3.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == universityTenant

    # 3. primary affiliation for 'universityUser3' has been created in 'user_tenant' table in 'central_mod_consortia'
    * print "login6"
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(universityUser3.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == universityUser3.id
    And match response.userTenants[0].isPrimary == true

  Scenario: Update a user called 'universityUser3' in 'universityTenant'
    # 1. 'universityUser3' update 'email', 'mobilePhone', 'phone' and 'username' fields
    * print "login7"
    * call read(login) consortiaAdmin
    Given path 'users'
    And param query = 'username=' + universityUser3.username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until $.totalRecords == 1
    When method GET
    Then status 200
    And match $.users[0].id == universityUser3.id
    * def userForUpdate = $.users[0]

    * set userForUpdate.personal.email = newEmail
    * set userForUpdate.personal.mobilePhone = mobilePhone
    * set userForUpdate.personal.phone = phone
    * set userForUpdate.username = newUsername

    Given path 'users'
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request userForUpdate
    When method POST
    Then status 201

    # 2. 'universityUser2' has been saved in 'user_tenant' table in 'central_mod_users'
    * print "login8"
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(newUsername)', userId: '#(universityUser3.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == universityTenant
    And match response.userTenants[0].username == newUsername
    And match response.userTenants[0].phone == phone
    And match response.userTenants[0].mobilePhone == mobilePhone
    And match response.userTenants[0].email == newEmail

