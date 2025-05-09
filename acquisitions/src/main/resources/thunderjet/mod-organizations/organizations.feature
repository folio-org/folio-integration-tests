Feature: mod-organizations integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-permissions'           |
      | 'mod-audit'                 |
      | 'mod-orders-storage'        |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |

    * table userPermissions
      | name                                      |
      | 'organizations.module.all'                |
      | 'organizations-storage.organizations.all' |
      | 'orders-storage.module.all'               |
      | 'acquisition.organization.events.get'     |

    # Test tenant name creation:
    * def random = callonce randomMillis
    * def testTenant = 'testmodorgs' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

  Scenario: Create tenant and users for testing
    * call read('classpath:common/setup-users.feature')

  # Custom scenario(s):
  Scenario: Acquisitions API tests
    Given call read('features/acquisitions-api-tests.feature')

  Scenario: Audit events for Organization
    Given call read('features/audit-event-organization.feature')

  Scenario: Wipe data
    Given call read('classpath:common/destroy-data.feature')
