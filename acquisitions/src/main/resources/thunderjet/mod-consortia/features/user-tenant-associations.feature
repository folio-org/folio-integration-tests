Feature: Consortia User Tenant associations api tests

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  # We had only 'centralAdmin' when POSTing 'centralTenant' to the consortium.
  Scenario: User 'centralAdmin' has been saved in 'users' and 'user_tenant' tables in 'central_mod_users', primary affiliation has been created for this user in 'user_tenant' table in 'central_mod_consortia'
    # 1. 'centralAdmin' has been saved in 'users' table in 'central_mod_users' - No need to check
    # 2. 'centralAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'centralAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'

    * call read(login) centralAdmin

    # 2. 'centralAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    * def queryParams = { username: '#(centralAdmin.username)', userId: '#(centralAdmin.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 3. primary affiliation for 'centralAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { username: '#(centralAdmin.username)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == centralAdmin.id
    And match response.userTenants[0].isPrimary == true

  # When POSTing 'centralTenant' to the consortium, 'consortia-system-user'(for 'centralTenant') should be created automatically
  Scenario: User 'consortia-system-user' has been saved in 'users' and 'user_tenant' tables in 'central_mod_users', primary affiliation has been created for this user in 'user_tenant' table in 'central_mod_consortia'
    # 1. 'consortia-system-user' has been saved in 'users' table in 'central_mod_users'
    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'

    * call read(login) centralAdmin

    # 1. 'consortia-system-user' has been saved in 'users' table in 'central_mod_users'
    Given path 'users'
    And param query = 'username=' + consortiaSystemUserName
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def consortiaSystemUserInCentralId = response.users[0].id

    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    * def queryParams = { username: '#(consortiaSystemUserName)', userId: '#(consortiaSystemUserInCentralId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { username: '#(consortiaSystemUserName)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == consortiaSystemUserInCentralId
    And match response.userTenants[0].isPrimary == true

  # We had only 'universityAdmin' when POSTing 'universityTenant' to the consortium.
  Scenario: User 'universityAdmin' has been saved in 'users' table in 'university_mod_users', in 'user_tenant' table in 'central_mod_users', primary affiliation has been created for this user in 'user_tenant' table in 'central_mod_consortia'
    # 1. 'universityAdmin' has been saved in 'users' table in 'university_mod_users' - No need to check
    # 2. 'universityAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'universityAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 4. non-primary affiliation for 'universityAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 5. shadow user for 'universityAdmin' has empty permissions (in 'centralTenant')

    * call read(login) centralAdmin

    # 2. 'universityAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    * def queryParams = { username: '#(universityAdmin.username)', userId: '#(universityAdmin.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 3. primary affiliation for 'universityAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { username: '#(universityAdmin.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == universityAdmin.id
    And match response.userTenants[0].isPrimary == true

    # 4. non-primary affiliation for 'universityAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * def queryParams = { userId: '#(universityAdmin.id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(userTenant) {return  userTenant.tenantId == centralTenant }
    * def userTenants = karate.filter(response.userTenants, fun)

    And assert karate.sizeOf(userTenants) == 1
    And match userTenants[0].username contains universityAdmin.username
    And match userTenants[0].isPrimary == false

    # 5. shadow user for 'universityAdmin' has empty permissions (in 'centralTenant')
    * call read(login) centralAdmin
    Given path 'perms/users'
    And param query = 'userId=' + universityAdmin.id
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

  # When POSTing 'universityTenant' to the consortium, 'consortia-system-user'(for 'universityTenant') should be created automatically
  Scenario: User 'consortia-system-user' has been saved in 'users' table in 'university_mod_users', in 'user_tenant' table in 'central_mod_users', primary affiliation has been created for this user in 'user_tenant' table in 'central_mod_consortia'
    # 1. 'consortia-system-user' has been saved in 'users' table in 'university_mod_users'
    # 2. 'consortia-system-user' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 4. non-primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 5. shadow user for 'consortia-system-user'(in 'universityTenant') has empty permissions (in 'centralTenant')

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

    # 4. non-primary affiliation for 'consortia-system-user' has been created in 'user_tenant' table in 'central_mod_consortia'
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

    # 5. shadow user for 'consortia-system-user'(in 'universityTenant') has empty permissions (in 'centralTenant')
    * call read(login) centralAdmin
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserInUniversityId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == []

  # When POSTing 'universityTenant' to the consortium, shadow (admin) user for 'centralAdmin' should be created automatically in 'universityTenant'
  Scenario: Shadow user 'centralAdmin' has been saved in 'users' table in 'university_mod_users', in 'user_tenant' table in 'central_mod_users', primary affiliation has been created for this user in 'user_tenant' table in 'central_mod_consortia'
    # 1. shadow (admin) user for 'centralAdmin' has been saved in 'users' table in 'university_mod_users'
    # 2. non-primary affiliation for 'centralAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 3. verify shadow (admin) user for 'centralAdmin' has some permissions

    * def shadowAdminUserId = centralAdmin.id

    # 1. shadow (admin) user for 'centralAdmin' has been saved in 'users' table in 'university_mod_users'
    * call read(login) universityAdmin
    Given path 'users'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def fun = function(user) {return  user.id == shadowAdminUserId }
    * def users = karate.filter(response.users, fun)

    And assert karate.sizeOf(users) == 1
    And match users[0].username contains centralAdmin.username
    * def shadowAdminUserName = users[0].username

    # 2. non-primary affiliation for 'centralAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(shadowAdminUserName)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == shadowAdminUserId
    And match response.userTenants[0].isPrimary == false

    # 3. verify shadow (admin) user for 'centralAdmin' has required permissions
    * call read(login) universityAdmin
    Given path 'perms/users'
    And param query = 'userId=' + shadowAdminUserId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == ['ui-users.editperms']

  # When POSTing 'universityTenant' to the consortium, 'dummy_user' should be created automatically in 'universityTenant'
  Scenario: Verify 'dummy_user' has been saved in 'user_tenant' table in 'university_mod_users'
    * call read(login) universityAdmin
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1

  Scenario: Create user for 'universityTenant' and verify that the user can login to 'universityTenant' and login through 'centralTenant'
    # Create a user in 'universityTenant' with credentials and verify following:
    # 1. 'universityUser1' can login to 'universityTenant' - No need to check
    # 2. 'universityUser1' has been saved in 'user_tenant' table in 'central_mod_users'
    # 3. primary affiliation for 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
    # 4. 'universityUser1' can login through 'centralTenant'

    # Create a user in 'universityTenant' with credentials
    * call read(login) universityAdmin
    * call read('features/util/initData.feature@PostUser') universityUser1

    * configure retry = { count: 10, interval: 3000 }

    # 2. 'universityUser1' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(universityUser1.username)', userId: '#(universityUser1.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 3. primary affiliation for 'universityUser1' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) centralAdmin
    * def queryParams = { username: '#(universityUser1.username)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until responseStatus == 200
    When method GET
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == universityUser1.id
    And match response.userTenants[0].isPrimary == true

    # 4. 'universityUser1' can login through 'centralTenant'
    Given path 'authn/login'
    And header x-okapi-tenant = centralTenant
    And request { username: '#(universityUser1.username)', password: '#(universityUser1.password)' }
    When method POST
    Then status 201