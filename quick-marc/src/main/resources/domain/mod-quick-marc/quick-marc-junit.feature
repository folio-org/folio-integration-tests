Feature: mod-quick-marc integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-inventory'                     |
      | 'mod-data-import'                   |
      | 'mod-quick-marc'                    |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                 |
      |'inventory-storage.preceding-succeeding-titles.collection.get'|
      | 'records-editor.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
