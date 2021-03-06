Feature: mod-event-config integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-event-config'                  |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'event.config.collection.get'       |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
