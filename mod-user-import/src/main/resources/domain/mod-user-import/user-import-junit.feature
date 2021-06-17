Feature: mod-user-import integration tests

  Background:
    * callonce login admin
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-user-import'                   |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'user-import.all'                   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  # TODO If this needs to be done here it is because mod-auth-token needs to be done first like mod-login-saml
  Scenario: enable mod-users-bl module
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-users-bl'}], tenant: '#(testTenant)'}