Feature: mod-gobi integration tests

  Background:
    * url baseUrl
    * table modules
      | name                  |
      | 'mod-gobi'            |
      | 'mod-orders'          |
      | 'mod-login'           |
      | 'mod-permissions'     |

    * table adminAdditionalPermissions
      | name                  |

    * table userPermissions
      | name          |
      | 'gobi.all'    |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
