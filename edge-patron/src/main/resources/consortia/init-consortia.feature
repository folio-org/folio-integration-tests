@parallel=false
Feature: Initialize mod-consortia integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * configure readTimeout = 600000
    * configure connectTimeout = 600000

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-users'                 |
      | 'mod-login'                 |
      | 'mod-inventory-storage'     |
      | 'mod-pubsub'                |
      | 'mod-circulation-storage'   |
      | 'mod-source-record-manager' |
      | 'mod-entities-links'        |
      | 'mod-inventory'             |
      | 'folio-custom-fields'       |
      | 'edge-patron'               |
      | 'mod-patron'                |
      | 'mod-tlr'                   |
      | 'mod-circulation'           |
      | 'mod-circulation-bff'       |
      | 'mod-dcb'                   |
      | 'mod-record-specifications' |

    # Permissions for consortiaAdmin and universityUser
    * table userPermissions
      | name                                                        |
      | 'circulation.rules.get'                                     |
      | 'circulation.rules.put'                                     |
      | 'circulation-storage.circulation-rules.get'                 |
      | 'circulation-storage.circulation-rules.put'                 |
      | 'circulation.requests.item.get'                             |
      | 'circulation.requests.item.post'                            |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loan-policies.item.post'               |
      | 'circulation-storage.patron-notice-policies.collection.get' |
      | 'circulation-storage.patron-notice-policies.item.post'      |
      | 'circulation-storage.request-policies.collection.get'       |
      | 'circulation-storage.request-policies.item.post'            |
      | 'configuration.entries.collection.get'                      |
      | 'configuration.entries.item.delete'                         |
      | 'configuration.entries.item.get'                            |
      | 'configuration.entries.item.post'                           |
      | 'configuration.entries.item.put'                            |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory-storage.holdings.collection.get'                 |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.instance-statuses.item.post'             |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.service-points.item.post'                |
      | 'inventory.holdings.move.item.post'                         |
      | 'inventory.holdings.update-ownership.item.post'             |
      | 'inventory.instances.item.delete'                           |
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items-by-holdings-id.collection.get'             |
      | 'inventory.items.collection.get'                            |
      | 'inventory.items.item.delete'                               |
      | 'inventory.items.item.get'                                  |
      | 'inventory.items.item.post'                                 |
      | 'inventory.items.move.item.post'                            |
      | 'inventory.tenant-items.collection.get'                     |
      | 'lost-item-fees-policies.collection.get'                    |
      | 'lost-item-fees-policies.item.post'                         |
      | 'overdue-fines-policies.collection.get'                     |
      | 'overdue-fines-policies.item.post'                          |
      | 'perms.users.get'                                           |
      | 'perms.users.item.put'                                      |
      | 'user-tenants.collection.get'                               |
      | 'usergroups.item.post'                                      |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'users.item.put'                                            |
      | 'users.collection.get'                                      |
      | 'patron.account.instance-batch-request.item.post'           |
      | 'patron.account.instance-batch-request-status.item.get'     |
      | 'patron.account.item.get'                                   |
      | 'circulation.requests.collection.get'                       |
      | 'circulation-bff.batch-requests.item.post'                  |
      | 'circulation-bff.batch-request.item.get'                    |
      | 'circulation-bff.batch-request.collection.get'              |
      | 'circulation-bff.batch-request.details.collection.get'      |
      | 'search.index.instance-records.reindex.full.post'           |
      | 'circulation.settings.item.post'                            |
      | 'patron.settings.item.post'                                 |

    # load global variables
    * callonce variables
    # load central tenant variables
    * callonce variablesCentral
    # load university tenant variables
    * callonce variablesUniversity
    # create disable instance matching config id for university tenant
    * def isInstanceMatchingDisabledId = callonce uuid

    # generate names for tenants
    * def centralTenant = { id : '#(centralTenantId)', name: '#(centralTenantName)' }
    * def universityTenant = { id : '#(universityTenantId)', name: '#(universityTenantName)' }

    # reusable features
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def postUser = read('classpath:common-consortia/eureka/initData.feature@PostUser')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')
    * def getAuthorizationToken = read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken')
    * def configureAccessTokenTime = read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime')

  Scenario: Create Central and University tenants and Set up Admins
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login-keycloak'        |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-audit'                 |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-feesfines'             |
      | 'mod-consortia-keycloak'    |
      | 'mod-search'                |
      | 'edge-patron'               |
      | 'mod-patron'                |
      | 'mod-tlr'                   |
      | 'mod-circulation'           |
      | 'mod-circulation-bff'       |
      | 'mod-requests-mediated'     |
      | 'mod-dcb'                   |
      | 'mod-record-specifications' |

    * call setupTenant { tenantId: '#(centralTenantId)', tenant: '#(centralTenantName)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenantId: '#(universityTenant.id)', tenant: '#(universityTenantName)', user: '#(universityUser)' }

    * call postUser { tenant: '#(centralTenantName)', user: '#(centralUser)' }
    * call putCaps { tenant: '#(centralTenantName)', user: '#(centralUser)' }

  Scenario: Setup Consortia
    # 1. Create Consortia
    * def result = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * call read('classpath:utils/consortium.feature@SetupConsortia') { token: '#(result.okapitoken)', tenant: '#(centralTenant)' }
    # 2. Add 2 tenants to consortium
    * call read('classpath:utils/tenant.feature') { token: '#(result.okapitoken)', centralTenantName: '#(centralTenantName)', uniTenant: '#(universityTenant)', consortiaAdmin: '#(consortiaAdmin)' }

    # 3. Add permissions to consortia_admin
    # Permissions for shadowConsortiaAdmin (consortia_admin in university tenant)
    * table userPermissions
      | name                                                        |
      | 'circulation.requests.item.get'                             |
      | 'circulation.requests.item.post'                            |
      | 'circulation.rules.get'                                     |
      | 'circulation.rules.put'                                     |
      | 'circulation-storage.circulation-rules.get'                 |
      | 'circulation-storage.circulation-rules.put'                 |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loan-policies.item.post'               |
      | 'circulation-storage.patron-notice-policies.collection.get' |
      | 'circulation-storage.patron-notice-policies.item.post'      |
      | 'circulation-storage.request-policies.collection.get'       |
      | 'circulation-storage.request-policies.item.post'            |
      | 'configuration.entries.collection.get'                      |
      | 'configuration.entries.item.get'                            |
      | 'configuration.entries.item.post'                           |
      | 'configuration.entries.item.put'                            |
      | 'consortia.sharing-instances.collection.get'                |
      | 'consortia.sharing-instances.item.post'                     |
      | 'inventory.holdings.update-ownership.item.post'             |
      | 'inventory.instances.item.delete'                           |
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items-by-holdings-id.collection.get'             |
      | 'inventory.items.collection.get'                            |
      | 'inventory.items.item.delete'                               |
      | 'inventory.items.item.post'                                 |
      | 'inventory-storage.holdings.collection.get'                 |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory-storage.hrid-settings.item.get'                  |
      | 'inventory-storage.hrid-settings.item.put'                  |
      | 'inventory-storage.instance-statuses.item.post'             |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.service-points.item.post'                |
      | 'lost-item-fees-policies.collection.get'                    |
      | 'lost-item-fees-policies.item.post'                         |
      | 'overdue-fines-policies.collection.get'                     |
      | 'overdue-fines-policies.item.post'                          |
      | 'usergroups.item.post'                                      |
      | 'circulation.settings.item.post'                            |
      | 'patron.settings.item.post'                                 |

    * def shadowConsortiaAdmin = { id: '#(centralAdminId)', tenant: '#(universityTenantName)' }
    * configure cookies = null
    * call putCaps { tenant: '#(universityTenantName)', user: '#(shadowConsortiaAdmin)' }

  Scenario: Prepare data
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }

    # Evict mod-search stale USER_TENANTS_CACHE (populated during @InstallApplications before consortium setup)
    # BEFORE creating items. This ensures Kafka events from inventory creation are processed with a fresh
    # central-tenant lookup, so university tenant items are indexed in the central OpenSearch index
    # (not in the university's own index).
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    When method POST
    Then status 200

    * call read('classpath:utils/inventory.feature')
    * call read('classpath:utils/inventory-university.feature')

    # Share university instance to central tenant to enable mod-search consortium item search indexing.
    # Headers must use universityTenantName so the final source='CONSORTIUM-FOLIO' check runs in the source tenant.
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json, text/plain' }
    * configure retry = { count: 30, interval: 5000 }
    * call read('classpath:reusable/shareInstance.feature') { instanceId: '#(universityInstanceId)', sourceTenantId: '#(universityTenantName)', targetTenantId: '#(centralTenantName)', consortiumId: '#(consortiumId)' }

    * call read('classpath:utils/configuration.feature')
    * call karate.read('classpath:reusable/createLoanPolicies.feature')

    # Setup circulation policies and rules for university tenant
    # Required for mod-tlr secondary request creation (Page/Recall/Hold in university tenant).
    * call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json, text/plain' }

    * call karate.read('classpath:reusable/createLoanPolicies.feature')

    # Create patron group in central tenant
    * def ecsPatronGroupId = 'ac34d2dc-0010-1111-bbbb-6f7264657273'
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    Given path 'groups'
    And request { "id": "#(ecsPatronGroupId)", "group": "ecs-patron", "desc": "ECS patron group for consortium requests" }
    When method POST
    * print 'POST groups central status:', responseStatus
    * if (responseStatus != 201 && responseStatus != 422) karate.fail('Unexpected status creating patron group in central tenant: ' + responseStatus)

    # update central user to have the created patron group
    Given path 'users', centralUser.id
    When method GET
    Then status 200
    * def centralUserRecord = response
    * centralUserRecord.patronGroup = ecsPatronGroupId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'text/plain' }
    Given path 'users', centralUser.id
    And request centralUserRecord
    When method PUT
    Then status 204

    # enable title-level requests (TLR) feature
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * def tlrConfig = read('classpath:consortia/samples/tlr-config-entry-request.json')
    Given path 'circulation/settings'
    And request tlrConfig
    When method POST
    Then status 201

    # enable Multi-Item Requesting Feature setting for the patron to get batch request information in the response of patron/account API
    Given path 'patron/settings'
    And request
        """
        {
          "scope": "mod-patron",
          "key": "isMultiItemRequestingFeatureEnabled",
          "value": {
            "enabled": "true"
          }
        }
        """
    When method POST
    Then status 201

    # Create same patron group in university tenant
    * call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    Given path 'groups'
    And request { "id": "#(ecsPatronGroupId)", "group": "ecs-patron", "desc": "ECS patron group for consortium requests" }
    When method POST
    * if (responseStatus != 201 && responseStatus != 422) karate.fail('Unexpected status creating patron group in university tenant: ' + responseStatus)
