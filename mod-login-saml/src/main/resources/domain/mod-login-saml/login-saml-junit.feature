Feature: mod-login-saml integration tests

  Background:
    # Login with the admin user is necessary in order to create the tenant with tenant.feature.
    * callonce login admin
    * url baseUrl

    # Define the modules used in this test.
    * table modules
      | name                                |
      | 'mod-login-saml'                    |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |

  Scenario: create new tenant
    Given call read('classpath:common/tenant.feature@create') { tenant: '#(testTenant)'}

  Scenario: get and install configured modules
    Given call read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testTenant)'}
