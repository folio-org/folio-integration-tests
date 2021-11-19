Feature: mod-email integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-email'                         |
      | 'mod-configuration'                 |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'email.message.post'                |
      | 'email.message.collection.get'      |
      | 'email.message.delete'              |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
