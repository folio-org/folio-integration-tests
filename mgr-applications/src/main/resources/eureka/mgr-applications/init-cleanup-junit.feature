Feature: initialize isolated mgr-applications cleanup test data

  Background:
    * url baseUrl
    * configure readTimeout = 3000000

    * table modules
      | name                  |
      | 'mod-users-keycloak'  |
      | 'mod-login-keycloak'  |
      | 'mod-roles-keycloak'  |

    * table userPermissions
      | name |

  Scenario: prepare isolated tenant and entitlement for cleanup test
    * call read('classpath:common/eureka/setup-users.feature@createTenant')
    * call read('classpath:common/eureka/setup-users.feature@createEntitlement')
    * call read('classpath:eureka/mgr-applications/features/helpers.feature@loginAdmin')
    * call read('classpath:eureka/mgr-applications/features/helpers.feature@grantMgrApplicationsPermissions')
