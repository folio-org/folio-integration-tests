# Please refer to the following document to see test cases for 'mod-consortia':
# https://wiki.folio.org/display/FOLIJET/Consortia+cases+covered+with+Karate+tests

Feature: mod-consortia and mod-bulk-operations integration tests

  Background:
    * url baseUrl
    * callonce login admin

    * table requiredModules
      | name                        |
      | 'mod-login'                 |
      | 'mod-inventory'             |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-source-record-storage' |
      | 'mod-source-record-manager' |
      | 'mod-data-import'           |
      | 'mod-search'                |

    # define consortium
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c32'

    # generate test tenants' names
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random

    # define users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def centralUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521412', username: 'central_user1', password: 'central_user1_password', tenant: '#(centralTenant)'}
    * def universityUser1 = { id: '334e5a9e-94f9-4673-8d1d-ab552863886b', username: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}

    # define custom login
    * def login = 'consortia/util/initData.feature@Login'

  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('consortia/util/tenant-and-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}
    * call read('consortia/util/tenant-and-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)'}
    * pause(5000)

    # add 'consortia.all' permission to 'consortiaAdmin'
    * call read(login) consortiaAdmin
    * call read('consortia/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'bulk-operations.item.inventory.get', 'search.index.instance-records.reindex.full.post', 'bulk-operations.all', 'source-records-manager.all', 'inventory.all']}

    # add 'consortia.all' permission to 'universityUser1'
    * call read(login) universityUser1
    * call read('consortia/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'bulk-operations.all', 'source-records-manager.all', 'inventory.all']}

  Scenario: Consortium api tests
    * call read('consortia/consortium.feature')

  Scenario: Tenant api tests
    * call read('consortia/tenant.feature')

  Scenario: Import MARC record
    * call read('init-data/import-marc-record.feature')

  Scenario: Sharing Instances api tests
    * call read('consortia/sharing-instance2.feature')

  Scenario: Add holdings to university
    * call read('init-data/init-data-for-holdings-university-ecs.feature')
    * call read('init-data/index.feature')
    * pause(360000)

  Scenario: Add new field
#    * call read('marc-instances-add.feature')

  Scenario: Bulk edit holding from central
    * call read('ecs-holdings.feature')

  Scenario: Destroy created ['university', 'central'] tenants
    * call read('consortia/util/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('consortia/util/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}
