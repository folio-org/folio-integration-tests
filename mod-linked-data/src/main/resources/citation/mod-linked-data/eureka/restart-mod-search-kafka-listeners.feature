Feature: mod-linked-data integration tests

  Background:
    * url baseUrl
    * table modules
      | name            |
      | 'mod-authtoken' |
      | 'mod-search'    |

  Scenario: Restart mod-search kafka listeners
    // Create a dummy tenant & enable mod-search for that tenant. Also, delete that tenant immediately.
    // This will restart kafka listeners for all tenants in mod-search
    * def dummyTenant = 'dummytenant' +  random_string().toLowerCase()
    * def dummyTenantId = uuid()
    * call read('classpath:common/eureka/tenant.feature@create') ({ tenantName: dummyTenant, tenantId: dummyTenantId })
    * call read('classpath:common/eureka/setup-users.feature@createentitlement') ({ tenantName: dummyTenant, testTenantId: dummyTenantId })
    * call read('classpath:common/eureka/tenant.feature@delete') ({ tenantId: dummyTenantId })
