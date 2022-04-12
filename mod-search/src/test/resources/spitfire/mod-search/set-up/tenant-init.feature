Feature: Tenant initialization for tests

  Background:
    * url baseUrl
    * table modules
      | name                    |
      | 'mod-login'             |
      | 'mod-permissions'       |
      | 'mod-users'             |
      | 'mod-inventory-storage' |
      | 'mod-search'            |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                           |
      | 'search.config.features.item.post'             |
      | 'search.facets.collection.get'                 |
      | 'search.instances.ids.collection.get'          |
      | 'search.instances.collection.get'              |
      | 'search.authorities.collection.get'            |
      | 'inventory-storage.items.batch.post'           |
      | 'inventory-storage.holdings.batch.post'        |
      | 'inventory-storage.instances.batch.post'       |
      | 'inventory-storage.authorities.item.post'      |
      | 'inventory-storage.instances.item.delete'      |
      | 'inventory-storage.holdings.item.delete'       |
      | 'inventory-storage.instance.reindex.item.get'  |
      | 'browse.authorities.collection.get'            |
      | 'browse.subjects.instances.collection.get'     |
      | 'browse.call-numbers.instances.collection.get' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: Upload test data
    Given call read('create-test-data.feature')
