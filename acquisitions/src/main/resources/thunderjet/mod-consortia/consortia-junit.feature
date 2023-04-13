Feature: mod-consortia integration tests

  Background:
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-consortia'             |

    * table userPermissions
      | name                                   |
      | 'consortia.all'                        |

  Scenario: Create tenant and users for testing
    * call read('classpath:common/setup-users.feature')
