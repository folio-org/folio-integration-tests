Feature: Verify real/shadow 'consortia-system-user' related records in all tenants, and their permissions

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 1000 }
    * def consortiaSystemUserName = 'consortia-system-user'

  Scenario: Verify there are following records for real/shadow 'consortia-system-user' in all tenants:
    # primary affiliations in 'central_mod_consortia.user_tenant':
    # 1. primary affiliation for 'consortia-system-user' of 'centralTenant' has been created in 'central_mod_consortia.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserName)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].username == consortiaSystemUserName
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].isPrimary == true

    * def consortiaSystemUserOfCentralId = response.userTenants[0].userId

    # 2. primary affiliation for 'consortia-system-user' of 'universityTenant' has been created in 'central_mod_consortia.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserName)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].username == consortiaSystemUserName
    And match response.userTenants[0].tenantId == universityTenant
    And match response.userTenants[0].isPrimary == true

    * def consortiaSystemUserOfUniversityId = response.userTenants[0].userId

    # 3. primary affiliation for 'consortia-system-user' of 'collegeTenant' has been created in 'central_mod_consortia.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserName)', tenantId: '#(collegeTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].username == consortiaSystemUserName
    And match response.userTenants[0].tenantId == collegeTenant
    And match response.userTenants[0].isPrimary == true

    * def consortiaSystemUserOfCollegeId = response.userTenants[0].userId

    # real 'consortia-system-user's in 'central_mod_users.user_tenant':
    # 4. 'consortia-system-user' of 'centralTenant' has been saved in 'central_mod_users.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserName)', userId: '#(consortiaSystemUserOfCentralId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].userId == consortiaSystemUserOfCentralId
    And match response.userTenants[0].username == consortiaSystemUserName
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].centralTenantId == centralTenant

    # 5. 'consortia-system-user' of 'universityTenant' has been saved in 'central_mod_users.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserName)', userId: '#(consortiaSystemUserOfUniversityId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].userId == consortiaSystemUserOfUniversityId
    And match response.userTenants[0].username == consortiaSystemUserName
    And match response.userTenants[0].tenantId == universityTenant
    And match response.userTenants[0].centralTenantId == centralTenant

    # 6. 'consortia-system-user' of 'collegeTenant' has been saved in 'central_mod_users.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserName)', userId: '#(consortiaSystemUserOfCollegeId)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].userId == consortiaSystemUserOfCollegeId
    And match response.userTenants[0].username == consortiaSystemUserName
    And match response.userTenants[0].tenantId == collegeTenant
    And match response.userTenants[0].centralTenantId == centralTenant

    # real 'consortia-system-user's in '<tenant>_mod_users.users':
    # 7. 'consortia-system-user' of 'centralTenant' has been saved in 'central_mod_users.users'
    Given path 'users', consortiaSystemUserOfCentralId
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaSystemUserOfCentralId
    And match response.username == consortiaSystemUserName
    And match response.personal.lastName == 'SystemConsortia'

    # 8. 'consortia-system-user' of 'universityTenant' has been saved in 'university_mod_users.users'
    Given path 'users', consortiaSystemUserOfUniversityId
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaSystemUserOfUniversityId
    And match response.username == consortiaSystemUserName
    And match response.personal.lastName == 'SystemConsortia'

    # 9. 'consortia-system-user' of 'collegeTenant' has been saved in 'college_mod_users.users'
    Given path 'users', consortiaSystemUserOfCollegeId
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaSystemUserOfCollegeId
    And match response.username == consortiaSystemUserName
    And match response.personal.lastName == 'SystemConsortia'

    # verify length of permissions of real 'consortia-system-user'
    # 10. 'consortia-system-user' of 'centralTenant' has required permissions in 'centralTenant'
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserOfCentralId
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].userId == consortiaSystemUserOfCentralId
    And match response.permissionUsers[0].permissions == '#[71]'

    # 11. 'consortia-system-user' of 'universityTenant' has required permissions in 'universityTenant'
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserOfUniversityId
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].userId == consortiaSystemUserOfUniversityId
    And match response.permissionUsers[0].permissions == '#[71]'

    # 12. 'consortia-system-user' of 'collegeTenant' has required permissions in 'collegeTenant'
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserOfCollegeId
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].userId == consortiaSystemUserOfCollegeId
    And match response.permissionUsers[0].permissions == '#[71]'

    # verify shadow 'consortia-system-user' of member tenants has empty permissions in 'centralTenant':
    # 13. shadow 'consortia-system-user' of 'universityTenant' has empty permissions in 'centralTenant'
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserOfUniversityId
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].userId == consortiaSystemUserOfUniversityId
    And match response.permissionUsers[0].permissions == []

    # 14. shadow 'consortia-system-user' of 'collegeTenant' has empty permissions in 'centralTenant'
    Given path 'perms/users'
    And param query = 'userId=' + consortiaSystemUserOfCollegeId
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And match response.totalRecords == 1
    And match response.permissionUsers[0].userId == consortiaSystemUserOfCollegeId
    And match response.permissionUsers[0].permissions == []

    # shadow 'consortia-system-user's in '<tenant>_mod_users.users'
    # 15. shadow 'consortia-system-user' of 'universityTenant' has been saved in 'central_mod_users.users'
    Given path 'users', consortiaSystemUserOfUniversityId
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaSystemUserOfUniversityId
    And match response.username contains consortiaSystemUserName
    And match response.type == 'shadow'
    And match response.customFields.originaltenantid == universityTenant

    * def consortiaSystemUserOfUniversityShadowInCentralUserName = response.username

    # 16. shadow 'consortia-system-user' of 'collegeTenant' has been saved in 'central_mod_users.users'
    Given path 'users', consortiaSystemUserOfCollegeId
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaSystemUserOfCollegeId
    And match response.username contains consortiaSystemUserName
    And match response.type == 'shadow'
    And match response.customFields.originaltenantid == collegeTenant

    * def consortiaSystemUserOfCollegeShadowInCentralUserName = response.username

    # 17. shadow 'consortia-system-user' of 'centralTenant' has been saved in 'university_mod_users.users'
    Given path 'users', consortiaSystemUserOfCentralId
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaSystemUserOfCentralId
    And match response.username contains consortiaSystemUserName
    And match response.type == 'shadow'
    And match response.customFields.originaltenantid == centralTenant

    * def consortiaSystemUserOfCentralShadowInUniversityUserName = response.username

    # 18. shadow 'consortia-system-user' of 'centralTenant' has been saved in 'college_mod_users.users'
    Given path 'users', consortiaSystemUserOfCentralId
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == consortiaSystemUserOfCentralId
    And match response.username contains consortiaSystemUserName
    And match response.type == 'shadow'
    And match response.customFields.originaltenantid == centralTenant

    * def consortiaSystemUserOfCentralShadowInCollegeUserName = response.username

    # non-primary affiliations in 'central_mod_consortia.user_tenant':
    # 19. non-primary affiliation for 'consortia-system-user' of 'universityTenant' - shadow in 'centralTenant' - has been created in 'central_mod_consortia.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserOfUniversityShadowInCentralUserName)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].userId == consortiaSystemUserOfUniversityId
    And match response.userTenants[0].username == consortiaSystemUserOfUniversityShadowInCentralUserName
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].isPrimary == false

    # 20. non-primary affiliation for 'consortia-system-user' of 'collegeTenant' - shadow in 'centralTenant' - has been created in 'central_mod_consortia.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserOfCollegeShadowInCentralUserName)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].userId == consortiaSystemUserOfCollegeId
    And match response.userTenants[0].username == consortiaSystemUserOfCollegeShadowInCentralUserName
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].isPrimary == false

    # 21. non-primary affiliation for 'consortia-system-user' of 'centralTenant' - shadow in 'universityTenant' - has been created in 'central_mod_consortia.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserOfCentralShadowInUniversityUserName)', tenantId: '#(universityTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].userId == consortiaSystemUserOfCentralId
    And match response.userTenants[0].username == consortiaSystemUserOfCentralShadowInUniversityUserName
    And match response.userTenants[0].tenantId == universityTenant
    And match response.userTenants[0].isPrimary == false

    # 22. non-primary affiliation for 'consortia-system-user' of 'centralTenant' - shadow in 'collegeTenant' - has been created in 'central_mod_consortia.user_tenant'
    * def queryParams = { username: '#(consortiaSystemUserOfCentralShadowInCollegeUserName)', tenantId: '#(collegeTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].userId == consortiaSystemUserOfCentralId
    And match response.userTenants[0].username == consortiaSystemUserOfCentralShadowInCollegeUserName
    And match response.userTenants[0].tenantId == collegeTenant
    And match response.userTenants[0].isPrimary == false