Feature: Consortia User Update tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Authtoken-Refresh-Cache': 'true', 'Accept': '*/*' }
    * configure retry = { count: 10, interval: 5000 }

  Scenario: Create a user called 'userToUpdate' in 'centralTenant', add affiliation in both tenants and verify that firstName and lastName applied to all shadow users:
    # create new user called 'userToUpdate' with type = 'staff' in 'centralTenant'
    * call read('features/util/initData.feature@PostUser') userToUpdate

    # check that user processed by consortia pipeline
    * def queryParams = { username: '#(userToUpdate.username)', userId: '#(userToUpdate.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].consortiumId == consortiumId
    And match response.userTenants[0].centralTenantId == centralTenant

    # 1. POST non-primary affiliation for 'userToUpdate' (for 'universityTenant')
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(userToUpdate.id)', tenantId :'#(universityTenant)'}
    When method POST
    Then status 200
    And match response.userId == userToUpdate.id
    And match response.username contains userToUpdate.username
    And match response.tenantId == universityTenant
    And match response.isPrimary == false

    # 2. POST non-primary affiliation for 'userToUpdate' (for 'collegeTenant')
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(userToUpdate.id)', tenantId :'#(collegeTenant)'}
    When method POST
    Then status 200
    And match response.userId == userToUpdate.id
    And match response.username contains userToUpdate.username
    And match response.tenantId == collegeTenant
    And match response.isPrimary == false

    # 3. 'userToUpdate' has been saved in 'users' table in 'university_mod_users' with correct firstName and lastName
    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == userToUpdate.id
    And match response.active == true
    And match response.personal.firstName == 'user first name'
    And match response.personal.lastName == 'user last name'

    # 4. 'userToUpdate' has been saved in 'users' table in 'college_mod_users' with correct firstName and lastName
    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == userToUpdate.id
    And match response.active == true
    And match response.personal.firstName == 'user first name'
    And match response.personal.lastName == 'user last name'

  Scenario: Update 'userToUpdate' firstName and lastName and changes should be propagated to all shadow users:
    # 1.  update user called 'userToUpdate' with new firstName, lastName in 'centralTenant'
    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    * copy userCopy = response
    * set userCopy.personal.firstName = 'firstNameUpdated'
    * set userCopy.personal.lastName = 'lastNameUpdated'

    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request userCopy
    When method PUT
    Then status 204

    # 2. verify that firstName lastName updated for real user in centralTenant
    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.id == userToUpdate.id
    And match response.active == true
    And match response.personal.firstName == 'firstNameUpdated'
    And match response.personal.lastName == 'lastNameUpdated'

    # 3. verify that firstName lastName updated for shadow user in universityTenant
    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.personal.firstName == 'firstNameUpdated'
    When method GET
    Then status 200
    And match response.id == userToUpdate.id
    And match response.active == true
    And match response.personal.firstName == 'firstNameUpdated'
    And match response.personal.lastName == 'lastNameUpdated'

    # 4. verify that firstName lastName updated for real user in collegeTenant
    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.personal.firstName == 'firstNameUpdated'
    When method GET
    Then status 200
    And match response.id == userToUpdate.id
    And match response.active == true
    And match response.personal.firstName == 'firstNameUpdated'
    And match response.personal.lastName == 'lastNameUpdated'

  Scenario: Update 'userToUpdate' barcode, externalSystemId, email, phoneNumber, mobilePhoneNumber for user-tenant endpoint:
    # 1. update user called 'userToUpdate' with new phone, mobilePhone, barcode, externalSystemId, email in 'centralTenant'
    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    * copy userCopy = response
    * set userCopy.personal.phone = '333-333'
    * set userCopy.personal.mobilePhone = '444-444'
    * set userCopy.personal.email = 'new@mail.com'
    * def newBarcode = callonce uuid1
    * def newExternalSystemId = callonce uuid2
    * set userCopy.barcode = newBarcode
    * set userCopy.externalSystemId = newExternalSystemId

    Given path 'users', userCopy.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request userCopy
    When method PUT
    Then status 204

    # 2. verify that all fields updated in mod-users /user-tenant central tenant
    * def queryParams = { username: '#(userCopy.username)', userId: '#(userCopy.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.userTenants[0].barcode == newBarcode
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].centralTenantId == centralTenant
    And match response.userTenants[0].consortiumId == consortiumId
    And match response.userTenants[0].barcode == newBarcode
    And match response.userTenants[0].externalSystemId == newExternalSystemId
    And match response.userTenants[0].email == userCopy.personal.email
    And match response.userTenants[0].phoneNumber == userCopy.personal.phone
    And match response.userTenants[0].mobilePhoneNumber == userCopy.personal.mobilePhone

  Scenario: Update 'userToUpdate' username and changes should be reflected in all places
    # 1. update user called 'userToUpdate' with new username 'centralTenant'
    Given path 'users', userToUpdate.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    * copy userCopy = response
    * set userCopy.username = 'username_new'

    Given path 'users', userCopy.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request userCopy
    When method PUT
    Then status 204

    # 2. verify that all fields updated in mod-users /user-tenant central tenant
    * def queryParams = { username: '#(userCopy.username)', userId: '#(userCopy.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].centralTenantId == centralTenant
    And match response.userTenants[0].consortiumId == consortiumId
    And match response.userTenants[0].username == userCopy.username

    # 3. verify that primary affiliation for 'userCopy' has been updated in 'user_tenant' table in 'central_mod_consortia' with new username
    * def queryParams = { username: '#(userCopy.username)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == userCopy.id
    And match response.userTenants[0].isPrimary == true
    And match response.userTenants[0].username == userCopy.username

  Scenario: Update firstName, lastName for user created in member tenant
    # create new user called 'universityUserToUpdate' with type = 'staff' in 'universityTenant'
    * call read('features/util/initData.feature@PostUser') universityUserToUpdate

    # 1. check that user processed by consortia pipeline
    * def queryParams = { username: '#(universityUserToUpdate.username)', userId: '#(universityUserToUpdate.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == universityTenant
    And match response.userTenants[0].consortiumId == consortiumId
    And match response.userTenants[0].centralTenantId == centralTenant

    # 2. POST non-primary affiliation for 'universityUserToUpdate' (for 'collegeTenant')
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(universityUserToUpdate.id)', tenantId :'#(collegeTenant)'}
    When method POST
    Then status 200
    And match response.userId == universityUserToUpdate.id
    And match response.username contains universityUserToUpdate.username
    And match response.tenantId == collegeTenant
    And match response.isPrimary == false

    # 3. update user called 'userToUpdate' with new firstName, lastName in 'universityTenant'
    Given path 'users', universityUserToUpdate.id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    * copy universityUserCopy = response
    * set universityUserCopy.personal.firstName = 'firstNameUpdated'
    * set universityUserCopy.personal.lastName = 'lastNameUpdated'

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/plain' }
    Given path 'users', universityUserToUpdate.id
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request universityUserCopy
    When method PUT
    Then status 204
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

    # 4. 'universityUserToUpdate' shadow user has been updated in 'users' table in 'central_mod_users' with correct firstName and lastName
    Given path 'users', universityUserToUpdate.id
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.personal.firstName == 'firstNameUpdated'
    When method GET
    Then status 200
    And match response.id == universityUserToUpdate.id
    And match response.active == true
    And match response.personal.firstName == 'firstNameUpdated'
    And match response.personal.lastName == 'lastNameUpdated'

    # 5. 'universityUserToUpdate' shadow user has been updated in 'users' table in 'college_mod_users' with correct firstName and lastName
    Given path 'users', universityUserToUpdate.id
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.personal.firstName == 'firstNameUpdated'
    When method GET
    Then status 200
    And match response.id == universityUserToUpdate.id
    And match response.active == true
    And match response.personal.firstName == 'firstNameUpdated'
    And match response.personal.lastName == 'lastNameUpdated'