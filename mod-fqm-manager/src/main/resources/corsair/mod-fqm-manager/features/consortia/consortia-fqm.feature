# Please refer to the following document to see test cases for 'mod-consortia':
# https://wiki.folio.org/display/FOLIJET/Consortia+cases+covered+with+Karate+tests

Feature: mod-consortia and mod-fqm-manager integration tests

  Background:
    * url baseUrl
    * callonce login admin
    * configure readTimeout = 600000

    * table requiredModules
      | name                                |
      | 'mod-login'                         |
      | 'mod-inventory'                     |
      | 'mod-permissions'                   |
      | 'okapi'                             |
      | 'mod-users'                         |
      | 'mod-inventory-storage'             |
      | 'mod-circulation'                   |
      | 'mod-circulation-storage'           |
      | 'mod-finance'                       |
      | 'mod-finance-storage'               |
      | 'mod-orders'                        |
      | 'mod-orders-storage'                |
      | 'mod-organizations'                 |
      | 'mod-organizations-storage'         |


    # define consortium
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c31'

    # generate test tenants' names
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random

    # define users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def centralUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521412', username: 'central_user1', password: 'central_user1_password', tenant: '#(centralTenant)'}
    * def universityUser1 = { id: '334e5a9e-94f9-4673-8d1d-ab552863886b', username: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}

    # define custom login
    * def login = 'util/initData.feature@Login'

  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('util/tenant-and-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}
    * call read('util/tenant-and-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)'}
    * eval java.lang.Thread.sleep(5000)

    # add 'consortia.all' permission to 'consortiaAdmin'
    # add 'tags.all' required for publish coordinator tests
    * call read(login) consortiaAdmin
    * call read('util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'inventory.instances.item.get', 'inventory-storage.all','fqm.entityTypes.collection.get']}


    # add 'consortia.all' permission to 'universityUser1'
    # add 'tags.all' required for publish coordinator tests
    * call read(login) universityUser1
    * call read('util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'inventory.instances.item.get', 'inventory-storage.all','fqm.entityTypes.collection.get']}

  Scenario: Consortium api tests
    * call read('consortium.feature')

  Scenario: Tenant api tests
    * call read('tenant.feature')

  Scenario: Cross Tenant
    * call read('cross_tenant_et.feature')


  Scenario: Destroy created ['university', 'central'] tenants
    * call read('util/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('util/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}