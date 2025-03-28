Feature: mod-sender integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-sender'                        |

    * table userPermissions
      | name                                |
      | 'sender.message-delivery.post'      |
      | 'users.item.post'                   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
