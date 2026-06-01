Feature: seed consortia data before Keycloak upgrade

  Background:
    * url baseUrl
    * configure cookies = null
    * configure retry = { count: 20, interval: 5000 }

  Scenario: create central and member tenant with non-primary affiliation before upgrade
    # Create the central tenant and enable applications required by the upgrade smoke and consortia flows.
    * def setupTenant = read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@SetupTenant')
    * call setupTenant { tenantId: '#(centralTenantId)', tenant: '#(centralTenant)', user: '#(consortiaAdmin)' }

    # Create a member tenant in the same consortium test fixture.
    * call setupTenant { tenantId: '#(memberTenantId)', tenant: '#(memberTenant)', user: '#(memberAdmin)' }

    # Log in as the central consortia admin to create consortium records.
    * call read('classpath:common-consortia/eureka/initData.feature@Login') consortiaAdmin

    # Create the consortium record before the upgrade.
    * call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@SetupConsortia') { tenant: '#(centralTenant)' }

    # Register the central and member tenants in the consortium before the upgrade.
    * call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@SetupTenantForConsortia') { tenant: '#(centralTenant)', code: 'cntrl', isCentral: true }
    * call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@SetupTenantForConsortia') { tenant: '#(memberTenant)', code: 'mbr', isCentral: false }

    # Create a central user whose affiliation and shadow user will be verified after the upgrade.
    * call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@PostUser') { tenant: '#(centralTenant)', user: '#(consortiaUser)' }

    # Verify the central user's primary affiliation was created before the upgrade.
    * def primaryAffiliationQuery = { userId: '#(consortiaUser.id)', tenantId: '#(centralTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = primaryAffiliationQuery
    And headers { 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-token': '#(okapitoken)' }
    And retry until response.totalRecords == 1
    When method get
    Then status 200
    And match response.userTenants[0].userId == consortiaUser.id
    And match response.userTenants[0].tenantId == centralTenant
    And match response.userTenants[0].isPrimary == true

    # Create the member non-primary affiliation before the upgrade.
    * call read('classpath:common-consortia/eureka/affiliation.feature@AddAffiliation') { tenant: '#(memberTenant)', user: '#(consortiaUser)' }

    # Verify the member shadow user exists before the upgrade.
    * call read('classpath:common-consortia/eureka/initData.feature@Login') memberAdmin
    Given path 'users', consortiaUser.id
    And headers { 'x-okapi-tenant': '#(memberTenant)', 'x-okapi-token': '#(okapitoken)' }
    And retry until response.active == true
    When method get
    Then status 200
    And match response.id == consortiaUser.id
    And match response.username contains consortiaUser.username
    And match response.type == 'shadow'
    And match response.customFields.originaltenantid == centralTenant
