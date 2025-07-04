Feature: edge-dcb integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |
      | 'mod-dcb'                   |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-circulation-storage'   |


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
      | 'inventory-storage.service-points.collection.get'          |
      | 'dcb.transactions.post'                                    |
      | 'dcb.transactions.status.get'                              |
      | 'dcb.transactions.status.put'                              |
      | 'dcb.transactions.collection.get'                          |
      | 'dcb.transactions.item.put'                                |
      | 'circulation.check-out-by-barcode.post'                    |
      | 'circulation.check-in-by-barcode.post'                     |
      | 'circulation.loans.collection.get'                         |
      | 'circulation-storage.loan-policies.collection.get'         |
      | 'manualblocks.collection.get'                              |
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
      | 'circulation-storage.cancellation-reasons.item.post'       |
      | 'inventory-storage.holdings-sources.collection.get'        |
      | 'circulation-item.item.get'                                |
      | 'circulation-item.collection.get'                          |
      | 'circulation-storage.requests.collection.get'              |
      | 'circulation-storage.loans.collection.get'                 |
      | 'patron-blocks.automated-patron-blocks.collection.get'     |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: call pre requisites feature file
    * callonce read('classpath:volaris/mod-dcb/reusable/pre-requisites.feature') {proxyCall: true}