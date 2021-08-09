Feature: mod-sender integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-sender'                        |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'sender.message-delivery'           |
      | 'users.item.post'                   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
