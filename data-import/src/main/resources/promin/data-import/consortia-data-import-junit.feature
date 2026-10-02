Feature: data-import ECS integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-users-bl'              |
      | 'mod-configuration'         |
      | 'mod-source-record-storage' |
      | 'mod-source-record-manager' |
      | 'mod-inventory-storage'     |
      | 'mod-di-converter-storage'  |
      | 'mod-inventory'             |
      | 'mod-data-export'           |
      | 'mod-data-import'           |
      | 'mod-entities-links'        |
      | 'mod-quick-marc'            |
      | 'mod-search'                |

    * table userPermissions
      | name                                                          |
      | 'change-manager.jobExecutions.children.collection.get'        |
      | 'change-manager.jobExecutions.item.get'                       |
      | 'change-manager.jobexecutions.delete'                         |
      | 'converter-storage.actionprofile.collection.get'              |
      | 'converter-storage.actionprofile.delete'                      |
      | 'converter-storage.actionprofile.post'                        |
      | 'converter-storage.jobprofile.collection.get'                 |
      | 'converter-storage.jobprofile.delete'                         |
      | 'converter-storage.jobprofile.item.get'                       |
      | 'converter-storage.jobprofile.post'                           |
      | 'converter-storage.mappingprofile.delete'                     |
      | 'converter-storage.mappingprofile.post'                       |
      | 'converter-storage.matchprofile.post'                         |
      | 'data-export.export.post'                                     |
      | 'data-export.file-definitions.item.get'                       |
      | 'data-export.file-definitions.item.post'                      |
      | 'data-export.file-definitions.upload.post'                    |
      | 'data-export.job-executions.collection.get'                   |
      | 'data-export.job-executions.items.download.get'               |
      | 'data-export.job-profiles.item.post'                          |
      | 'data-export.mapping-profiles.item.post'                      |
      | 'data-export.quick.export.post'                               |
      | 'data-import.assembleStorageFile.post'                        |
      | 'data-import.datatypes.get'                                   |
      | 'data-import.downloadUrl.get'                                 |
      | 'data-import.fileExtensions.collection.get'                   |
      | 'data-import.fileExtensions.default.post'                     |
      | 'data-import.fileExtensions.delete'                           |
      | 'data-import.fileExtensions.item.get'                         |
      | 'data-import.fileExtensions.post'                             |
      | 'data-import.fileExtensions.put'                              |
      | 'data-import.jobexecution.cancel'                             |
      | 'data-import.splitconfig.get'                                 |
      | 'data-import.upload.file.post'                                |
      | 'data-import.uploadDefinitions.files.item.post'               |
      | 'data-import.uploadDefinitions.item.get'                      |
      | 'data-import.uploadDefinitions.processFiles.item.post'        |
      | 'data-import.uploadUrl.item.get'                              |
      | 'data-import.uploadUrl.subsequent.item.get'                   |
      | 'data-import.uploaddefinitions.files.delete'                  |
      | 'data-import.uploaddefinitions.post'                          |
      | 'instance-authority-links.instances.collection.get'           |
      | 'inventory-storage.authorities.collection.get'                |
      | 'inventory-storage.authorities.item.delete'                   |
      | 'inventory-storage.authorities.item.get'                      |
      | 'inventory-storage.call-number-types.item.post'               |
      | 'inventory-storage.contributor-name-types.collection.get'     |
      | 'inventory-storage.contributor-types.collection.get'          |
      | 'inventory-storage.electronic-access-relationships.item.post' |
      | 'inventory-storage.holdings-sources.item.post'                |
      | 'inventory-storage.holdings-types.item.post'                  |
      | 'inventory-storage.holdings.collection.get'                   |
      | 'inventory-storage.holdings.item.post'                        |
      | 'inventory-storage.identifier-types.collection.get'           |
      | 'inventory-storage.identifier-types.item.post'                |
      | 'inventory-storage.ill-policies.item.post'                    |
      | 'inventory-storage.instance-statuses.item.post'               |
      | 'inventory-storage.instance-types.item.post'                  |
      | 'inventory-storage.instances.collection.get'                  |
      | 'inventory-storage.instances.item.post'                       |
      | 'inventory-storage.item-note-types.item.post'                 |
      | 'inventory-storage.items.collection.get'                      |
      | 'inventory-storage.items.item.post'                           |
      | 'inventory-storage.loan-types.item.post'                      |
      | 'inventory-storage.location-units.campuses.item.post'         |
      | 'inventory-storage.location-units.institutions.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'        |
      | 'inventory-storage.locations.collection.get'                  |
      | 'inventory-storage.locations.item.post'                       |
      | 'inventory-storage.material-types.item.post'                  |
      | 'inventory-storage.statistical-code-types.item.post'          |
      | 'inventory-storage.statistical-codes.item.post'               |
      | 'inventory.instances.collection.get'                          |
      | 'inventory.instances.item.get'                                |
      | 'inventory.instances.item.put'                                |
      | 'inventory.items.collection.get'                              |
      | 'inventory.items.item.get'                                    |
      | 'mapping-metadata.item.get'                                   |
      | 'mapping-metadata.type.item.get'                              |
      | 'mapping-rules.get'                                           |
      | 'mapping-rules.restore'                                       |
      | 'mapping-rules.update'                                        |
      | 'marc-records-editor.item.get'                                |
      | 'marc-records-editor.item.put'                                |
      | 'metadata-provider.jobExecutions.collection.get'              |
      | 'metadata-provider.jobExecutions.users.collection.get'        |
      | 'metadata-provider.jobLogEntries.collection.get'              |
      | 'metadata-provider.jobLogEntries.records.item.get'            |
      | 'metadata-provider.jobSummary.item.get'                       |
      | 'metadata-provider.journalRecords.collection.get'             |
      | 'search.authorities.collection.get'                           |
      | 'search.instances.collection.get'                             |
      | 'source-storage.records.formatted.item.get'                   |
      | 'source-storage.records.item.get'                             |
      | 'source-storage.records.post'                                 |
      | 'source-storage.snapshots.post'                               |
      | 'source-storage.source-records.collection.get'                |
      | 'source-storage.source-records.item.get'                      |
      | 'users.collection.get'                                        |

    # define custom login
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

  Scenario: Create ['central', 'university', 'college'] tenants and set up admins
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)', centralTenantId: '#(centralTenant)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)', user: '#(collegeUser1)'}

  Scenario: Create consortium and setup tenants
    * call login consortiaAdmin
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia') { tenant: '#(centralTenant)' }

    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(centralTenant)', id: '#(centralTenantId)', isCentral: true, code: 'ABC', centralTenantId: '#(centralTenant)' }
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(universityTenant)', id: '#(universityTenantId)', isCentral: false, code: 'XYZ' }
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(collegeTenant)', id: '#(collegeTenantId)', isCentral: false, code: 'BEE' }

  Scenario: Add affiliations
    * call login consortiaAdmin
    * call read('classpath:common-consortia/eureka/affiliation.feature@AddAffiliation') { user: '#(universityUser1)', tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)'  }

    * table notEmptyPermissions
      | name            |
      | 'consortia.all' |
    # add non-empty permission to shadow 'universityUser1' in the college tenant
    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') { id: '#(universityUser1.id)', tenant: '#(collegeTenant)', userPermissions: '#(notEmptyPermissions)'}

  Scenario: Init global data for member tenants
    # mod_inventory_init_data.feature internally calls the "login" variable in scope with
    # "testUser" which carry username/password/tenant,
    # matching common-consortia's Login scenario, not common/login.feature's name field)
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

    * def testTenant = universityTenant
    * def testUser = universityUser1
    * call read('classpath:promin/data-import/global/mod_inventory_init_data.feature')

    * def testTenant = collegeTenant
    * def testUser = collegeUser1
    * call read('classpath:promin/data-import/global/mod_inventory_init_data.feature')
