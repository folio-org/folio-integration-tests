  # MODCONSKC-135: setupStatus of a member tenant must become COMPLETED after the tenant is added to a consortium,
  # also when the member tenant has no users, so the primary affiliation sync has nothing to sync
Feature: Member tenant 'setupStatus' after adding the tenant to a consortium

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 15000 }

  @Positive
  Scenario: MODCONSKC-135 setupStatus of a member tenant without users becomes COMPLETED
    # the member tenant has no users, so the primary affiliation sync has nothing to sync and sets
    # COMPLETED status right away - before the fix this update was lost and the tenant stayed IN_PROGRESS forever

    # 1. create consortium
    Given path 'consortia'
    And request { id: '#(consortiumId)', name: 'Setup status consortium' }
    When method POST
    Then status 201

    # 2. post 'centralTenant' (isCentral = true)
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '#(centralTenant)', code: 'CEN', name: 'Central tenant', isCentral: true }
    And retry until responseStatus == 201
    When method POST
    Then status 201

    # 3. verify that setupStatus of 'centralTenant' is COMPLETED
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200

    # 4. post 'memberTenant' (isCentral = false) without users
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(memberTenant)', code: 'MEM', name: 'Member tenant', isCentral: false }
    And retry until responseStatus == 201
    When method POST
    Then status 201
    And match response == { id: '#(memberTenant)', code: 'MEM', name: 'Member tenant', isCentral: false, isDeleted: false }

    # 5. verify that setupStatus of 'memberTenant' is COMPLETED
    Given path 'consortia', consortiumId, 'tenants', memberTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == memberTenant
    And match response.isCentral == false

    # 6. verify that consortia admin is affiliated with 'memberTenant' (shadow admin user was created)
    Given path 'consortia', consortiumId, 'user-tenants'
    And param userId = consortiaAdmin.id
    When method GET
    Then status 200
    And match response.userTenants[*].tenantId contains memberTenant
