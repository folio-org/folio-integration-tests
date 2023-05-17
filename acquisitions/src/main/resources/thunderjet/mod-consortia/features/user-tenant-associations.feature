Feature: Consortia User Tenant associations api tests

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  Scenario: Create a user for 'university' tenant and check whether this user has been created in 'user-tenants'
    # create a user in 'central' tenant
    * call read(login) centralAdmin
    * call read('features/util/initData.feature@SetUpUserWithAuth') centralUser2
    * call pause 60

    # verify there is a record for newly created user in 'user-tenants'
    * def userTenants = call read('features/util/initData.feature@GetUserTenantsRecordFilteredByUserIdAndTenantId') { userId: '#(centralUser2.id)', tenantId: '#(centralAdmin.tenant)'}

    And assert karate.sizeOf(userTenants.response) == 1
    And match userTenants.response[0].isPrimary == true
