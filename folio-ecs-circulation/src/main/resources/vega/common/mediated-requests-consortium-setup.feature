@ignore
Feature: Common mediated-requests setup (inventory, circulation policies, shadow-user capabilities)

  # Adds the mediated-request-specific data on top of the shared consortium.
  # The university tenant acts as the "secure" tenant where mediated requests are created.
  #
  # The central/university/college tenants and the consortium itself are NOT created here - they
  # are created once per build by vega/common/consortium-bootstrap.feature, invoked from
  # FolioEcsCirculationTests#bootstrapConsortium (@Order(0)). Everything this feature does is
  # additive against already-initialised tenants.
  #
  # DO NOT reintroduce setupTenant or DeleteTenantAndEntitlement here. Every feature in this
  # module shares one tenant name-space, so a delete/recreate cycle in this file destroys the
  # tenants the other features are using (and, with the mediated workflow running for tens of
  # minutes, can destroy them mid-flight).

  Background:
    * url baseUrl
    * configure readTimeout = 600000

  Scenario: setup mediated-request inventory, policies and shadow-user capabilities
    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupCirculationPolicies = read('classpath:vega/ecs-requests/ecs-circulation-policies.feature')

    # Fixed UUIDs for inventory entities
    * callonce read('classpath:vega/mediated-requests/mediated-requests-variables.feature')

    # Modules required by the mediated-request suite. Kept for documentation only - tenant
    # entitlement happens in consortium-bootstrap.feature, whose module list is the union of
    # every suite's requirements and must be updated if this list grows.
    * table baseModules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-users'                 |
      | 'mod-login-keycloak'        |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-consortia'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-tlr'                   |
      | 'mod-search'                |
      | 'mod-requests-mediated'     |

    # Likewise: the local-admin permissions this suite needs, granted by consortium-bootstrap.
    * table baseUserPermissions
      | name                                                        |
      | 'users.item.post'                                           |
      | 'users.item.get'                                            |
      | 'usergroups.item.post'                                      |
      | 'inventory-storage.service-points.item.post'                |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.items.item.post'                         |
      | 'inventory-storage.items.collection.get'                    |
      | 'inventory-storage.items.item.get'                          |
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
      | 'circulation-storage.request-policies.item.post'            |
      | 'circulation-storage.requests.collection.get'               |
      | 'circulation-storage.requests.item.get'                     |
      | 'circulation-item.item.get'                                 |
      | 'circulation.check-in-by-barcode.post'                      |
      | 'lost-item-fees-policies.item.post'                         |
      | 'overdue-fines-policies.item.post'                          |
      | 'circulation.settings.item.post'                            |
      | 'tlr.settings.put'                                          |
      | 'consortia.sharing-instances.item.post'                     |
      | 'consortia.sharing-instances.collection.get'                |
      | 'user-tenants.collection.get'                               |
      | 'consortia.user-tenants.collection.get'                     |
      | 'consortia.user-tenants.item.post'                          |
      | 'search.index.instance-records.reindex.full.post'           |
      | 'requests-mediated.mediated-request.item.post'              |
      | 'requests-mediated.mediated-request.item.get'               |
      | 'requests-mediated.mediated-requests.decline.execute'       |
      | 'requests-mediated.mediated-request.confirm.post'           |
      | 'requests-mediated.confirm-item-arrival.post'               |
      | 'requests-mediated.send-item-in-transit.post'               |

    * def modules = baseModules
    * def userPermissions = baseUserPermissions

    # ========== Step 1: Confirm the shared consortium is ready ==========
    # Tenants and consortium registration are done by consortium-bootstrap.feature. Fail fast and
    # clearly here if that did not happen, instead of erroring deep inside the workflow.
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * configure retry = { count: 10, interval: 10000 }
    Given path 'consortia', consortiumId, 'tenants'
    And retry until responseStatus == 200 && response.totalRecords == 3
    When method GET
    Then status 200
    And match response.tenants[*].id contains centralTenant
    And match response.tenants[*].id contains universityTenant
    And match response.tenants[*].id contains collegeTenant

    # ========== Step 2: Shadow-user capabilities - NOT granted here ==========
    # Listed for documentation only. The shadow consortia_admin capabilities for the university and
    # college tenants are granted once per build by consortium-bootstrap.feature, whose
    # shadowPermissions table is the union of every suite's requirements and must be updated if this
    # list grows.
    #
    # DO NOT call putCaps from this file. PutCaps issues a plain POST /users/capabilities, which is
    # not idempotent - mod-roles-keycloak returns 400 EntityExistsException if any capability in the
    # payload is already assigned. This suite runs at @Order 1, so granting here left the first four
    # entries below already assigned by the time ecs-consortium-setup.feature (callonce'd by both
    # staff-slips and ecs-requests, hence run twice) re-POSTed a superset of them, failing both of
    # those suites in setup on
    #     "Relation already exists for user=... and capabilities=[...]"
    * table shadowPermissionsUniversityAndCollege
      | name                                            |
      | 'inventory.instances.item.get'                  |
      | 'inventory.items.item.get'                      |
      | 'inventory-storage.holdings.item.get'           |
      | 'user-tenants.collection.get'                   |
      | 'requests-mediated.mediated-request.item.post'  |
      | 'requests-mediated.mediated-request.item.get'   |

    # Re-login as consortia_admin to restore the central tenant okapitoken
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Wait for consortium registration to propagate through Kafka
    * configure retry = { count: 20, interval: 30000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    Given path 'user-tenants'
    And param tenantId = centralTenant
    And retry until responseStatus == 200
    When method GET
    Then status 200

    # ========== Step 3: Initialize mod-search indices ==========
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    When method POST
    Then status 200

    # ========== Step 4: Setup inventory data in central tenant ==========
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(mrCentralInstitutionId)', name: 'MR Test Institution Central', code: 'MRI-C' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(mrCentralCampusId)', name: 'MR Test Campus Central', code: 'MRC-C', institutionId: '#(mrCentralInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(mrCentralLibraryId)', name: 'MR Test Library Central', code: 'MRL-C', campusId: '#(mrCentralCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(mrCentralServicePointId)', name: 'MR Central Service Point', code: 'MR-SP-C', discoveryDisplayName: 'MR Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    Given path 'instance-types'
    And request { id: '#(mrInstanceTypeId)', name: 'MR Instance Type', code: 'MRI-T', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(mrLoanTypeId)', name: 'MR Loan Type' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(mrMaterialTypeId)', name: 'MR Material Type' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(mrCentralHoldingsSourceId)', name: 'MR FOLIO Central' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(mrCentralLocationId)",
        "name": "MR Central Location",
        "code": "MR-LOC-C",
        "institutionId": "#(mrCentralInstitutionId)",
        "campusId": "#(mrCentralCampusId)",
        "libraryId": "#(mrCentralLibraryId)",
        "primaryServicePoint": "#(mrCentralServicePointId)",
        "servicePointIds": ["#(mrCentralServicePointId)"]
      }
      """
    When method POST
    Then status 201

    # ========== Step 5: Setup inventory data in university (secure) tenant ==========
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(mrUniInstitutionId)', name: 'MR Test Institution University', code: 'MRI-U' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(mrUniCampusId)', name: 'MR Test Campus University', code: 'MRC-U', institutionId: '#(mrUniInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(mrUniLibraryId)', name: 'MR Test Library University', code: 'MRL-U', campusId: '#(mrUniCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(mrUniServicePointId)', name: 'MR University Service Point', code: 'MR-SP-U', discoveryDisplayName: 'MR University Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    # Also create the central service point in the university tenant for pickup availability
    Given path 'service-points'
    And request { id: '#(mrCentralServicePointId)', name: 'MR Central Service Point', code: 'MR-SP-C', discoveryDisplayName: 'MR Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then match [201, 422] contains responseStatus

    # Create the interim service point in the university (secure) tenant. mod-requests-mediated uses
    # this hardcoded service point as the pickup service point when confirming a mediated request,
    # and mod-tlr looks it up in the primary (university) tenant to clone it into the lending tenants.
    Given path 'service-points'
    And request { id: '#(mrInterimServicePointId)', name: 'MR Interim Service Point', code: 'MR-SP-INT', discoveryDisplayName: 'MR Interim Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'instance-types'
    And request { id: '#(mrInstanceTypeId)', name: 'MR Instance Type', code: 'MRI-T', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(mrLoanTypeId)', name: 'MR Loan Type' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(mrMaterialTypeId)', name: 'MR Material Type' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(mrUniHoldingsSourceId)', name: 'MR FOLIO University' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(mrUniLocationId)",
        "name": "MR University Location",
        "code": "MR-LOC-U",
        "institutionId": "#(mrUniInstitutionId)",
        "campusId": "#(mrUniCampusId)",
        "libraryId": "#(mrUniLibraryId)",
        "primaryServicePoint": "#(mrCentralServicePointId)",
        "servicePointIds": ["#(mrCentralServicePointId)", "#(mrUniServicePointId)"]
      }
      """
    When method POST
    Then status 201

    # ========== Step 6: Setup inventory data in college tenant ==========
    * def collegeLogin = call eurekaLogin { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeLogin.okapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(mrCollegeInstitutionId)', name: 'MR Test Institution College', code: 'MRI-COL' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(mrCollegeCampusId)', name: 'MR Test Campus College', code: 'MRC-COL', institutionId: '#(mrCollegeInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(mrCollegeLibraryId)', name: 'MR Test Library College', code: 'MRL-COL', campusId: '#(mrCollegeCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(mrCollegeServicePointId)', name: 'MR College Service Point', code: 'MR-SP-COL', discoveryDisplayName: 'MR College Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    # Also create the central service point in the college tenant for pickup availability
    Given path 'service-points'
    And request { id: '#(mrCentralServicePointId)', name: 'MR Central Service Point', code: 'MR-SP-C', discoveryDisplayName: 'MR Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'instance-types'
    And request { id: '#(mrInstanceTypeId)', name: 'MR Instance Type', code: 'MRI-T', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(mrLoanTypeId)', name: 'MR Loan Type' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(mrMaterialTypeId)', name: 'MR Material Type' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(mrCollegeHoldingsSourceId)', name: 'MR FOLIO College' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(mrCollegeLocationId)",
        "name": "MR College Location",
        "code": "MR-LOC-COL",
        "institutionId": "#(mrCollegeInstitutionId)",
        "campusId": "#(mrCollegeCampusId)",
        "libraryId": "#(mrCollegeLibraryId)",
        "primaryServicePoint": "#(mrCentralServicePointId)",
        "servicePointIds": ["#(mrCentralServicePointId)", "#(mrCollegeServicePointId)"]
      }
      """
    When method POST
    Then status 201

    # ========== Step 7: Setup circulation policies ==========
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Enable ECS TLR feature at consortium level
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    Given path 'tlr/settings'
    And request { "ecsTlrFeatureEnabled": true, "excludeFromEcsRequestLendingTenantSearch": [] }
    When method PUT
    Then status 204

    * call setupCirculationPolicies { tenant: '#(centralTenant)', okapitoken: '#(okapitoken)', policyLabel: 'MR-Central' }

    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * call setupCirculationPolicies { tenant: '#(universityTenant)', okapitoken: '#(universityLogin.okapitoken)', policyLabel: 'MR-University' }

    * def collegeLogin = call eurekaLogin { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }
    * call setupCirculationPolicies { tenant: '#(collegeTenant)', okapitoken: '#(collegeLogin.okapitoken)', policyLabel: 'MR-College' }
