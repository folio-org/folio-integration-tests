# FAT-21604, Create Karate tests for ILR and TLR ECS requests via mod-circulation-bff
@parallel=false
Feature: ECS ILR and TLR requests creation via mod-circulation-bff

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-users'                 |
      | 'mod-login'                 |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-consortia'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-circulation-bff'       |
      | 'mod-tlr'                   |
      | 'mod-search'                |

    * table userPermissions
      | name                                                        |
      | 'users.item.post'                                           |
      | 'users.item.get'                                            |
      | 'users.collection.get'                                      |
      | 'usergroups.item.post'                                      |
      | 'inventory-storage.service-points.item.post'                |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.items.item.post'                         |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items.item.post'                                 |
      | 'circulation-storage.circulation-rules.put'                 |
      | 'circulation-storage.loan-policies.item.post'               |
      | 'circulation-storage.patron-notice-policies.item.post'      |
      | 'circulation-storage.request-policies.item.post'            |
      | 'lost-item-fees-policies.item.post'                         |
      | 'overdue-fines-policies.item.post'                          |
      | 'circulation.settings.item.post'                            |
      | 'tlr.settings.put'                                          |
      | 'consortia.sharing-instances.item.post'                     |
      | 'consortia.sharing-instances.collection.get'                |
      | 'user-tenants.collection.get'                               |
      | 'consortia.user-tenants.collection.get'                     |
      | 'consortia.user-tenants.item.post'                          |
      | 'circulation-bff.requests.allowed-service-points.get'       |
      | 'circulation-bff.requests.post'                             |
      | 'circulation.requests.item.post'                            |
      | 'search.index.instance-records.reindex.full.post'           |

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def setupConsortium = read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia')
    * def setupTenantForConsortia = read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')

    # Fixed UUIDs for inventory entities shared across scenarios
    * callonce read('classpath:vega/ecs-requests/ecs-requests-variables.feature')

    * def centralTenantUuid = centralTenantId.length == 36 ? centralTenantId : karate.get('centralTenantUuid')
    * eval karate.set('centralTenantUuid', centralTenantUuid)
    * eval karate.set('centralTenantId', centralTenant)

  Scenario: create and initialize central and university tenants
    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantUuid)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)' }

  Scenario: create consortium and register central and university tenants
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * call setupConsortium { tenant: '#(centralTenant)' }
    * call setupTenantForConsortia { tenant: '#(centralTenant)', id: '#(centralTenantId)', isCentral: true, code: 'CON' }
    * call setupTenantForConsortia { tenant: '#(universityTenant)', id: '#(universityTenantId)', isCentral: false, code: 'UNI' }

    * table userPermissions
      | name                                              |
      | 'circulation.requests.item.post'                  |
      | 'circulation.requests.item.get'                   |
      | 'circulation-bff.requests.allowed-service-points.get' |
      | 'circulation-bff.requests.post'                   |
      | 'inventory.instances.item.get'                    |
      | 'inventory.items.item.get'                        |
      | 'inventory-storage.holdings.item.get'             |
      | 'user-tenants.collection.get'                     |
      | 'consortia.user-tenants.collection.get'           |
      | 'consortia.user-tenants.item.post'                |
      | 'consortia.sharing-instances.item.post'           |
      | 'consortia.sharing-instances.collection.get'      |

    * def shadowConsortiaAdmin = { id: '#(consortiaAdmin.id)', tenant: '#(universityTenant)' }
    * configure cookies = null
    * call putCaps { tenant: '#(universityTenant)', user: '#(shadowConsortiaAdmin)' }

    # Re-login as consortia_admin to restore the central tenant okapitoken
    # (putCaps calls getAuthorizationToken for universityTenant, overwriting okapitoken)
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Wait for consortium registration to propagate through Kafka (mod-search creates consortium index asynchronously)
    * configure retry = { count: 20, interval: 30000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    Given path 'user-tenants'
    And param tenantId = centralTenant
    And retry until responseStatus == 200
    When method GET
    Then status 200
    * print 'DEBUG: consortium propagated, user-tenants response:', response

  Scenario: initialize mod-search indices for central tenant
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    When method POST
    Then status 200
    * print 'DEBUG: mod-search reindex triggered for central tenant'

  Scenario: setup inventory data in central tenant
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralLogin.okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(ecsInstitutionId)', name: 'ECS Test Institution Central', code: 'ECSI-C' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(ecsCampusId)', name: 'ECS Test Campus Central', code: 'ECSC-C', institutionId: '#(ecsInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(ecsLibraryId)', name: 'ECS Test Library Central', code: 'ECSL-C', campusId: '#(ecsCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(ecsServicePointId)', name: 'ECS Central Service Point', code: 'ECS-SP-C', discoveryDisplayName: 'ECS Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    Given path 'instance-types'
    And request { id: '#(ecsInstanceTypeId)', name: 'ECS Instance Type Central', code: 'ECSI-CT', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(ecsLoanTypeId)', name: 'ECS Loan Type Central' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(ecsMaterialTypeId)', name: 'ECS Material Type Central' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(ecsHoldingsSourceId)', name: 'ECS FOLIO Central' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(ecsLocationId)",
        "name": "ECS Central Location",
        "code": "ECS-LOC-C",
        "institutionId": "#(ecsInstitutionId)",
        "campusId": "#(ecsCampusId)",
        "libraryId": "#(ecsLibraryId)",
        "primaryServicePoint": "#(ecsServicePointId)",
        "servicePointIds": ["#(ecsServicePointId)"]
      }
      """
    When method POST
    Then status 201

  Scenario: setup inventory data in university tenant
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(uniInstitutionId)', name: 'ECS Test Institution University', code: 'ECSI-U' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(uniCampusId)', name: 'ECS Test Campus University', code: 'ECSC-U', institutionId: '#(uniInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(uniLibraryId)', name: 'ECS Test Library University', code: 'ECSL-U', campusId: '#(uniCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(uniServicePointId)', name: 'ECS University Service Point', code: 'ECS-SP-U', discoveryDisplayName: 'ECS University Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    Given path 'instance-types'
    And request { id: '#(uniInstanceTypeId)', name: 'ECS Instance Type University', code: 'ECSI-UT', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(uniLoanTypeId)', name: 'ECS Loan Type University' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(uniMaterialTypeId)', name: 'ECS Material Type University' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(uniHoldingsSourceId)', name: 'ECS FOLIO University' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(uniLocationId)",
        "name": "ECS University Location",
        "code": "ECS-LOC-U",
        "institutionId": "#(uniInstitutionId)",
        "campusId": "#(uniCampusId)",
        "libraryId": "#(uniLibraryId)",
        "primaryServicePoint": "#(ecsServicePointId)",
        "servicePointIds": ["#(ecsServicePointId)", "#(uniServicePointId)"]
      }
      """
    When method POST
    Then status 201

  Scenario: setup circulation policies and enable ECS TLR
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Enable ECS TLR feature at consortium level
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    Given path 'tlr/settings'
    And request { "ecsTlrFeatureEnabled": true, "excludeFromEcsRequestLendingTenantSearch": [] }
    When method PUT
    Then status 204

    # Central tenant circulation policies
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def centralLoanPolicyId = uuid()
    Given path 'loan-policy-storage/loan-policies'
    And request
      """
      {
        "id": "#(centralLoanPolicyId)",
        "name": "ECS Loan Policy Central",
        "loanable": true,
        "loansPolicy": {
          "profileId": "Rolling",
          "period": { "duration": 1, "intervalId": "Months" },
          "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE"
        },
        "renewable": true,
        "renewalsPolicy": {
          "unlimited": false,
          "numberAllowed": 3,
          "renewFromId": "CURRENT_DUE_DATE",
          "differentPeriod": false
        }
      }
      """
    When method POST
    Then status 201

    * def centralLostItemFeePolicyId = uuid()
    Given path 'lost-item-fees-policies'
    And request
      """
      {
        "id": "#(centralLostItemFeePolicyId)",
        "name": "ECS Lost Item Fee Policy Central",
        "itemAgedLostOverdue": { "duration": 1, "intervalId": "Months" },
        "patronBilledAfterAgedLost": { "duration": 1, "intervalId": "Months" },
        "lostItemChargeFeeFine": { "duration": 6, "intervalId": "Months" },
        "chargeAmountItem": { "amount": 0.00, "chargeType": "actualCost" },
        "lostItemProcessingFee": 0.00,
        "chargeAmountItemPatron": true,
        "chargeAmountItemSystem": true,
        "lostItemReturned": "Charge",
        "replacedLostItemProcessingFee": true,
        "replacementProcessingFee": 0.00,
        "replacementAllowed": true
      }
      """
    When method POST
    Then status 201

    * def centralOverdueFinePolicyId = uuid()
    Given path 'overdue-fines-policies'
    And request
      """
      {
        "id": "#(centralOverdueFinePolicyId)",
        "name": "ECS Overdue Fine Policy Central",
        "overdueFine": { "quantity": 0.00, "intervalId": "hour" },
        "overdueRecallFine": { "quantity": 0.00, "intervalId": "hour" },
        "gracePeriodRecall": false,
        "maxOverdueFine": 0.00,
        "forgiveOverdueFine": false,
        "maxOverdueRecallFine": 0.00
      }
      """
    When method POST
    Then status 201

    * def centralPatronNoticePolicyId = uuid()
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request
      """
      {
        "id": "#(centralPatronNoticePolicyId)",
        "name": "ECS Patron Notice Policy Central",
        "active": false,
        "loanNotices": [],
        "feeFineNotices": [],
        "requestNotices": []
      }
      """
    When method POST
    Then status 201

    * def centralRequestPolicyId = uuid()
    Given path 'request-policy-storage/request-policies'
    And request
      """
      {
        "id": "#(centralRequestPolicyId)",
        "name": "ECS Request Policy Central",
        "requestTypes": ["Hold", "Page", "Recall"]
      }
      """
    When method POST
    Then status 201

    * def centralRules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + centralLoanPolicyId + ' o ' + centralOverdueFinePolicyId + ' i ' + centralLostItemFeePolicyId + ' r ' + centralRequestPolicyId + ' n ' + centralPatronNoticePolicyId
    Given path 'circulation-rules-storage'
    And request { "rulesAsText": "#(centralRules)" }
    When method PUT
    Then status 204

    # Enable TLR for central tenant
    * def centralTlrSettingsId = uuid()
    Given path 'circulation/settings'
    And request { id: '#(centralTlrSettingsId)', name: 'TLR', value: { titleLevelRequestsFeatureEnabled: true, tlrHoldShouldFollowCirculationRules: false, createTitleLevelRequestsByDefault: false } }
    When method POST
    Then match [201, 422] contains responseStatus

    # University tenant circulation policies
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    * def uniLoanPolicyId = uuid()
    Given path 'loan-policy-storage/loan-policies'
    And request
      """
      {
        "id": "#(uniLoanPolicyId)",
        "name": "ECS Loan Policy University",
        "loanable": true,
        "loansPolicy": {
          "profileId": "Rolling",
          "period": { "duration": 1, "intervalId": "Months" },
          "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE"
        },
        "renewable": true,
        "renewalsPolicy": {
          "unlimited": false,
          "numberAllowed": 3,
          "renewFromId": "CURRENT_DUE_DATE",
          "differentPeriod": false
        }
      }
      """
    When method POST
    Then status 201

    * def uniLostItemFeePolicyId = uuid()
    Given path 'lost-item-fees-policies'
    And request
      """
      {
        "id": "#(uniLostItemFeePolicyId)",
        "name": "ECS Lost Item Fee Policy University",
        "itemAgedLostOverdue": { "duration": 1, "intervalId": "Months" },
        "patronBilledAfterAgedLost": { "duration": 1, "intervalId": "Months" },
        "lostItemChargeFeeFine": { "duration": 6, "intervalId": "Months" },
        "chargeAmountItem": { "amount": 0.00, "chargeType": "actualCost" },
        "lostItemProcessingFee": 0.00,
        "chargeAmountItemPatron": true,
        "chargeAmountItemSystem": true,
        "lostItemReturned": "Charge",
        "replacedLostItemProcessingFee": true,
        "replacementProcessingFee": 0.00,
        "replacementAllowed": true
      }
      """
    When method POST
    Then status 201

    * def uniOverdueFinePolicyId = uuid()
    Given path 'overdue-fines-policies'
    And request
      """
      {
        "id": "#(uniOverdueFinePolicyId)",
        "name": "ECS Overdue Fine Policy University",
        "overdueFine": { "quantity": 0.00, "intervalId": "hour" },
        "overdueRecallFine": { "quantity": 0.00, "intervalId": "hour" },
        "gracePeriodRecall": false,
        "maxOverdueFine": 0.00,
        "forgiveOverdueFine": false,
        "maxOverdueRecallFine": 0.00
      }
      """
    When method POST
    Then status 201

    * def uniPatronNoticePolicyId = uuid()
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request
      """
      {
        "id": "#(uniPatronNoticePolicyId)",
        "name": "ECS Patron Notice Policy University",
        "active": false,
        "loanNotices": [],
        "feeFineNotices": [],
        "requestNotices": []
      }
      """
    When method POST
    Then status 201

    * def uniRequestPolicyId = uuid()
    Given path 'request-policy-storage/request-policies'
    And request
      """
      {
        "id": "#(uniRequestPolicyId)",
        "name": "ECS Request Policy University",
        "requestTypes": ["Hold", "Page", "Recall"]
      }
      """
    When method POST
    Then status 201

    * def uniRules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + uniLoanPolicyId + ' o ' + uniOverdueFinePolicyId + ' i ' + uniLostItemFeePolicyId + ' r ' + uniRequestPolicyId + ' n ' + uniPatronNoticePolicyId
    Given path 'circulation-rules-storage'
    And request { "rulesAsText": "#(uniRules)" }
    When method PUT
    Then status 204

    # Enable TLR for university tenant
    * def uniTlrSettingsId = uuid()
    Given path 'circulation/settings'
    And request { id: '#(uniTlrSettingsId)', name: 'TLR', value: { titleLevelRequestsFeatureEnabled: true, tlrHoldShouldFollowCirculationRules: false, createTitleLevelRequestsByDefault: false } }
    When method POST
    Then match [201, 422] contains responseStatus

  Scenario: create ILR ECS request via mod-circulation-bff
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def headersCentralConsortium = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }

    # Create user group and user in central tenant
    * configure headers = headersCentral
    * def ilrGroupId = uuid()
    * def ilrGroup = 'ecs-ilr-grp-' + randomMillis()
    Given path 'groups'
    And request { id: '#(ilrGroupId)', group: '#(ilrGroup)', desc: 'ECS ILR test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def ilrUserId = uuid()
    * def ilrBarcode = 'ECS-ILR-' + randomMillis()
    * def ilrUsername = ilrBarcode
    Given path 'users'
    And request
      """
      {
        "id": "#(ilrUserId)",
        "username": "#(ilrUsername)",
        "barcode": "#(ilrBarcode)",
        "active": true,
        "type": "patron",
        "patronGroup": "#(ilrGroupId)",
        "personal": {
          "lastName": "ECSTest",
          "firstName": "ILRUser",
          "email": "ecs-ilr@test.com",
          "preferredContactTypeId": "002",
          "addresses": []
        },
        "departments": [],
        "expirationDate": "2028-12-31T23:59:59.000+00:00"
      }
      """
    When method POST
    Then status 201

    # Retrieve created user for building the requester object
    Given path 'users', ilrUserId
    When method GET
    Then status 200
    * def ilrRequester = response

    # Switch to university tenant for instance/holding/item creation
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    * configure headers = headersUniversity

    # Create instance in university tenant
    * def ilrInstanceId = uuid()
    * def ilrInstanceHrid = 'in' + randomMillis()
    Given path 'inventory/instances'
    And request
      """
      {
        "id": "#(ilrInstanceId)",
        "title": "ECS ILR Test Instance",
        "instanceTypeId": "#(uniInstanceTypeId)",
        "source": "FOLIO",
        "hrid": "#(ilrInstanceHrid)"
      }
      """
    When method POST
    Then status 201

    # Share instance from university to central tenant
    * def ilrSharingId = uuid()
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        "id": "#(ilrSharingId)",
        "instanceIdentifier": "#(ilrInstanceId)",
        "sourceTenantId": "#(universityTenant)",
        "targetTenantId": "#(centralTenant)"
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == ilrInstanceId

    # Wait for sharing to complete
    * configure retry = { count: 20, interval: 30000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = ilrInstanceId
    And param sourceTenantId = universityTenant
    And retry until response.sharingInstances && response.sharingInstances.length > 0 && (response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR')
    When method GET
    Then status 200
    And match response.sharingInstances[0].status == 'COMPLETE'
    * print 'DEBUG: instance sharing completed for ILR scenario'

    # Wait for Kafka to fully propagate source change (edge-patron pattern: sleep + verify CONSORTIUM-FOLIO)
    * java.lang.Thread.sleep(5000)
    * configure headers = headersUniversity
    Given path 'inventory/instances', ilrInstanceId
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-FOLIO'
    * print 'DEBUG: ILR instance source confirmed as CONSORTIUM-FOLIO'

    # Create holding in university tenant
    * def ilrHoldingId = uuid()
    Given path 'holdings-storage/holdings'
    And request
      """
      {
        "id": "#(ilrHoldingId)",
        "instanceId": "#(ilrInstanceId)",
        "permanentLocationId": "#(uniLocationId)",
        "sourceId": "#(uniHoldingsSourceId)"
      }
      """
    When method POST
    Then status 201

    # Create item in university tenant
    * def ilrItemId = uuid()
    * def ilrItemBarcode = 'ECS-ILR-ITEM-' + randomMillis()
    Given path 'inventory/items'
    And request
      """
      {
        "id": "#(ilrItemId)",
        "holdingsRecordId": "#(ilrHoldingId)",
        "barcode": "#(ilrItemBarcode)",
        "status": { "name": "Available" },
        "materialType": { "id": "#(uniMaterialTypeId)" },
        "permanentLoanType": { "id": "#(uniLoanTypeId)" },
        "permanentLocation": { "id": "#(uniLocationId)" }
      }
      """
    When method POST
    Then status 201

    * configure headers = headersCentral
    * configure retry = { count: 20, interval: 15000 }
    Given path 'circulation-bff/requests/allowed-service-points'
    And param requesterId = ilrUserId
    And param operation = 'create'
    And param itemId = ilrItemId
    And retry until responseStatus == 200 && response && karate.sizeOf(response) > 0
    When method GET
    * print 'DEBUG: ILR allowed-service-points response:', response
    Then status 200
    * def allowedServicePoints = response

    * def allSpIds = []
    * def collectIds = function(arr) { arr.forEach(function(sp){ allSpIds.push(sp.id) }) }
    * if (allowedServicePoints.Page) collectIds(allowedServicePoints.Page)
    * if (allowedServicePoints.Hold) collectIds(allowedServicePoints.Hold)
    * if (allowedServicePoints.Recall) collectIds(allowedServicePoints.Recall)
    * if (!allSpIds.includes(ecsServicePointId)) karate.fail('ILR: ecsServicePointId (' + ecsServicePointId + ') not found in allowedServicePoints: ' + karate.toJson(allowedServicePoints))
    * print 'DEBUG: ILR ecsServicePointId confirmed in allowedServicePoints'

    # Create ILR ECS request via mod-circulation-bff
    * def ilrRequestId = uuid()
    * def ilrRequestDate = java.time.Instant.now().toString()
    Given path 'circulation-bff/requests'
    And headers headersCentralConsortium
    And request
      """
      {
        "id": "#(ilrRequestId)",
        "requestType": "Page",
        "requestLevel": "Item",
        "requestDate": "#(ilrRequestDate)",
        "fulfillmentPreference": "Hold Shelf",
        "instanceId": "#(ilrInstanceId)",
        "holdingsRecordId": "#(ilrHoldingId)",
        "itemId": "#(ilrItemId)",
        "item": { "barcode": "#(ilrItemBarcode)" },
        "requesterId": "#(ilrUserId)",
        "requester": "#(ilrRequester)",
        "pickupServicePointId": "#(ecsServicePointId)"
      }
      """
    When method POST
    Then status 201
    * print 'DEBUG: ILR ECS request response:', response
    And match response.requestLevel == 'Item'
    And match response.itemId == ilrItemId
    And match response.instanceId == ilrInstanceId
    And match response.requesterId == ilrUserId
    And match response.pickupServicePointId == ecsServicePointId
    And match response.status == 'Open - Not yet filled'

  Scenario: create TLR ECS request via mod-circulation-bff
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def headersCentralConsortium = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }

    # Create user group and user in central tenant
    * configure headers = headersCentral
    * def tlrGroupId = uuid()
    * def tlrGroup = 'ecs-tlr-grp-' + randomMillis()
    Given path 'groups'
    And request { id: '#(tlrGroupId)', group: '#(tlrGroup)', desc: 'ECS TLR test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def tlrUserId = uuid()
    * def tlrBarcode = 'ECS-TLR-' + randomMillis()
    * def tlrUsername = tlrBarcode
    Given path 'users'
    And request
      """
      {
        "id": "#(tlrUserId)",
        "username": "#(tlrUsername)",
        "barcode": "#(tlrBarcode)",
        "active": true,
        "type": "patron",
        "patronGroup": "#(tlrGroupId)",
        "personal": {
          "lastName": "ECSTest",
          "firstName": "TLRUser",
          "email": "ecs-tlr@test.com",
          "preferredContactTypeId": "002",
          "addresses": []
        },
        "departments": [],
        "expirationDate": "2028-12-31T23:59:59.000+00:00"
      }
      """
    When method POST
    Then status 201

    # Retrieve created user for building the requester object
    Given path 'users', tlrUserId
    When method GET
    Then status 200
    * def tlrRequester = response

    # Switch to university tenant for instance/holding/item creation
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def headersUniversity = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    * configure headers = headersUniversity

    # Create instance in university tenant
    * def tlrInstanceId = uuid()
    * def tlrInstanceHrid = 'in' + randomMillis()
    Given path 'inventory/instances'
    And request
      """
      {
        "id": "#(tlrInstanceId)",
        "title": "ECS TLR Test Instance",
        "instanceTypeId": "#(uniInstanceTypeId)",
        "source": "FOLIO",
        "hrid": "#(tlrInstanceHrid)"
      }
      """
    When method POST
    Then status 201

    # Share instance from university to central tenant
    * def tlrSharingId = uuid()
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        "id": "#(tlrSharingId)",
        "instanceIdentifier": "#(tlrInstanceId)",
        "sourceTenantId": "#(universityTenant)",
        "targetTenantId": "#(centralTenant)"
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == tlrInstanceId

    # Wait for sharing to complete
    * configure retry = { count: 20, interval: 30000 }
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = tlrInstanceId
    And param sourceTenantId = universityTenant
    And retry until response.sharingInstances && response.sharingInstances.length > 0 && (response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR')
    When method GET
    Then status 200
    And match response.sharingInstances[0].status == 'COMPLETE'
    * print 'DEBUG: instance sharing completed for TLR scenario'

    # Wait for Kafka to fully propagate source change (edge-patron pattern: sleep + verify CONSORTIUM-FOLIO)
    * java.lang.Thread.sleep(5000)
    * configure headers = headersUniversity
    Given path 'inventory/instances', tlrInstanceId
    When method GET
    Then status 200
    And match response.source == 'CONSORTIUM-FOLIO'
    * print 'DEBUG: TLR instance source confirmed as CONSORTIUM-FOLIO'

    # Create holding in university tenant
    * def tlrHoldingId = uuid()
    Given path 'holdings-storage/holdings'
    And request
      """
      {
        "id": "#(tlrHoldingId)",
        "instanceId": "#(tlrInstanceId)",
        "permanentLocationId": "#(uniLocationId)",
        "sourceId": "#(uniHoldingsSourceId)"
      }
      """
    When method POST
    Then status 201

    # Create item in university tenant
    * def tlrItemId = uuid()
    * def tlrItemBarcode = 'ECS-TLR-ITEM-' + randomMillis()
    Given path 'inventory/items'
    And request
      """
      {
        "id": "#(tlrItemId)",
        "holdingsRecordId": "#(tlrHoldingId)",
        "barcode": "#(tlrItemBarcode)",
        "status": { "name": "Available" },
        "materialType": { "id": "#(uniMaterialTypeId)" },
        "permanentLoanType": { "id": "#(uniLoanTypeId)" },
        "permanentLocation": { "id": "#(uniLocationId)" }
      }
      """
    When method POST
    Then status 201

    # Wait for mod-search to index the instance (retry via circulation-bff allowed-service-points using instanceId)
    * configure headers = headersCentral
    * configure retry = { count: 20, interval: 15000 }
    Given path 'circulation-bff/requests/allowed-service-points'
    And param requesterId = tlrUserId
    And param operation = 'create'
    And param instanceId = tlrInstanceId
    And retry until responseStatus == 200 && response && karate.sizeOf(response) > 0
    When method GET
    * print 'DEBUG: TLR allowed-service-points response:', response
    Then status 200
    * def allowedServicePoints = response

    # Verify the ECS central service point is among allowed ones (response is a map by request type)
    * def allSpIds = []
    * def collectIds = function(arr) { arr.forEach(function(sp){ allSpIds.push(sp.id) }) }
    * if (allowedServicePoints.Page) collectIds(allowedServicePoints.Page)
    * if (allowedServicePoints.Hold) collectIds(allowedServicePoints.Hold)
    * if (allowedServicePoints.Recall) collectIds(allowedServicePoints.Recall)
    * if (!allSpIds.includes(ecsServicePointId)) karate.fail('TLR: ecsServicePointId (' + ecsServicePointId + ') not found in allowedServicePoints: ' + karate.toJson(allowedServicePoints))
    * print 'DEBUG: TLR ecsServicePointId confirmed in allowedServicePoints'

    # Create TLR ECS request via mod-circulation-bff
    * def tlrRequestId = uuid()
    * def tlrRequestDate = java.time.Instant.now().toString()
    Given path 'circulation-bff/requests'
    And headers headersCentralConsortium
    And request
      """
      {
        "id": "#(tlrRequestId)",
        "requestType": "Page",
        "requestLevel": "Title",
        "requestDate": "#(tlrRequestDate)",
        "fulfillmentPreference": "Hold Shelf",
        "instanceId": "#(tlrInstanceId)",
        "requesterId": "#(tlrUserId)",
        "requester": "#(tlrRequester)",
        "pickupServicePointId": "#(ecsServicePointId)"
      }
      """
    When method POST
    Then status 201
    * print 'DEBUG: TLR ECS request response:', response
    And match response.requestLevel == 'Title'
    And match response.instanceId == tlrInstanceId
    And match response.requesterId == tlrUserId
    And match response.pickupServicePointId == ecsServicePointId
    And match response.status == 'Open - Not yet filled'
