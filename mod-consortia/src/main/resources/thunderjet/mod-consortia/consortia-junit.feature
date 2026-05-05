@parallel=false
Feature: mod-consortia-keycloak integration tests

  # Please refer to the following document to see test cases for 'mod-consortia-keycloak':
  # https://wiki.folio.org/display/FOLIJET/Consortia+cases+covered+with+Karate+tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure connectTimeout = 600000

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-settings'              |
      | 'mod-configuration'         |
      | 'mod-login-keycloak'        |
      | 'mod-users'                 |
      | 'mod-inventory-storage'     |
      | 'mod-pubsub'                |
      | 'mod-circulation-storage'   |
      | 'mod-source-record-manager' |
      | 'mod-entities-links'        |
      | 'mod-inventory'             |
      | 'folio-custom-fields'       |
      | 'mod-feesfines'             |

    # generate names for tenants
    * def random = callonce randomMillis
    * def uuids = callonce uuids 4
    * def centralTenantId = uuids[0]
    * def universityTenantId = uuids[1]
    * def collegeTenantId = uuids[2]
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random
    * def collegeTenant = 'college' + random

    * def centralUser1Id = callonce uuid1
    * def userPhone = '11111-11111'
    * def userMobilePhone = '00000-11111'

    * def centralUser2Id = callonce uuid2

    * def universityUser1Id = callonce uuid3
    * def universityUser1Phone = '22222-22222'
    * def universityUser1MobilePhone = '00000-22222'

    * def universityUser2Id = callonce uuid4

    * def collegeUser1Id = callonce uuid5
    * def collegeUser2Id = callonce uuid6

    * def shadowUserId = callonce uuid7
    * def patronUserId = callonce uuid8

    * def userToUpdateId = callonce uuid9
    * def universityUserToUpdateId = callonce uuid10
    * def patronUserToUpdateId = callonce uuid11

    # define consortium
    * def consortiumId = uuids[3]

    # define main users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def centralUser1 = { id: '#(centralUser1Id)', username: 'central_user1', password: 'central_user1_password', type: 'staff', tenant: '#(centralTenant)', phone: '#(userPhone)', mobilePhone: '#(userMobilePhone)'}
    * def centralUser2 = { id: '#(centralUser2Id)', username: 'central_user2', password: 'central_user2_password', type: 'staff', tenant: '#(centralTenant)'}

    * def universityUser1 = { id: '#(universityUser1Id)', username: 'university_user1', password: 'university_user1_password', type: 'staff', tenant: '#(universityTenant)', phone: '#(universityUser1Phone)', mobilePhone:  '#(universityUser1MobilePhone)'}
    * def universityUser2 = { id: '#(universityUser2Id)', username: 'university_user2', password: 'university_user2_password', type: 'staff', tenant: '#(universityTenant)'}

    * def collegeUser1 = { id: '#(collegeUser1Id)', username: 'college_user1', password: 'college_user1_password', type: 'staff', tenant: '#(collegeTenant)'}
    * def collegeUser2 = { id: '#(collegeUser2Id)', username: 'college_user2', password: 'college_user2_password', type: 'staff', tenant: '#(collegeTenant)'}

    * def shadowUser = { id: '#(shadowUserId)', username: 'university_shadow_user', password: 'university_shadow_user_password', type: 'shadow', tenant: '#(universityTenant)'}
    * def patronUser = { id: '#(patronUserId)', username: 'college_patron_user', password: 'college_patron_user_password', type: 'patron', tenant: '#(collegeTenant)'}

    * def userToUpdate = { id: '#(userToUpdateId)', username: 'user_to_update', password: 'user_to_update_password', type: 'staff', tenant: '#(centralTenant)', phone: '#(userPhone)', mobilePhone: '#(userMobilePhone)'}
    * def universityUserToUpdate = { id: '#(universityUserToUpdateId)', username: 'university_user_to_update', password: 'university_user_to_update_password', type: 'staff', tenant: '#(universityTenant)', phone: '#(userPhone)', mobilePhone: '#(userMobilePhone)'}
    * def patronUserToUpdate = { id: '#(patronUserToUpdateId)', username: 'patron_user_to_update', password: 'patron_user_to_update_password', type: 'patron', tenant: '#(collegeTenant)', phone: '#(userPhone)', mobilePhone: '#(userMobilePhone)'}

    # define custom login
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    # capabilities granted to main users and to shadow consortiaAdmin
    # (consortia.* and tags.* perms are attached by @SetupTenant — list only the rest here).
    * table mainUserPerms
      | name                                         |
      | 'users.item.post'                            |
      | 'users.item.get'                             |
      | 'users.item.put'                             |
      | 'users.item.delete'                          |
      | 'users.collection.get'                       |
      | 'user-tenants.collection.get'                |
      | 'departments.item.post'                      |
      | 'departments.item.get'                       |
      | 'departments.item.put'                       |
      | 'departments.item.delete'                    |
      | 'departments.collection.get'                 |
      | 'usergroups.item.post'                       |
      | 'usergroups.item.get'                        |
      | 'usergroups.item.put'                        |
      | 'usergroups.item.delete'                     |
      | 'usergroups.collection.get'                  |
      | 'inventory-storage.instance-types.item.post' |
      | 'inventory-storage.instance-types.item.get'  |
      | 'inventory.instances.item.post'              |
      | 'inventory.instances.item.get'               |
      | 'inventory.instances.item.delete'            |
      | 'login.item.post'                            |

    # reusable features
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')
    * def deleteTenantAndEntitlement = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')

  Scenario: Create ['central', 'university', 'college'] tenants and set up admins
    * call setupTenant { tenantId: '#(centralTenantId)', tenant: '#(centralTenant)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenantId: '#(universityTenantId)', tenant: '#(universityTenant)', user: '#(universityUser1)' }
    * call setupTenant { tenantId: '#(collegeTenantId)', tenant: '#(collegeTenant)', user: '#(collegeUser1)' }

    # attach capabilities to the local admins in each tenant
    * call putCaps { tenant: '#(centralTenant)', user: '#(consortiaAdmin)', userPermissions: '#(mainUserPerms)' }
    * call putCaps { tenant: '#(universityTenant)', user: '#(universityUser1)', userPermissions: '#(mainUserPerms)' }
    * call putCaps { tenant: '#(collegeTenant)', user: '#(collegeUser1)', userPermissions: '#(mainUserPerms)' }


  Scenario: Consortium api tests
    * call read('features/consortium.feature')

  Scenario: Tenant api tests
    * call read('features/tenant.feature')

  Scenario: verify and setup 'consortiaAdmin' for all tenants
    * call read('features/consortia-admin-verification-and-setup.feature')

  Scenario: User-Tenant associations api tests
    * call read('features/user-tenant-associations.feature')

  Scenario: verify users with shadow or patron types not processed by consortia pipeline
    * call read('features/consortia-skip-not-required-user-types.feature')

  Scenario: verify user update scenarios
    * call read('features/consortia-user-update.feature')

  Scenario: verify user type update scenarios
    * call read('features/consortia-user-type-update.feature')

  Scenario: Publish coordinator tests
    * call read('features/publish-coordinator.feature')

  Scenario: Sharing Instances api tests
    * call read('features/sharing-instance.feature')

  Scenario: Sharing Settings api tests
    * call read('features/sharing-setting.feature')

  Scenario: Sharing Patron Groups Settings api tests
    * call read('features/sharing-patron-groups-setting.feature')

  Scenario: Destroy created ['central', 'university', 'college'] tenants
    * call deleteTenantAndEntitlement { tenantId: '#(universityTenantId)' }
    * call deleteTenantAndEntitlement { tenantId: '#(collegeTenantId)' }
    * call deleteTenantAndEntitlement { tenantId: '#(centralTenantId)' }
