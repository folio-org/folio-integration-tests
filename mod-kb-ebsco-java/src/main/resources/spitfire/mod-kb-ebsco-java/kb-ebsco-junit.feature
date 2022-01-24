Feature: mod-kb-ebsco-java integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-users'         |
      | 'mod-kb-ebsco-java' |
      | 'mod-configuration' |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                         |
      | 'kb-ebsco.all'                               |
      | 'kb-ebsco.kb-credentials.holdings-load.post' |
      | 'users.all'                                  |
      | 'configuration.all'                          |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
