Feature: edge-inn-reach integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |

    * table userPermissions
      | name                                              |

  Scenario: init data
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')

