Feature: mod-circulation integration tests

  Background:
    * url baseUrl
    * table modules
      | name              |
      | 'mod-login'       |
      | 'mod-permissions' |
      | 'mod-circulation' |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')