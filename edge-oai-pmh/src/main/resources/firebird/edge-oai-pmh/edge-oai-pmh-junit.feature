Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 420000
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
    * pause(5000)
    Given call read('classpath:common/eureka/setup-users.feature')
