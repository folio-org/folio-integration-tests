Feature: mod-notes integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-entities-links'        |
      | 'mod-source-record-manager' |
      | 'mod-source-record-storage' |
      | 'mod-inventory'             |
      | 'mod-inventory-storage'     |

    * table userPermissions
      | name                                     |
      | 'instance-authority-links.instances.all' |
      | 'inventory-storage.all'                  |
      | 'source-storage.all'                     |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: setup sample test data
    Given call read('classpath:spitfire/mod-entities-links/features/setup.feature')