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


    * def testTenant = 'ttttpatron'
  * def testUser = { tenant: '#(testTenant)', name: 'testpatron', password: 'password' }
  #eyJzIjoidVh5a2xCZTRnaiIsInQiOiJ0ZXN0X2VkZ2VfZGNiIiwidSI6ImRjYkNsaWVudCJ9

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature') { testTenant: '#(testTenant)', testUser: #(testUser) }
