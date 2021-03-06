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
      | name                                      |
      | 'search.instances.facets.collection.get'  |
      | 'search.instances.ids.collection.get'     |
      | 'search.instances.collection.get'         |
      | 'inventory-storage.items.batch.post'      |
      | 'inventory-storage.holdings.batch.post'   |
      | 'inventory-storage.instances.batch.post'  |
      | 'inventory-storage.instances.item.delete' |
      | 'inventory-storage.holdings.item.delete'  |
      | 'inventory-storage.items.item.delete'     |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: Upload test data
    Given call read('classpath:set-up/create-test-data.feature')

