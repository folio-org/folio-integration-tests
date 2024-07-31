Feature: mod-gobi integration tests

  Background:
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-audit'                 |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-search'                |
      | 'mod-source-record-manager' |
      | 'mod-entities-links'        |
      | 'mod-tags'                  |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |


    * table userPermissions
      | name                        |

  Scenario: Create tenant and users for testing
  # Create tenant and users for testing:
    * call read('classpath:common/setup-users.feature')
