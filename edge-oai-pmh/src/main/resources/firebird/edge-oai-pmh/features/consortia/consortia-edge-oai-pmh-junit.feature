Feature: edge-oai-pmh ECS tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * table modules
      | name                                     |
      | 'mod-login'                              |
      | 'mod-permissions'                        |
      | 'mod-users'                              |
      | 'mod-oai-pmh'                            |
      | 'mod-quick-marc'                         |
      | 'mod-data-import'                        |
      | 'mod-di-converter-storage'               |
      | 'mod-source-record-storage'              |
      | 'mod-source-record-manager'              |
      | 'mod-inventory-storage'                  |
      | 'mod-inventory'                          |

    * table userPermissions
      | name                                     |
      | 'oai-pmh.clean-up-error-logs.post'                                            |
      | 'oai-pmh.clean-up-instances.post'                                             |
      | 'oai-pmh.filtering-conditions.get'                                            |
      | 'oai-pmh.sets.item.collection.get'                                            |
      | 'oai-pmh.sets.item.post'                                                      |
      | 'oai-pmh.sets.item.delete'                                                    |
      | 'oai-pmh.sets.item.put'                                                       |
      | 'oai-pmh.sets.item.get'                                                       |
      | 'oai-pmh.records.collection.get'                                              |
      | 'oai-pmh.request-metadata.collection.get'                                     |
      | 'oai-pmh.request-metadata.failed-instances.collection.get'                    |
      | 'oai-pmh.request-metadata.failed-to-save-instances.collection.get'            |
      | 'oai-pmh.request-metadata.logs.item.get'                                      |
      | 'oai-pmh.request-metadata.skipped-instances.collection.get'                   |
      | 'oai-pmh.request-metadata.suppressed-from-discovery-instances.collection.get' |
      | 'inventory-storage.electronic-access-relationships.item.post'                 |
      | 'inventory-storage.holdings.item.post'                                        |
      | 'inventory-storage.instances.item.post'                                       |
      | 'inventory-storage.items.item.post'                                           |
      | 'source-storage.snapshots.post'                                               |
      | 'source-storage.records.post'                                                 |
      | 'inventory-storage.holdings-sources.item.post'                                |
      | 'inventory-storage.instance-types.item.post'                                  |
      | 'inventory-storage.location-units.institutions.item.post'                     |
      | 'inventory-storage.location-units.campuses.item.post'                         |
      | 'inventory-storage.location-units.libraries.item.post'                        |
      | 'inventory-storage.locations.item.post'                                       |
      | 'inventory-storage.call-number-types.item.post'                               |
      | 'inventory-storage.loan-types.item.post'                                      |
      | 'inventory-storage.material-types.item.post'                                  |
      | 'configuration.entries.item.post'                                             |
      | 'configuration.entries.collection.get'                                        |
      | 'configuration.entries.item.get'                                              |
      | 'configuration.entries.item.put'                                              |
      | 'inventory-storage.holdings.item.get'                                         |
      | 'inventory-storage.items.collection.get'                                      |
      | 'inventory-storage.items.item.get'                                            |
      | 'inventory-storage.items.item.put'                                            |
      | 'inventory-storage.holdings.item.put'                                         |
      | 'inventory-storage.instances.collection.get'                                  |
      | 'inventory-storage.instances.item.get'                                        |
      | 'marc-records-editor.item.get'                                                |
      | 'marc-records-editor.item.put'                                                |
      | 'oai-pmh.configuration-settings.collection.get'                               |
      | 'oai-pmh.configuration-settings.item.get'                                     |
      | 'oai-pmh.configuration-settings.item.post'                                    |
      | 'oai-pmh.configuration-settings.item.put'                                     |
      | 'oai-pmh.configuration-settings.item.delete'                                  |
      | 'inventory-storage.instances.item.put'                                        |
      | 'source-storage.records.put'                                                  |
      | 'source-storage.records.item.get'                                             |
      | 'inventory-storage.items.item.delete'                                         |
      | 'inventory-storage.holdings.item.delete'                                      |
      | 'inventory-storage.instances.item.delete'                                     |
      | 'source-storage.records.delete'                                               |
      | 'source-storage.snapshots.delete'                                             |
      | 'inventory.instances.collection.get'                                          |
      | 'inventory.instances.item.post'                                               |
      | 'inventory.instances.item.get'                                                |
      | 'inventory.instances.item.put'                                                |
      | 'inventory.instances.item.delete'                                             |
      | 'inventory-storage.hrid-settings.item.put'                                    |
      | 'data-import.uploaddefinitions.post'                                          |
      | 'data-import.uploadDefinitions.item.get'                                      |
      | 'data-import.uploadUrl.item.get'                                              |
      | 'data-import.assembleStorageFile.post'                                        |
      | 'data-import.uploadDefinitions.processFiles.item.post'                        |
      | 'metadata-provider.jobExecutions.collection.get'                              |
      | 'user-tenants.collection.get'                                                 |
      | 'oai-pmh.all'                                                                 |

    # define custom login
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

  Scenario: Create ['central', 'college', 'university'] tenants and set up admins
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)', user: '#(collegeUser1)'}

  Scenario: Create consortium and setup tenants
    * call login consortiaAdmin
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia') { tenant: '#(centralTenant)' }

    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(centralTenant)', id: '#(centralTenantId)', isCentral: true, code: 'ABC' }
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(universityTenant)', id: '#(universityTenantId)', isCentral: false, code: 'XYZ' }
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(collegeTenant)', id: '#(collegeTenantId)', isCentral: false, code: 'BEE' }

  Scenario: Add affilitions
    * call login consortiaAdmin
    * call read('classpath:common-consortia/eureka/affiliation.feature@AddAffiliation') { user: '#(universityUser1)', tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)'  }

    * table notEmptyPermissinos
      | name            |
      | 'consortia.all' |
    # add non-empty permission to shadow 'centralUser1'
    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') { id: '#(universityUser1.id)', tenant: '#(collegeTenant)', userPermissions: '#(notEmptyPermissinos)'}

  Scenario: Update hrId for all tenants
    * call login consortiaAdmin
    * call read('classpath:firebird/edge-oai-pmh/features/consortia/hrid-util.feature@UpdateHrId') { tenant: '#(centralTenant)', prefix: 'cons' }

    * call login universityUser1
    * call read('classpath:firebird/edge-oai-pmh/features/consortia/hrid-util.feature@UpdateHrId') { tenant: '#(universityTenant)', prefix: 'u' }

    * call login collegeUser1
    * call read('classpath:firebird/edge-oai-pmh/features/consortia/hrid-util.feature@UpdateHrId') { tenant: '#(collegeTenant)', prefix: 'o' }

  Scenario: Create reference data
    Given call read('classpath:firebird/edge-oai-pmh/features/init_data/create-reference-data.feature') { testUser : '#(consortiaAdmin)' }
    Given call read('classpath:firebird/edge-oai-pmh/features/init_data/create-reference-data.feature') { testUser : '#(universityUser1)' }
    Given call read('classpath:firebird/edge-oai-pmh/features/init_data/create-reference-data.feature') { testUser : '#(collegeUser1)' }