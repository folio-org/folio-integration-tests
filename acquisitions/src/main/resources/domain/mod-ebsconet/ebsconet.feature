Feature: mod-ebsconet integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-configuration' |
      | 'mod-ebsconet'      |
      | 'mod-login'         |
      | 'mod-orders'        |
      | 'mod-organizations' |
      | 'mod-permissions'   |

    * def random = callonce randomMillis
    * def testTenant = 'test_ebsconet' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name           |
      | 'ebsconet.all' |

    # create tenant and users for testing
    * call read('classpath:common/setup-users.feature')

    # init global data
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: Get Ebsconet Order Line
    Given call read('features/get-ebsconet-order-line.feature')
