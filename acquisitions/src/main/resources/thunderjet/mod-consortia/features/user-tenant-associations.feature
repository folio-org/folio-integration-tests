Feature: Consortia User Tenant associations api tests

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  # At this point each tenant has following users:
  # 'consortiaAdmin' in 'centralTenant';
  # 'consortia-system-user' in 'centralTenant' (automatically created when 'mod-consortia' was enabled);
  # 'universityUser1' in 'universityTenant';
  # 'consortia-system-user' in 'universityTenant' (automatically created when 'mod-consortia' was enabled);

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

  # We need to add permissions of 'consortiaAdmin' to shadow 'consortiaAdmin'
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
    * call pause 60000
