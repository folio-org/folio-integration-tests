Feature: Consortia User Tenant associations api tests

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  # Before posting tenants to the consortium tenants had following users:
  # 'consortiaAdmin' in 'centralTenant';
  # 'consortia-system-user' in 'centralTenant' (automatically created when 'mod-consortia' was enabled);
  # 'pubsub-user' in 'centralTenant' (we will not check this users' associations);
  # 'universityUser1' in 'universityTenant';
  # 'consortia-system-user' in 'universityTenant' (automatically created when 'mod-consortia' was enabled);
  # 'pubsub-user' in 'universityTenant' (we will not check this users' associations);

  Scenario: Verify there are following records for 'consortiaAdmin':
    # 1. 'consortiaAdmin' has been saved in 'users' table in 'central_mod_users'

    # 2. 'consortiaAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(consortiaAdmin.username)', userId: '#(consortiaAdmin.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == centralTenant

    # 3. primary affiliation for 'consortiaAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(consortiaAdmin.username)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == consortiaAdmin.id
    And match response.userTenants[0].isPrimary == true

    * def shadowConsortiaAdminId = consortiaAdmin.id
    # 4. shadow 'consortiaAdmin' has been saved in 'users' table in 'university_mod_users'
    * call read(login) universityUser1
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(user) {return  user.id == shadowConsortiaAdminId }
    * def users = karate.filter(response.users, fun)

    And assert karate.sizeOf(users) == 1
    And match users[0].username contains consortiaAdmin.username
    * def shadowConsortiaAdminUsername = users[0].username

    # 5. non-primary affiliation for shadow 'consortiaAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(shadowConsortiaAdminUsername)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == shadowConsortiaAdminId
    And match response.userTenants[0].isPrimary == false

    # 6. verify shadow 'consortiaAdmin' has required permissions (in 'universityTenant')
    * call read(login) universityUser1
    Given path 'perms/users'
    And param query = 'userId=' + shadowConsortiaAdminId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == ['ui-users.editperms']

  Scenario: Verify there are following records for 'consortia-system-user' of 'centralTenant':
    # 1. 'consortia-system-user' has been saved in 'users' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    Given path 'users'
    And param query = 'username=' + consortiaSystemUserName
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def consortiaSystemUserInCentralId = response.users[0].id

    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(consortiaSystemUserName)', userId: '#(consortiaSystemUserInCentralId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == centralTenant

    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
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
    * call read(login) consortiaAdmin
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserInCentralId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == '#[14]'

  Scenario: Verify there are following records for 'universityUser1':
    # 1. 'universityUser1' has been saved in 'users' table in 'university_mod_users'

    # 2. 'universityUser1' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(universityUser1.username)', userId: '#(universityUser1.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == universityTenant

    # 3. primary affiliation for 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(universityUser1.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == universityUser1.id
    And match response.userTenants[0].isPrimary == true

    * def shadowUniversityUser1Id = universityUser1.id
    # 4. shadow 'universityUser1' has been saved in 'users' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(user) {return  user.id == shadowUniversityUser1Id }
    * def users = karate.filter(response.users, fun)

    And assert karate.sizeOf(users) == 1
    And match users[0].username contains universityUser1.username
    * def shadowUniversityUser1Username = users[0].username

    # 5. non-primary affiliation for shadow 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(shadowUniversityUser1Username)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == shadowUniversityUser1Id
    And match response.userTenants[0].isPrimary == false

    # 6. shadow 'universityUser1' has empty permissions (in 'centralTenant')
    * call read(login) consortiaAdmin
    Given path 'perms/users'
    And param query = 'userId=' + shadowUniversityUser1Id
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

  Scenario: Verify there are following records for 'consortia-system-user' of 'universityTenant':
    # 1. 'consortia-system-user' has been saved in 'users' table in 'university_mod_users'
    * call read(login) universityUser1
    Given path 'users'
    And param query = 'username=' + consortiaSystemUserName
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def consortiaSystemUserInUniversityId = response.users[0].id

    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(consortiaSystemUserName)', userId: '#(consortiaSystemUserInUniversityId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == universityTenant

    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
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
    * call read(login) universityUser1
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserInUniversityId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == '#[14]'

    # 5. shadow 'consortia-system-user' has been saved in 'users' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(user) {return  user.id == consortiaSystemUserInUniversityId }
    * def users = karate.filter(response.users, fun)

    And assert karate.sizeOf(users) == 1
    And match users[0].username contains consortiaSystemUserName

    # 6. non-primary affiliation for shadow 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
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
    * call read(login) consortiaAdmin
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserInUniversityId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

  # There will be only one admin user, so need to add permissions of 'consortiaAdmin' to shadow 'consortiaAdmin'
  Scenario: Add permissions of 'consortiaAdmin' to shadow 'consortiaAdmin'
    # get permissions of 'consortiaAdmin'
    * call read(login) consortiaAdmin
    Given path 'perms/users'
    And param query = 'userId=' + id
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def newPermissions = $.permissionUsers[0].permissions

    # get permissions of shadow 'consortiaAdmin'
    * call read(login) consortiaAdmin
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

  Scenario: Create a user called 'centralUser1' in 'centralTenant' and verify there are following records:
    # create user called 'centralUser1' in 'centralTenant'
    * call read(login) consortiaAdmin
    * call read('features/util/initData.feature@PostUser') centralUser1

    # 1. 'centralUser1' has been saved in 'users' table in 'central_mod_users'

    # 2. 'centralUser1' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(centralUser1.username)', userId: '#(centralUser1.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == centralTenant

    # 3. primary affiliation for 'centralUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(centralUser1.username)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == centralUser1.id
    And match response.userTenants[0].isPrimary == true

  # We have 'centralUser1' in 'centralTenant'
  Scenario: POST, DELETE, re-POST non-primary affiliation for 'centralUser1' verify there are following records:
    # POST non-primary affiliation for 'centralUser1' (for 'universityTenant')
    * call read(login) consortiaAdmin
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
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
    * call read(login) consortiaAdmin
    Given path 'users'
    And param query = 'username=' + shadowCentralUser1Username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].id == centralUser1.id
    And match response.users[0].active == true

    # 2. shadow 'centralUser1' has empty permissions (in 'universityTenant')
    * call read(login) consortiaAdmin
    Given path 'perms/users'
    And param query = 'userId=' + shadowCentralUser1Id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

    # DELETE non-primary affiliation for 'centralUser1' (for 'universityTenant')
    * call read(login) consortiaAdmin
    * def queryParams = { userId: '#(shadowCentralUser1Id)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method DELETE
    Then status 204

    # 3. shadow 'centralUser1' has been deactivated (in 'users' table in 'university_mod_users')
    * call read(login) consortiaAdmin
    Given path 'users'
    And param query = 'username=' + shadowCentralUser1Username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].id == centralUser1.id
    And match response.users[0].active == false

    # re-POST non-primary affiliation for 'centralUser1' (for 'universityTenant')
    * call read(login) consortiaAdmin
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(centralUser1.id)', tenantId :'#(universityTenant)'}
    When method POST
    Then status 200
    And match response.userId == centralUser1.id
    And match response.username contains centralUser1.username
    And match response.tenantId == universityTenant
    And match response.isPrimary == false

    # 4. shadow 'centralUser1' has been reactivated (in 'users' table in 'university_mod_users')
    * call read(login) consortiaAdmin
    Given path 'users'
    And param query = 'username=' + shadowCentralUser1Username
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.users[0].id == centralUser1.id
    And match response.users[0].active == true

  # We have shadow 'centralUser1' in 'universityTenant' with 'active'=true, and empty permission
  Scenario: Verify DELETE, re-POST of non-primary affiliation does not affect permissions of the user:
    * def shadowCentralUser1Id = centralUser1.id

    # get shadow 'centralUser1's' username
    * call read(login) consortiaAdmin
    * def queryParams = { userId: '#(shadowCentralUser1Id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(userTenant) {return  userTenant.tenantId == universityTenant }
    * def userTenants = karate.filter(response.userTenants, fun)

    And assert karate.sizeOf(userTenants) == 1
    And match userTenants[0].username contains centralUser1.username
    And match userTenants[0].isPrimary == false

    * def shadowCentralUser1Username = userTenants[0].username

    # 1. add non-empty permission to shadow 'centralUser1'
    * call read(login) consortiaAdmin
    * call read('features/util/initData.feature@PutPermissions') { id: '#(shadowCentralUser1Id)', tenant: '#(universityTenant)', desiredPermissions: ['consortia.all']}

    # 2. get updated permissions of shadow 'centralUser1'
    * call read(login) consortiaAdmin
    Given path 'perms/users'
    And param query = 'userId=' + shadowCentralUser1Id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions != []
    * def updatedNonEmptyPermissionsOfShadowCentralUser1 = response.permissionUsers[0].permissions

    # DELETE non-primary affiliation for 'centralUser1' (for 'universityTenant')
    * call read(login) consortiaAdmin
    * def queryParams = { userId: '#(shadowCentralUser1Id)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method DELETE
    Then status 204

    # re-POST non-primary affiliation for 'centralUser1' (for 'universityTenant')
    * call read(login) consortiaAdmin
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(centralUser1.id)', tenantId :'#(universityTenant)'}
    When method POST
    Then status 200
    And match response.userId == centralUser1.id
    And match response.username contains centralUser1.username
    And match response.tenantId == universityTenant
    And match response.isPrimary == false

    # 3. verify that permissions of shadow 'centralUser1' after re-POST is not changes
    * call read(login) consortiaAdmin
    Given path 'perms/users'
    And param query = 'userId=' + shadowCentralUser1Id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == updatedNonEmptyPermissionsOfShadowCentralUser1