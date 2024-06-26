Feature: mod-consortia integration tests

  # Please refer to the following document to see test cases for 'mod-consortia':
  # https://wiki.folio.org/display/FOLIJET/Consortia+cases+covered+with+Karate+tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * call login admin

    * table requiredModules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-audit'                 |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-circulation-storage'   |


    * table adminAdditionalPermissions
      | name                                         |
      | 'orders-storage.module.all'                  |
      | 'finance.module.all'                         |
      | 'acquisitions-units.memberships.item.delete' |
      | 'acquisitions-units.memberships.item.post'   |
      | 'acquisitions-units.units.item.post'         |

    # generate names for tenants
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random

    * def universityUser1Id = callonce uuid3

    # define consortium
    * def consortiumId = callonce uuid12

    # define main users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}
    * def universityUser1 = { id: '#(universityUser1Id)', username: 'university_user1', password: 'university_user1_password', type: 'staff', tenant: '#(universityTenant)'}

    # define custom login
    * def login = read('classpath:common-consortia/initData.feature@Login')

  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)'}

    # add 'consortia.all' (for consortia management)
    * call login consortiaAdmin
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all']}

    * call login universityUser1
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all']}

  Scenario: Create consortium
    * call read('tenant-utils/consortium.feature')

  Scenario: Add 2 tenants to consortium
    * call read('tenant-utils/tenant.feature')

  Scenario: Add permissions to consortia_admin
    * call read('tenant-utils/add-permissions-for-admin.feature')

  Scenario: Create and open order
    * call read('consortia-orders.feature')

  Scenario: Destroy created ['central', 'university'] tenants
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}
