Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 360000
    * table modules
      | name                                     |
      | 'mod-login'                              |
      | 'mod-permissions'                        |
      | 'mod-users'                              |
      | 'mod-oai-pmh'                            |
      | 'mod-quick-marc'                         |

    * table adminAdditionalPermissions
      | name                                     |

    * table userPermissions
      | name                                     |
      | 'oai-pmh.all'                            |


  Scenario: create tenant and users for testing
    * pause(300000)
    Given call read('classpath:common/setup-users.feature')
