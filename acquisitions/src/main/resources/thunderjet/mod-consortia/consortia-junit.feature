# Please refer to the following document to see test cases for 'mod-consortia':
# https://wiki.folio.org/display/FOLIJET/Consortia+cases+covered+with+Karate+tests

Feature: mod-consortia integration tests

  Background:
    * url baseUrl
    * callonce login admin

    * table requiredModules
      | name                        |
      | 'mod-login'                 |
      | 'mod-inventory'             |
      | 'mod-permissions'           |
    # following modules will also be enabled:
    # | 'mod-tags'                  |
    # | 'mod-notes'                 |
    # | 'mod-users'                 |
    # | 'mod-email'                 |
    # | 'mod-notify'                |
    # | 'mod-pubsub'                |
    # | 'mod-calendar'              |
    # | 'mod-consortia'             |
    # | 'mod-authtoken'             |
    # | 'mod-feesfines'             |
    # | 'mod-event-config'          |
    # | 'mod-patron-blocks'         |
    # | 'mod-template-engine'       |
    # | 'mod-inventory-storage'     |
    # | 'mod-password-validator'    |
    # | 'mod-circulation-storage'   |

    # define consortium
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c32'
    * def consortiaSystemUserName = 'consortia-system-user'

    # generate test tenants' names
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random

    # define users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def centralUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521412', username: 'central_user1', password: 'central_user1_password', tenant: '#(centralTenant)'}
    * def centralUser2 = { id: 'cd3f6cac-fa17-4079-9fae-2fb27e521412', username: 'central_user2', password: 'central_user2_password', tenant: '#(centralTenant)'}

    * def universityUser1 = { id: '334e5a9e-94f9-4673-8d1d-ab552863886b', username: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}
    * def universityUser2 = { id: '334e5a9e-94f9-4673-8d1d-ab552873886b', username: 'university_user2', password: 'university_user2_password', tenant: '#(universityTenant)'}

    # define custom login
    * def login = 'features/util/initData.feature@Login'

  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('features/util/tenant-and-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}
    * call read('features/util/tenant-and-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)'}

    # add 'consortia.all' permission to 'consortiaAdmin'
    # add 'tags.all' required for publish coordinator tests
    * call read(login) consortiaAdmin
    * call read('features/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'tags.all']}

    # add 'consortia.all' permission to 'universityUser1'
    # add 'tags.all' required for publish coordinator tests
    * call read(login) universityUser1
    * call read('features/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'tags.all']}

    # add more users
    * def createUserTenant1Parameters = []
    * def createUserTenant2Parameters = []
    * def createParameterArrays =
"""
function() {
  for (let i=3; i<104; i++) {
    const userId1 = uuid();
    const username1 = 'university_user'+i;
    const password1 = username1 +'_password';
    createUserTenant1Parameters.push({'id': userId1, 'username': username1, 'password': password1, tenant: centralTenant});

    const userId2 = uuid();
    const username2 = 'central_user'+i;
    const password2 = username2 +'_password';
    createUserTenant2Parameters.push({'id': userId2, 'username': username2, 'password': password2, tenant: universityTenant});
  }
}
"""
    * eval createParameterArrays()
    * def v = call read('features/util/initData.feature@PostUser') createUserTenant1Parameters
    * def v = call read('features/util/initData.feature@PostUser') createUserTenant2Parameters

  Scenario: Consortium api tests
    * call read('features/consortium.feature')

  Scenario: Tenant api tests
    * call read('features/tenant.feature')

  Scenario: Publish coordinator tests
    * call read('features/publish-coordinator.feature')

  Scenario: User-Tenant associations api tests
    * call read('features/user-tenant-associations.feature')

  Scenario: Sharing Instances api tests
    * call read('features/sharing-instance.feature')

  Scenario: Destroy created ['university', 'central'] tenants
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}