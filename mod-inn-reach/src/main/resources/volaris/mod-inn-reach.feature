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
    # -Dkarate.env=snapshot karate.env=snapshot
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name                                                                 |
      | 'inn-reach.central-servers.collection.get'                           |
      | 'inventory.instances.item.post'                                      |
      | 'inventory.instances.item.get'                                       |
      | 'inventory-storage.instance-types.item.post'                         |
      | 'inn-reach.d2ir.bib-info.item.get'                                   |
      | 'inn-reach.locations.item.post'                                      |
      | 'inn-reach.locations.collection.get'                                 |
      | 'inn-reach.locations.item.get'                                       |
      | 'inn-reach.locations.item.put'                                       |
      | 'inn-reach.locations.item.delete'                                    |


    * table userPermissions
      | name                                                                 |
      | 'inn-reach.central-servers.collection.get'                           |
      | 'inventory.instances.item.post'                                      |
      | 'inventory.instances.item.get'                                       |
      | 'inventory-storage.instance-types.item.post'                         |
      | 'inn-reach.d2ir.bib-info.item.get'                                   |
      | 'inn-reach.locations.item.post'                                      |
      | 'inn-reach.locations.collection.get'                                 |
      | 'inn-reach.locations.item.get'                                       |
      | 'inn-reach.locations.item.put'                                       |
      | 'inn-reach.locations.item.delete'                                    |
      | 'users.item.get'                                                     |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')

  Scenario: create inn reach location
    Given call read('features/inn-reach-location.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
