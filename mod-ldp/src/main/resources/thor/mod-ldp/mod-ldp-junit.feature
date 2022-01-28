Feature: mod-ldp integration tests

Background:
  * url baseUrl
  * table modules
    | name                                |
    | 'mod-login'                         |
    | 'mod-permissions'                   |
    | 'mod-ldp'                           |
    | 'mod-configuration'                 |

  * table adminAdditionalPermissions
    | name                                |

  * table userPermissions
    | name                                |
    | 'ldp.read'                          |
    | 'ldp.config.read'                   |
    | 'ldp.config.edit'                   |


Scenario: create tenant and users for testing
  Given call read('classpath:common/setup-users.feature')
