Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                     |
      | 'mod-login'                              |
      | 'mod-permissions'                        |
      | 'mod-users'                              |
      | 'mod-oai-pmh'                            |

    * table adminAdditionalPermissions
      | name                                     |

    * table userPermissions
      | name                                     |
      | 'oai-pmh.all'                            |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')