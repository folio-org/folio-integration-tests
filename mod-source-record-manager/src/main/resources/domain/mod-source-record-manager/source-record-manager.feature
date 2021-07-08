Feature: mod-source-record-storage integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-source-record-manager' |

    * table adminAdditionalPermissions
      | name                      |

    * table userPermissions
      | name                         |
      | 'mapping-rules.get' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')