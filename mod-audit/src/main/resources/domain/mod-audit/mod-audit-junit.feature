Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-audit'                         |
      | 'mod-circulation'                   |

    * table adminAdditionalPermissions
      | name                                |
      | 'overdue-fines-policies.item.post'  |
      | 'lost-item-fees-policies.item.post' |
      | 'overdue-fines-policies.item.delete' |
      | 'lost-item-fees-policies.item.delete' |

    * table userPermissions
      | name                                |
      | 'audit.all'                         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')