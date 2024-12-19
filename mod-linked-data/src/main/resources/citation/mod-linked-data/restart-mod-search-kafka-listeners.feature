Feature: mod-linked-data integration tests

  Background:
    * url baseUrl
    * table searchModule
      | name                                      |
      | 'mod-search'                              |

  Scenario: Restart mod-search kafka listeners
    // Create a dummy tenant & enable mod-search for that tenant. Also, delete that tenant immediately.
    // This will restart kafka listeners in mod-search
    * def dummyTenant = 'dummytenant' +  random_string().toLowerCase()
    * call read('classpath:common/tenant.feature') ({ modules: searchModule, tenant: dummyTenant })
