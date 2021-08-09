Feature: mod-codex-ekb integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-codex-ekb'     |
      | 'mod-codex-mux'     |
      | 'mod-kb-ebsco-java' |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name              |
      | 'codex-ekb.all'   |
      | 'codex-mux.all'   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
