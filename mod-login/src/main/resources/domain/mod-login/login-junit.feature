Feature: mod-login integration tests

  Background:
    * callonce login admin
    * url baseUrl
    * table modules
      | name                                |
      | 'okapi'                             |
      | 'mod-permissions'                   |
      | 'mod-configuration'                 |
      | 'mod-users'                         |
      | 'mod-login'                         |

    * table adminAdditionalPermissions
      | name                                |
      | 'users.all'                         |

    * table userPermissions
      | name                                |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')



