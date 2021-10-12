Feature: mod-circulation integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-circulation'                   |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                        |
      | 'circulation-storage.loans.item.post'     |
      | 'circulation-storage.loans.item.get'     |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')