Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-audit'                         |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'audit.all'                         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')