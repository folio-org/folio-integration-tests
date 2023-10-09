Feature: mod-dcb integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |
      | 'mod-dcb'                   |

    * table userPermissions
      | name                                                       |
      |'inventory-storage.inventory-view.instances.collection.get' |
      |'inventory-storage.instances.collection.get'                |
      |'inventory-storage.instances.item.get'                      |
      |'inventory-storage.items.collection.get'                    |
      |'inventory-storage.items.item.get'                          |
      |'inventory-storage.holdings.item.get'                       |
      |'inventory-storage.locations.collection.get'                |
      |'inventory-storage.material-types.collection.get'           |
      |'inventory.items.item.get'                                  |
      |'inventory.instances.item.get'                              |
      |'users.collection.get'                                      |
      |'users.item.get'                                           |
      |'source-storage.records.get'                                |
      |'circulation.requests.item.get'                             |
      |'circulation.requests.item.post'                            |
      |'circulation.requests.collection.get'                       |
      |'circulation.loans.collection.get'                          |
      |'circulation.check-in-by-barcode.post'                      |
      |'circulation.check-out-by-barcode.post'                     |
      |'inventory.items.item.put'                                  |
      |'inventory-storage.holdings.item.put'                       |



  Scenario: create tenant and users for testing for mod-dcb
    Given call read('classpath:common/setup-users.feature')
