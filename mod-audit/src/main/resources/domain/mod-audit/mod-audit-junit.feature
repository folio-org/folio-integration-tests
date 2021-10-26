Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                     |
      | 'mod-audit'                              |
      | 'mod-circulation'                        |

    * table adminAdditionalPermissions
      | name                                     |
      | 'overdue-fines-policies.item.post'       |
      | 'lost-item-fees-policies.item.post'      |

    * table userPermissions
      | name                                     |
      | 'audit.all'                              |
      | 'circulation.all'                        |
      | 'manualblocks.collection.get'            |
      | 'automated-patron-blocks.collection.get' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
    Given call read('classpath:global/initTest.feature')