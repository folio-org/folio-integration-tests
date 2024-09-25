Feature: mod-dcb integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-source-record-storage' |
      | 'mod-calendar'              |
      | 'mod-feesfines'             |
      | 'mod-circulation-item'      |
      | 'mod-dcb'                   |


    * table userPermissions
      | name                                                       |
      | 'users.collection.get'                                     |
      | 'usergroups.collection.get'                                |
      | 'usergroups.item.post'                                     |
      | 'users.item.post'                                          |
      | 'inventory-storage.service-points.item.post'               |
      | 'inventory-storage.items.item.get'                         |
      | 'inventory.items.item.post'                                |
      | 'inventory.instances.item.post'                            |
      | 'inventory-storage.instance-types.item.post'               |
      | 'inventory-storage.contributor-name-types.item.post'       |
      | 'inventory-storage.holdings.item.post'                     |
      | 'inventory-storage.location-units.institutions.item.post'  |
      | 'inventory-storage.location-units.campuses.item.post'      |
      | 'inventory-storage.location-units.libraries.item.post'     |
      | 'inventory-storage.locations.item.post'                    |
      | 'inventory-storage.material-types.item.post'               |
      | 'inventory-storage.loan-types.item.post'                   |
      | 'inventory-storage.service-points.item.put'                |
      | 'dcb.transactions.post'                                    |
      | 'dcb.transactions.get'                                     |
      | 'dcb.transactions.put'                                     |
      | 'dcb.transactions.collection.get'                          |
      | 'circulation.check-out-by-barcode.post'                    |
      | 'circulation.check-in-by-barcode.post'                     |
      | 'manualblocks.collection.get'                              |
      | 'automated-patron-blocks.collection.get'                   |
      | 'perms.users.item.post'                                    |
      | 'login.item.post'                                          |
      | 'perms.permissions.get'                                    |
      | 'circulation.rules.get'                                    |
      | 'circulation-storage.circulation-rules.put'                |
      | 'circulation.rules.put'                                    |
      | 'circulation-storage.loan-policies.item.post'              |
      | 'lost-item-fees-policies.item.post'                        |
      | 'overdue-fines-policies.item.post'                         |
      | 'circulation-storage.patron-notice-policies.item.post'     |
      | 'circulation-storage.request-policies.item.post'           |


  Scenario: create tenant and users for testing for mod-dcb
    Given call read('classpath:common/setup-users.feature')
  Scenario: call pre requisites feature file
    * callonce read('classpath:volaris/mod-dcb/reusable/pre-requisites.feature')
