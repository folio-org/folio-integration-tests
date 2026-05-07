Feature: Cross-tenant item queries in mod-fqm-manager

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure retry = { count: 20, interval: 15000 }
    * def itemEntityTypeId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def resultFields = ['items.id', 'items.created_date', 'items.tenant_id', 'holdings.tenant_id', 'instances.tenant_id', 'instances.shared', 'instances.source']

  @Positive @C552521
  Scenario: [Items] [Central tenant] Query returns items for local and shared instances from all tenants
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    # The item entity type should expose the ECS-only fields that back the Lists preview columns.
    Given path 'entity-types', itemEntityTypeId
    When method GET
    Then status 200
    And match response.columns[*].name contains resultFields

    # Cross-tenant execution flattens the item entity type in each affiliated tenant.
    * def itemQueryHelpers = 'classpath:corsair/mod-fqm-manager/features/consortia/cross_tenant_item_query_helpers.feature'
    * call read(itemQueryHelpers + '@InstallEntityTypes') ({ tenant: centralTenant, user: consortiaAdmin, itemEntityTypeId: itemEntityTypeId })
    * call read(itemQueryHelpers + '@InstallEntityTypes') ({ tenant: universityTenant, user: universityUser1, itemEntityTypeId: itemEntityTypeId })
    * call read(itemQueryHelpers + '@InstallEntityTypes') ({ tenant: collegeTenant, user: collegeUser1, itemEntityTypeId: itemEntityTypeId })

    * def centralRef = call read(itemQueryHelpers + '@CreateReferenceData') ({ tenant: centralTenant, user: consortiaAdmin, codePrefix: 'cen' })
    * def universityRef = call read(itemQueryHelpers + '@CreateReferenceData') ({ tenant: universityTenant, user: universityUser1, codePrefix: 'uni' })
    * def collegeRef = call read(itemQueryHelpers + '@CreateReferenceData') ({ tenant: collegeTenant, user: collegeUser1, codePrefix: 'col' })

    * def sharedInstanceId = uuid()
    * def universityLocalInstanceId = uuid()
    * def collegeLocalInstanceId = uuid()
    * def centralSharedItemId = uuid()
    * def universitySharedItemId = uuid()
    * def collegeSharedItemId = uuid()
    * def universityLocalItemId = uuid()
    * def collegeLocalItemId = uuid()
    * def centralSharedHoldingId = uuid()
    * def universitySharedHoldingId = uuid()
    * def collegeSharedHoldingId = uuid()
    * def universityLocalHoldingId = uuid()
    * def collegeLocalHoldingId = uuid()
    * def centralSharedBarcode = 'fqm-central-shared-' + centralSharedItemId
    * def universitySharedBarcode = 'fqm-university-shared-' + universitySharedItemId
    * def collegeSharedBarcode = 'fqm-college-shared-' + collegeSharedItemId
    * def universityLocalBarcode = 'fqm-university-local-' + universityLocalItemId
    * def collegeLocalBarcode = 'fqm-college-local-' + collegeLocalItemId

    # Central tenant shared FOLIO instance with a central holding and item.
    * def centralSharedItem = call read(itemQueryHelpers + '@CreateInstanceHoldingItem') ({ tenant: centralTenant, user: consortiaAdmin, instanceId: sharedInstanceId, instanceTitle: 'FQM ECS shared central FOLIO instance', instanceSource: 'FOLIO', itemId: centralSharedItemId, holdingId: centralSharedHoldingId, barcode: centralSharedBarcode, refData: centralRef })

    # Member tenant shadow records for the shared instance, each with local holdings and items.
    * call read(itemQueryHelpers + '@CreateInstanceHoldingItem') ({ tenant: universityTenant, user: universityUser1, instanceId: sharedInstanceId, instanceTitle: 'FQM ECS shared central FOLIO instance', instanceSource: 'CONSORTIUM-FOLIO', itemId: universitySharedItemId, holdingId: universitySharedHoldingId, barcode: universitySharedBarcode, refData: universityRef })
    * call read(itemQueryHelpers + '@CreateInstanceHoldingItem') ({ tenant: collegeTenant, user: collegeUser1, instanceId: sharedInstanceId, instanceTitle: 'FQM ECS shared central FOLIO instance', instanceSource: 'CONSORTIUM-FOLIO', itemId: collegeSharedItemId, holdingId: collegeSharedHoldingId, barcode: collegeSharedBarcode, refData: collegeRef })

    # Local member tenant instances, holdings, and items.
    * call read(itemQueryHelpers + '@CreateInstanceHoldingItem') ({ tenant: universityTenant, user: universityUser1, instanceId: universityLocalInstanceId, instanceTitle: 'FQM ECS local university FOLIO instance', instanceSource: 'FOLIO', itemId: universityLocalItemId, holdingId: universityLocalHoldingId, barcode: universityLocalBarcode, refData: universityRef })
    * call read(itemQueryHelpers + '@CreateInstanceHoldingItem') ({ tenant: collegeTenant, user: collegeUser1, instanceId: collegeLocalInstanceId, instanceTitle: 'FQM ECS local college FOLIO instance', instanceSource: 'FOLIO', itemId: collegeLocalItemId, holdingId: collegeLocalHoldingId, barcode: collegeLocalBarcode, refData: collegeRef })

    # Submit the API equivalent of "Item - Created date equals today's date".
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    * def queryDate = centralSharedItem.itemCreatedDate
    * def fqlQuery = '{"items.created_date":{"$eq":"' + queryDate + '"}}'
    * def queryRequest = { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '#(fqlQuery)', fields: '#(resultFields)' }
    Given path 'query'
    And request queryRequest
    When method POST
    Then status 201
    And match response.queryId == '#present'
    * def queryId = response.queryId

    Given path 'query', queryId
    And params { includeResults: true, limit: 1000, offset: 0 }
    And retry until responseStatus != 200 || response.status == 'SUCCESS' || response.status == 'FAILED'
    When method GET
    Then status 200
    * if (response.status == 'FAILED') karate.fail('FQM query failed: ' + karate.pretty(response))
    And match response.status == 'SUCCESS'

    * def expectedItemIds = ['#(centralSharedItemId)', '#(universitySharedItemId)', '#(collegeSharedItemId)', '#(universityLocalItemId)', '#(collegeLocalItemId)']
    * def queriedItems = karate.filter(response.content, function(row) { return expectedItemIds.indexOf(row['items.id']) > -1 })
    * assert karate.sizeOf(queriedItems) == 5

    And match queriedItems contains deep { "items.id": '#(universitySharedItemId)', "instances.shared": 'Shared', "instances.source": 'CONSORTIUM-FOLIO', "holdings.tenant_id": '#(universityTenant)', "instances.tenant_id": '#(universityTenant)', "items.tenant_id": '#(universityTenant)' }
    And match queriedItems contains deep { "items.id": '#(collegeSharedItemId)', "instances.shared": 'Shared', "instances.source": 'CONSORTIUM-FOLIO', "holdings.tenant_id": '#(collegeTenant)', "instances.tenant_id": '#(collegeTenant)', "items.tenant_id": '#(collegeTenant)' }
    And match queriedItems contains deep { "items.id": '#(universityLocalItemId)', "instances.shared": 'Local', "instances.source": 'FOLIO', "holdings.tenant_id": '#(universityTenant)', "instances.tenant_id": '#(universityTenant)', "items.tenant_id": '#(universityTenant)' }
    And match queriedItems contains deep { "items.id": '#(collegeLocalItemId)', "instances.shared": 'Local', "instances.source": 'FOLIO', "holdings.tenant_id": '#(collegeTenant)', "instances.tenant_id": '#(collegeTenant)', "items.tenant_id": '#(collegeTenant)' }
    And match queriedItems contains deep { "items.id": '#(centralSharedItemId)', "instances.shared": 'Shared', "instances.source": 'FOLIO', "holdings.tenant_id": '#(centralTenant)', "instances.tenant_id": '#(centralTenant)', "items.tenant_id": '#(centralTenant)' }
