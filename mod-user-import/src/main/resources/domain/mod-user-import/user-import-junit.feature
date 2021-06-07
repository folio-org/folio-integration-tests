Feature: mod-user-import integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-user-import'                   |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'user-import.all'                   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
