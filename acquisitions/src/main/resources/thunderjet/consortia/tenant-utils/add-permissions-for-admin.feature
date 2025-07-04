Feature: add permissions to consortia-admin user in all tenants

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * configure retry = { count: 10, interval: 2000 }
    * def consortiaAdminId = consortiaAdmin.id
    * def consortiaAdminUsername = consortiaAdmin.username

  Scenario: Add permissions of real 'consortiaAdmin' to all shadow 'consortiaAdmin':

    # get permissions of 'consortiaAdmin'
    Given path '/users/capabilities'
    And param query = 'userId=' + consortiaAdminId
    And headers {'x-okapi-tenant':'#(centralTenantName)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    * def newCaps = $.capabilities

    # For 'universityTenant':
    # get permissions of shadow 'consortiaAdmin' of 'universityTenant'
    Given path '/users/capabilities'
    And param query = 'userId=' + consortiaAdminId
    And headers {'x-okapi-tenant':'#(universityTenantName)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    # add required permissions to shadow 'consortiaAdmin' of 'universityTenant'
    * def permissionEntry = $.permissionUsers[0]
    * def updatedPermissions = karate.append(newPermissions, permissionEntry.permissions)
    And set permissionEntry.permissions = updatedPermissions

    # update permissions of shadow 'consortiaAdmin' of 'universityTenant'
    Given path 'perms/users', permissionEntry.id
    And headers {'x-okapi-tenant':'#(universityTenantName)', 'x-okapi-token':'#(okapitoken)'}
    And request permissionEntry
    When method PUT
    Then status 200
