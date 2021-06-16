Feature: mod-notes integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-configuration'                 |
      | 'mod-notes'                         |

    * table adminAdditionalPermissions
      | name                   |

    * table userPermissions
      | name                   |
      | 'notes.all'            |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')