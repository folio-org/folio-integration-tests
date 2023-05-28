Feature: init data for mod-data-export-spring

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }
    # set default headers to 'user'
    * configure headers = headersUser
    # define default values
    * def defaultOrganizationName = 'Default organization name for MODEXPS-202'
    * def defaultOrganizationCode = 'Default organization code for MODEXPS-202'

  @CreateOrganization
  Scenario: Create organization
    * configure headers = headersAdmin
    * def organizationEntityRequest = read('samples/organization-entity-request.json')
    * organizationEntityRequest.id = karate.get('extOrganizationId', globalVendorId)
    * organizationEntityRequest.name = karate.get('extOrganizationName', defaultOrganizationName + ' ' + random_string())
    * organizationEntityRequest.code = karate.get('extOrganizationCode', defaultOrganizationCode + ' ' + random_string())

    Given path '/organizations/organizations'
    And request organizationEntityRequest
    When method POST
    Then status 201

  @SetAccountToOrganization
  Scenario: Set accounts to specified organization
    * def organizationId = karate.get('extOrganizationId', globalVendorId)
    * def accounts = karate.get('extAccounts', [])

    # get required organization by id
    Given path '/organizations/organizations/', organizationId
    When method GET
    Then status 200
    * json organization = response

    # set 'accounts' to the organization
    * set organization.accounts = accounts

    Given path '/organizations/organizations/', organizationId
    And request organization
    When method PUT
    Then status 204

    # verify everything have been set correctly
    Given path '/organizations/organizations/', organizationId
    When method GET
    Then status 200
    And match $.id == '#(organizationId)'
    And match $.accounts == '#(accounts)'

  @CreateOrderForOrganization
  Scenario: Create order for specified organization
    * def orderEntityRequest = read('samples/order-entity-request.json')
    * orderEntityRequest.id = karate.get('extOrderId')
    * orderEntityRequest.vendor = karate.get('extOrganizationId', globalVendorId)
    * orderEntityRequest.poNumber = karate.get('extPoNumber', '0000001')
    * orderEntityRequest.orderType = karate.get('extOrderType', 'One-Time')

    Given path 'orders/composite-orders'
    And request orderEntityRequest
    When method POST
    Then status 201

  @CreateOrderLines
  Scenario: Create order for specified organization
    * def poLineEntityRequest = read('samples/order-po-line-electronic.json')
    * poLineEntityRequest.id = karate.get('extPoLineId')
    * poLineEntityRequest.eresource.accessProvider = karate.get('extOrganizationId')
    * poLineEntityRequest.purchaseOrderId = karate.get('extOrderId')

    * poLineEntityRequest.acquisitionMethod = karate.get('extPurchaseAcqMethodId', globalPurchaseAcqMethodId)
    * poLineEntityRequest.fundDistribution[0].fundId = karate.get('extFundId', globalFundId)
    * poLineEntityRequest.fundDistribution[0].code = 'PO line fund code'
    * poLineEntityRequest.locations[0].locationId = karate.get('extLocationId', globalLocationsId)
    * poLineEntityRequest.physical.materialType = karate.get('extMaterialTypeId', globalMaterialTypeIdPhys)
    * poLineEntityRequest.physical.materialSupplier = karate.get('extMaterialSupplier', globalVendorId)
    * poLineEntityRequest.eresource.materialType = karate.get('extMaterialTypeId', globalMaterialTypeIdElec)
    * poLineEntityRequest.vendorDetail.vendorAccount = karate.get('extAccountNumber', 'default account number')

    Given path 'orders/order-lines'
    And request poLineEntityRequest
    When method POST
    Then status 201

  @OpenOrder
  Scenario: Open specified order
    * def orderId = karate.get('extOrderId')
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    # set order.workflowStatus to 'Open'
    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'
    * remove order.compositePoLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  @GetLocaleSettings
  Scenario: Get locale settings
    * configure headers = headersAdmin
    Given path 'configurations/entries'
    And param query = '(configName==localeSettings)'
    When method GET
    Then status 200

  @AddIntegrationToOrganization
  Scenario: Add integration to specified organization
    * def exportConfigRequest = read('samples/export-config.json')

    * exportConfigRequest.id = karate.get('extExportConfigId')

    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId = karate.get('extExportConfigId')
    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.vendorId = karate.get('extOrganizationId', globalVendorId)
    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediConfig.accountNoList = karate.get('extAccountNoList', [])
    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediConfig.defaultAcquisitionMethods = karate.get('extAcquisitionMethods',[globalPurchaseAcqMethodId])

    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.scheduleFrequency = karate.get('extEdiScheduleFrequency', 1)
    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.schedulePeriod = karate.get('extEdiSchedulePeriod', 'DAY')
    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.scheduleTime = karate.get('extEdiScheduleTime', '00:00:00')
    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.weekDays = karate.get('extEdiScheduleWeekDays', null)
    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.timeZone = karate.get('extEdiScheduleTimeZone', 'UTC')

    # post export config
    Given path 'data-export-spring/configs'
    And request exportConfigRequest
    When method POST
    Then status 201

  @GetDataExportSpringJobsByType
  Scenario: Get data-export-spring jobs by type == EDIFACT_ORDERS_EXPORT
    Given path 'data-export-spring/jobs'
    And param query = '(type==EDIFACT_ORDERS_EXPORT)'
    When method GET
    Then status 200