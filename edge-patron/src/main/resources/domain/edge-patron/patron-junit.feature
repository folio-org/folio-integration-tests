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

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
