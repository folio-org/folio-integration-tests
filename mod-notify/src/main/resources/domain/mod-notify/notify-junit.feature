Feature: mod-notify integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-notify'                        |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'notify.collection.get'             |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
