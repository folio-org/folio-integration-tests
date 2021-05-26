Feature: mod-template-engine integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-template-engine'                        |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'templates.collection.get'           |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
