Feature: Setup 'consortiaAdmin' for all tenants

  Background:
    * url baseUrl
    * configure retry = { count: 10, interval: 1000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * def consortiaAdminId = consortiaAdmin.id
    * def consortiaAdminUsername = consortiaAdmin.username

  Scenario: Verify there are following records for 'consortiaAdmin':
    # For 'centralTenant':
    # 1. 'consortiaAdmin' has been saved in 'users' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    Given path 'users', consortiaAdminId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaAdminId
    And match response.username == consortiaAdminUsername
    And match response.active == true

    # 2. 'consortiaAdmin' has been saved in 'user_tenant' table in 'central_mod_users'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(consortiaAdminUsername)', userId: '#(consortiaAdminId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == centralTenant

    # 3. primary affiliation for 'consortiaAdmin' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(consortiaAdminUsername)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == consortiaAdminId
    And match response.userTenants[0].isPrimary == true

    # For 'universityTenant':
    # 4. shadow 'consortiaAdmin' has been saved in 'users' table in 'university_mod_users'
    * call read(login) universityUser1
    Given path 'users', consortiaAdminId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaAdminId
    And match response.username contains consortiaAdminUsername
    And match response.active == true

    * def shadowConsortiaAdminInUniversityUsername = response.username

    # 5. non-primary affiliation for shadow 'consortiaAdmin' of 'universityTenant' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(shadowConsortiaAdminInUniversityUsername)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == consortiaAdminId
    And match response.userTenants[0].isPrimary == false

    # 6. verify shadow 'consortiaAdmin' of 'universityTenant' has required permissions
    * call read(login) universityUser1
    Given path 'perms/users'
    And param query = 'userId=' + consortiaAdminId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == ['ui-users.editperms']

    # For 'collegeTenant':
    # 7. shadow 'consortiaAdmin' has been saved in 'users' table in 'college_mod_users'
    * call read(login) collegeUser1
    Given path 'users', consortiaAdminId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaAdminId
    And match response.username contains consortiaAdminUsername
    And match response.active == true

    * def shadowConsortiaAdminInCollegeUsername = response.username

    # 8. non-primary affiliation for shadow 'consortiaAdmin' of 'collegeTenant' has been created in 'user_tenant' table in 'central_mod_consortia'
    * call read(login) consortiaAdmin
    * def queryParams = { username: '#(shadowConsortiaAdminInCollegeUsername)', tenantId: '#(collegeTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == consortiaAdminId
    And match response.userTenants[0].isPrimary == false

    # 9. verify shadow 'consortiaAdmin' of 'collegeTenant' has required permissions
    * call read(login) collegeUser1
    Given path 'perms/users'
    And param query = 'userId=' + consortiaAdminId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].permissions == ['ui-users.editperms']

  Scenario: Add permissions of real 'consortiaAdmin' to all shadow 'consortiaAdmin':
    * call read(login) consortiaAdmin

    # get permissions of 'consortiaAdmin'
    Given path 'perms/users'
    And param query = 'userId=' + consortiaAdminId
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def newPermissions = $.permissionUsers[0].permissions

    # For 'universityTenant':
    # get permissions of shadow 'consortiaAdmin' of 'universityTenant'
    Given path 'perms/users'
    And param query = 'userId=' + consortiaAdminId
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    # add required permissions to shadow 'consortiaAdmin' of 'universityTenant'
    * def permissionEntry = $.permissionUsers[0]
    * def updatedPermissions = karate.append(newPermissions, permissionEntry.permissions)
    And set permissionEntry.permissions = updatedPermissions

    # update permissions of shadow 'consortiaAdmin' of 'universityTenant'
    Given path 'perms/users', permissionEntry.id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request permissionEntry
    When method PUT
    Then status 200

    # For 'collegeTenant':
    # get permissions of shadow 'consortiaAdmin' of 'collegeTenant'
    Given path 'perms/users'
    And param query = 'userId=' + consortiaAdminId
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    # add required permissions to shadow 'consortiaAdmin' of 'collegeTenant'
    * def permissionEntry = $.permissionUsers[0]
    * def updatedPermissions = karate.append(newPermissions, permissionEntry.permissions)
    And set permissionEntry.permissions = updatedPermissions

    # update permissions of shadow 'consortiaAdmin' of 'collegeTenant'
    Given path 'perms/users', permissionEntry.id
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request permissionEntry
    When method PUT
    Then status 200