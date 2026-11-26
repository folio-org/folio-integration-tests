@parallel=false
Feature: mod-consortia-keycloak member tenant 'setupStatus' integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure connectTimeout = 600000

    * table modules
      | name                  |
      | 'mod-users'           |
      | 'mod-configuration'   |
      | 'mod-settings'        |
      | 'folio-custom-fields' |

    # 'member' tenant is created without 'setupTenant' (no admin user), so it needs the consortia modules explicitly
    * table consortiaModules
      | name                     |
      | 'mod-tags'               |
      | 'mod-users-bl'           |
      | 'mod-password-validator' |
      | 'folio_users'            |
      | 'mod-consortia-keycloak' |
    * def memberModules = karate.append(modules, consortiaModules)

    * def random = callonce randomMillis
    * def uuids = callonce uuids 3
    * def centralTenantId = uuids[0]
    * def memberTenantId = uuids[1]
    * def consortiumId = uuids[2]
    * def centralTenant = 'central' + random
    * def memberTenant = 'member' + random

    * def consortiaAdminId = callonce uuid1
    * def consortiaAdmin = { id: '#(consortiaAdminId)', username: 'consortia_admin', password: '#(generatePassword("consortia_admin"))', tenant: '#(centralTenant)'}

    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def deleteTenantAndEntitlement = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')

  Scenario: Create 'central' tenant with admin and 'member' tenant without any users
    * call setupTenant { tenantId: '#(centralTenantId)', tenant: '#(centralTenant)', user: '#(consortiaAdmin)' }

    * call read('classpath:common-consortia/eureka/initData.feature@PostTenant') { tenantId: '#(memberTenantId)', tenant: '#(memberTenant)', description: 'member tenant without users' }
    * call read('classpath:common-consortia/eureka/initData.feature@InstallApplications') { tenantId: '#(memberTenantId)', modules: '#(memberModules)' }

  Scenario: Member tenant 'setupStatus' becomes COMPLETED
    * call read('features/member-tenant-setup-status.feature')

  Scenario: Destroy created ['central', 'member'] tenants
    * call deleteTenantAndEntitlement { tenantId: '#(memberTenantId)' }
    * call deleteTenantAndEntitlement { tenantId: '#(centralTenantId)' }
