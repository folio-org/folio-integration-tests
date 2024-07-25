Feature: edge-patron integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'okapi'                   |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-inventory'           |
      | 'mod-inventory-storage'   |
      | 'mod-feesfines'           |
      | 'mod-users'             |
      | 'edge-patron'             |
      | 'mod-circulation'         |
      | 'mod-circulation-storage' |

    * table adminAdditionalPermissions
      | name                                                           |
      | 'users.item.post'                                              |
      | 'lost-item-fees-policies.item.post'                            |
      | 'owners.item.post'                                             |
      | 'overdue-fines-policies.item.post'                             |

    * table userPermissions
      | name                                                           |
      | 'usergroups.item.post'                                         |
      | 'users.item.post'                                              |
      | 'lost-item-fees-policies.item.post'                            |
      | 'owners.item.post'                                             |
      | 'overdue-fines-policies.item.post'                             |
      | 'users.collection.get'                                         |
      | 'patron.account.item.post'                                     |
      | 'usergroups.collection.get'                                    |
      | 'addresstypes.collection.get'                                  |
      | 'addresstypes.item.post'                                       |
      | 'patron.account.item.get'                                      |
      | 'patron.account.item.put'                                      |


  * def testTenant = 'ttttpatron'
  * def testUser = { tenant: '#(testTenant)', name: 'testpatron', password: 'password' }

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature') { testTenant: '#(testTenant)', testUser: #(testUser) }
