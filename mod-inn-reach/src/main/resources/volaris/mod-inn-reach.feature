Feature: mod-inn-reach integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-inn-reach'     |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |
      | 'mod-users'         |

    * def random = callonce randomMillis
    * print "def testTenant must starts with test_inn_reach_integration"
    * def testTenant = 'test_inn_reach_integration' + random
    #* def testTenant = 'test_inn_reach_integration1'
    # -Dkarate.env=testing
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name                                                                 |
      | 'inn-reach.central-servers.collection.get'                           |
      | 'inventory.instances.item.post'                                      |
      | 'inventory.instances.item.get'                                       |
      | 'inventory-storage.instance-types.item.post'                         |
      | 'inn-reach.d2ir.bib-info.item.get'                                   |


    * table userPermissions
      | name                                                                 |
      | 'inn-reach.central-servers.collection.get'                           |
      | 'inventory.instances.item.post'                                      |
      | 'inventory.instances.item.get'                                       |
      | 'inventory-storage.instance-types.item.post'                         |
      | 'inn-reach.d2ir.bib-info.item.get'                                   |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')


  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
