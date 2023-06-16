Feature: Consortia User Tenant associations api tests

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  # At this point each tenant has following users:
  # 'centralAdmin' in 'centralTenant';
  # 'consortia-system-user' in 'centralTenant' (automatically created when 'mod-consortia' was enabled);
  # 'universityAdmin' in 'universityTenant';
  # 'consortia-system-user' in 'universityTenant' (automatically created when 'mod-consortia' was enabled);

  Scenario: Verify there are following records for 'centralAdmin':
    # 1. 'centralAdmin' has been saved in 'users' table in 'central_mod_users'
    # 2. 'centralAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'centralAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 4. shadow 'centralAdmin' has been saved in 'users' table in 'university_mod_users'
    # 5. non-primary affiliation for shadow 'centralAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 6. shadow 'centralAdmin' has required permissions (in 'universityTenant')

    # 2. 'centralAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(centralAdmin.username)', userId: '#(centralAdmin.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 3. primary affiliation for 'centralAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(centralAdmin.username)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == centralAdmin.id
    And match response.userTenants[0].isPrimary == true

    * def shadowCentralAdminUserId = centralAdmin.id
    # 4. shadow 'centralAdmin' has been saved in 'users' table in 'university_mod_users'
    * call read(login) universityAdmin
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(user) {return  user.id == shadowCentralAdminUserId }
    * def users = karate.filter(response.users, fun)

    And assert karate.sizeOf(users) == 1
    And match users[0].username contains centralAdmin.username
    * def shadowCentralAdminUserName = users[0].username

    # 5. non-primary affiliation for shadow 'centralAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(shadowCentralAdminUserName)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == shadowCentralAdminUserId
    And match response.userTenants[0].isPrimary == false

    # 6. verify shadow 'centralAdmin' has required permissions (in 'universityTenant')
    * call read(login) universityAdmin
    Given path 'perms/users'
    And param query = 'userId=' + shadowCentralAdminUserId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == ['ui-users.editperms']

  Scenario: Verify there are following records for 'consortia-system-user' of 'centralTenant':
    # 1. 'consortia-system-user' has been saved in 'users' table in 'central_mod_users'
    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 4. 'consortia-system-user' has required permissions

    # 1. 'consortia-system-user' has been saved in 'users' table in 'central_mod_users'
    * call read(login) centralAdmin
    Given path 'users'
    And param query = 'username=' + consortiaSystemUserName
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def consortiaSystemUserInCentralId = response.users[0].id

    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(consortiaSystemUserName)', userId: '#(consortiaSystemUserInCentralId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(consortiaSystemUserName)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == consortiaSystemUserInCentralId
    And match response.userTenants[0].isPrimary == true

    # 4. 'consortia-system-user' has required permissions
    * call read(login) centralAdmin
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserInCentralId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == '#[14]'

  Scenario: Verify there are following records for 'universityAdmin':
    # 1. 'universityAdmin' has been saved in 'users' table in 'university_mod_users'
    # 2. 'universityAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'universityAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 4. shadow 'universityAdmin' has been saved in 'users' table in 'central_mod_users'
    # 5. non-primary affiliation for shadow 'universityAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 6. shadow 'universityAdmin' has empty permissions (in 'centralTenant')

    # 2. 'universityAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(universityAdmin.username)', userId: '#(universityAdmin.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 3. primary affiliation for 'universityAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(universityAdmin.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == universityAdmin.id
    And match response.userTenants[0].isPrimary == true

    * def shadowUniversityAdminUserId = universityAdmin.id
    # 4. shadow 'universityAdmin' has been saved in 'users' table in 'central_mod_users'
    * call read(login) centralAdmin
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(user) {return  user.id == shadowUniversityAdminUserId }
    * def users = karate.filter(response.users, fun)

    And assert karate.sizeOf(users) == 1
    And match users[0].username contains universityAdmin.username
    * def shadowUniversityAdminUserName = users[0].username

    # 5. non-primary affiliation for shadow 'universityAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(shadowUniversityAdminUserName)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == shadowUniversityAdminUserId
    And match response.userTenants[0].isPrimary == false

    # 6. shadow 'universityAdmin' has empty permissions (in 'centralTenant')
    * call read(login) centralAdmin
    Given path 'perms/users'
    And param query = 'userId=' + shadowUniversityAdminUserId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

  Scenario: Verify there are following records for 'consortia-system-user' of 'universityTenant':
    # 1. 'consortia-system-user' has been saved in 'users' table in 'university_mod_users'
    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 4. 'consortia-system-user' has required permissions
    # 5. shadow 'consortia-system-user' has been saved in 'users' table in 'central_mod_users'
    # 6. non-primary affiliation for shadow 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 7. shadow 'consortia-system-user' of 'universityTenant' has empty permissions (in 'centralTenant')

    # 1. 'consortia-system-user' has been saved in 'users' table in 'university_mod_users'
    * call read(login) universityAdmin
    Given path 'users'
    And param query = 'username=' + consortiaSystemUserName
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def consortiaSystemUserInUniversityId = response.users[0].id

    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(consortiaSystemUserName)', userId: '#(consortiaSystemUserInUniversityId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(consortiaSystemUserName)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == consortiaSystemUserInUniversityId
    And match response.userTenants[0].isPrimary == true

    # 4. 'consortia-system-user' has required permissions
    * call read(login) universityAdmin
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserInUniversityId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == '#[14]'

    # 5. shadow 'consortia-system-user' has been saved in 'users' table in 'central_mod_users'
    * call read(login) centralAdmin
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(user) {return  user.id == consortiaSystemUserInUniversityId }
    * def users = karate.filter(response.users, fun)

    And assert karate.sizeOf(users) == 1
    And match users[0].username contains consortiaSystemUserName

    # 6. non-primary affiliation for shadow 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { userId: '#(consortiaSystemUserInUniversityId)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(userTenant) {return  userTenant.tenantId == centralTenant }
    * def userTenants = karate.filter(response.userTenants, fun)

    And assert karate.sizeOf(userTenants) == 1
    And match userTenants[0].username contains consortiaSystemUserName
    And match userTenants[0].isPrimary == false

    # 7. shadow 'consortia-system-user' of 'universityTenant' has empty permissions (in 'centralTenant')
    * call read(login) centralAdmin
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserInUniversityId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

#  # We need to ass required permissions to shadow 'universityAdmin' to be able to work further
#  Scenario: Get 'universityAdmin' permissions (in 'universityTenant') and add these permissions to shadow user for 'universityAdmin' (in 'centralTenant')
#    # get permissions of 'universityAdmin' in 'universityTenant'
#    * call read(login) universityAdmin
#    Given path 'perms/users'
#    And param query = 'userId=' + id
#    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
#    When method GET
#    Then status 200
#
#    * def newPermissions = $.permissionUsers[0].permissions
#
#    # get permissions of shadow 'universityAdmin' in 'centralTenant'
#    * call read(login) centralAdmin
#    Given path 'perms/users'
#    And param query = 'userId=' + universityAdmin.id
#    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
#    When method GET
#    Then status 200
#
#    # add required permissions to shadow user
#    * def permissionEntry = $.permissionUsers[0]
#    * def updatedPermissions = karate.append(newPermissions, permissionEntry.permissions)
#    And set permissionEntry.permissions = updatedPermissions
#
#    # update permissions of shadow 'universityAdmin' in 'centralTenant'
#    Given path 'perms/users', permissionEntry.id
#    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
#    And request permissionEntry
#    When method PUT
#    Then status 200
#
#    # pause
#    * call pause 100000
#
#  Scenario: Create user for 'universityTenant' and verify that the user can login to 'universityTenant' and login through 'centralTenant'
#    # Create a user in 'universityTenant' with credentials and verify following:
#    # 1. 'universityUser1' can login to 'universityTenant' - No need to check
#    # 2. 'universityUser1' has been saved in 'users' table in 'central_mod_users'
#    # 3. primary affiliation for 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
#    # 4. non-primary affiliation for 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
#    # 5. shadow user for 'universityUser1' has empty permissions (in 'centralTenant')
#
#    # Create a user in 'universityTenant' with credentials
#    * call read(login) universityAdmin
#    * call read('features/util/initData.feature@PostUser') universityUser1
#
#    * configure retry = { count: 10, interval: 3000 }
#
#    # 2. 'universityUser1' has been saved in 'users' table in 'central_mod_users'
#    * call read(login) centralAdmin
#    Given path 'users'
#    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
#    When method GET
#    Then status 200
#
#    * def fun = function(user) {return  user.id == universityUser1.id }
#    * def users = karate.filter(response.users, fun)
#
#    And assert karate.sizeOf(users) == 1
#    And match users[0].username contains universityUser1.username
#
#    # 3. primary affiliation for 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
#    * call read(login) centralAdmin
#    * def queryParams = { username: '#(universityUser1.username)', tenantId: '#(universityTenant)' }
#    Given path 'consortia', consortiumId, 'user-tenants'
#    And params query = queryParams
#    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
#    And retry until responseStatus == 200
#    When method GET
#    And match response.totalRecords == 1
#    And match response.userTenants[0].userId == universityUser1.id
#    And match response.userTenants[0].isPrimary == true
#
#    # 4. non-primary affiliation for 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
#    * call read(login) centralAdmin
#    * def queryParams = { userId: '#(universityUser1.id)' }
#    Given path 'consortia', consortiumId, 'user-tenants'
#    And params query = queryParams
#    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
#    When method GET
#    Then status 200
#
#    * def fun = function(userTenant) {return  userTenant.tenantId == centralTenant }
#    * def userTenants = karate.filter(response.userTenants, fun)
#
#    And assert karate.sizeOf(userTenants) == 1
#    And match userTenants[0].username contains universityUser1.username
#    And match userTenants[0].isPrimary == false
#
#    # 5. shadow user for 'universityUser1' has empty permissions (in 'centralTenant')
#    * call read(login) centralAdmin
#    Given path 'perms/users'
#    And param query = 'userId=' + universityUser1.id
#    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
#    When method GET
#    Then status 200
#
#    And match response.totalRecords == 1
#    And match response.permissionUsers[0].permissions == []
