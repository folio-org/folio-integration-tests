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
    * def defaultOrganizationId = 'fdf712cb-ffd2-5142-ad1c-8b0cc1c262f7'
    * def defaultOrganizationName = 'Default organization name for MODEXPS-202'
    * def defaultOrganizationCode = 'Default organization code for MODEXPS-202'
    * def defaultAccounts = []
    * def defaultEdiFtpFormat = 'FTP'
    * def defaultEdiFtpMode = 'ASCII'
    * def defaultEdiFtpPort = 22
    * def defaultEdiFtpInvoiceDirectory = '/modexps-202/invoices'
    * def defaultEdiFtpOrderDirectory = '/modexps-202/orders'
    * def defaultEdiFtpPassword = 'Ffx29%pu'
    * def defaultEdiFtpServerAddress = 'ftp://ftp.ci.folio.org'
    * def defaultEdiFtpUsername = 'folio'
    * def defaultEdiScheduleTimeZone = 'UTC'

  @CreateOrganization
  Scenario: Create organization
    * configure headers = headersAdmin
    * def organizationEntityRequest = read('samples/organization-entity-request.json')
    * organizationEntityRequest.id = karate.get('extOrganizationId', defaultOrganizationId)
    * organizationEntityRequest.name = karate.get('extOrganizationName', defaultOrganizationName + ' ' + random_string())
    * organizationEntityRequest.code = karate.get('extOrganizationCode', defaultOrganizationCode + ' ' + random_string())

    Given path '/organizations/organizations'
    And request organizationEntityRequest
    When method POST
    Then status 201

  @SetAccountToOrganization
  Scenario: Set accounts to specified organization
    * def organizationId = karate.get('extOrganizationId', defaultOrganizationId)
    * def accounts = karate.get('extAccounts', defaultAccounts)

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
    * orderEntityRequest.vendor = karate.get('extOrganizationId', defaultOrganizationId)
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

    * poLineEntityRequest.acquisitionMethod = karate.get('extPurchaseAcqMethodId', defaultPurchaseAcqMethodId)
    * poLineEntityRequest.fundDistribution[0].fundId = karate.get('extFundId', defaultFundId)
    * poLineEntityRequest.fundDistribution[0].code = 'PO line fund code'
    * poLineEntityRequest.locations[0].locationId = karate.get('extLocationId', defaultLocationId)
    * poLineEntityRequest.physical.materialType = karate.get('extMaterialTypeId', defaultMaterialTypeIdPhys)
    * poLineEntityRequest.physical.materialSupplier = karate.get('extMaterialSupplier', defaultVendorId)
    * poLineEntityRequest.eresource.materialType = karate.get('extMaterialTypeId', defaultMaterialTypeIdPhys)
    * poLineEntityRequest.vendorDetail.vendorAccount = karate.get('extOrganizationId', defaultVendorId)

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

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

#  @AddIntegrationToOrganization
#  Scenario: Add integration to specified organization
#
#    # should do refactoring on these codes: need to add uuid to objects, need to find default method(Purchase),...
#
#    # mandatory fields
#    * def organizationId = karate.get('extOrganizationId', defaultOrganizationId)
#    * def accountNo = karate.get('extAccountNo')
#
#    * def ediScheduleFrequency = karate.get('extEdiScheduleFrequency', 1)
#    * def ediSchedulePeriod = karate.get('extEdiSchedulePeriod', 'DAY')
#    * def ediScheduleDate = karate.get('extEdiScheduleDate', '2023-04-13T10:53Z')
#    * def ediScheduleTime = karate.get('extEdiScheduleTime', '10:53:00')
#
#    # set all obtained fields to export-config
#    * def exportConfigRequest = read('samples/export-config.json')
##    * exportConfigRequest.id = call uuid1
#
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.vendorId = organizationId
#
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediConfig.accountNoList = [accountNo]
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediConfig.defaultAcquisitionMethods = 'Should find an existing default method (Purchase)'
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediConfig.libEdiCode = 'Should be a number'
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediConfig.vendorEdiCode = 'Should be a number'
#
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.ftpFormat = karate.get('extEdiFtpFormat', defaultEdiFtpFormat)
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.ftpMode = karate.get('extEdiFtpMode', defaultEdiFtpMode)
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.ftpPort = karate.get('extEdiFtpPort', defaultEdiFtpPort)
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.invoiceDirectory = karate.get('extEdiFtpInvoiceDirectory', defaultEdiFtpInvoiceDirectory)
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.orderDirectory = karate.get('extEdiFtpOrderDirectory', defaultEdiFtpOrderDirectory)
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.password = karate.get('extEdiFtpPassword', defaultEdiFtpPassword)
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.serverAddress = karate.get('extEdiFtpServerAddress', defaultEdiFtpServerAddress)
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.username = karate.get('extEdiFtpUsername', defaultEdiFtpUsername)
#
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.scheduleFrequency = ediScheduleFrequency
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.schedulePeriod = ediSchedulePeriod
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.schedulingDate = ediScheduleDate
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.scheduleTime = ediScheduleTime
#    * exportConfigRequest.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediSchedule.scheduleParameters.timeZone = karate.get('extEdiScheduleTimeZone', defaultEdiScheduleTimeZone)
#
#    # post export config
#    Given path '/data-export-spring/configs'
#    And request exportConfigRequest
#    When method POST
#    Then status 201

  @CreateFiscalYear
  Scenario: Create fiscal year
    * configure headers = headersAdmin
    * print 'In @CreateFiscalYear:: defaultFiscalYearId = ' + defaultFiscalYearId
    * def fiscalYearId = karate.get('extFiscalYearId', defaultFiscalYearId)
    * print 'In @CreateFiscalYear:: fiscalYearId = ' + fiscalYearId

    Given path 'finance/fiscal-years'
    And request
    """
    {
      "id": "#(fiscalYearId)",
      "name": "TST-Fiscal Year 2023",
      "code": "FY2023",
      "description": "January 1 - December 30",
      "periodStart": "2023-01-01T00:00:00Z",
      "periodEnd": "2023-12-31T23:59:59Z",
      "series": "FY"
    }
    """
    When method POST
    Then status 201

  @CreateLedgers
  Scenario: Create ledger
    * configure headers = headersAdmin
    * def ledgerId = karate.get('extLedgerId', defaultLedgerId)
    * def fiscalYearId = karate.get('extFiscalYearId', defaultFiscalYearId)

    Given path 'finance-storage/ledgers'
    And request
    """
    {
        "id": "#(ledgerId)",
        "code": "TST-LDG",
        "ledgerStatus": "Active",
        "name": "Test ledger",
        "fiscalYearOneId": "#(fiscalYearId)",
        "restrictEncumbrance": false
    }
    """
    When method POST
    Then status 201

  @CreateFund
  Scenario: Create fund
    * configure headers = headersAdmin
    * def fundId = karate.get('extFundId', defaultFundId)
    * def ledgerId = karate.get('extLedgerId', defaultLedgerId)

    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(fundId)",
      "code": "TST-FND",
      "description": "Fund for API Tests",
      "externalAccountNo": "1111111111111111111111111",
      "fundStatus": "Active",
      "ledgerId": "#(ledgerId)",
      "name": "Fund for API Tests"
    }
    """
    When method POST
    Then status 201

  @CreateBudget
  Scenario: Create budget
    * configure headers = headersAdmin
    * def budgetId = karate.get('extBudgetId', defaultBudgetId)
    * def fundId = karate.get('extFundId', defaultFundId)
    * def fiscalYearId = karate.get('extFiscalYearId', defaultFiscalYearId)

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "Budget for API Tests",
      "fiscalYearId":"#(fiscalYearId)",
      "allocated": 9999999
    }
    """
    When method POST
    Then status 201

  @CreateIdentifierType
  Scenario: create identifier type
    * configure headers = headersAdmin
    * def identifierTypeId = karate.get('extIdentifierTypeId', defaultIdentifierTypeId)

    Given path 'identifier-types'
    And request
    """
    {
      "id": "#(identifierTypeId)",
      "name": "apiTestsIdentifierTypeName"
    }
    """
    When method POST
    Then status 201

  @CreateIdentifierTypeISBN
  Scenario: create identifier type ISBN
    * configure headers = headersAdmin
    * def ISBNIdentifierTypeId = karate.get('extISBNIdentifierTypeId', defaultISBNIdentifierTypeId)

    Given path 'identifier-types'
    And request
    """
    {
      "id": "#(ISBNIdentifierTypeId)",
      "name": "ISBN"
    }
    """
    When method POST
    Then status 201

  @CreateInstanceType
  Scenario: create instance type
    * configure headers = headersAdmin
    * def instanceTypeId = karate.get('extInstanceTypeId', defaultInstanceTypeId)

    Given path 'instance-types'
    And request
    """
    {
      "id": "#(instanceTypeId)",
      "code": "apiTestsInstanceTypeCode",
      "name": "apiTestsInstanceTypeCode",
      "source": "apiTests"
    }
    """
    When method POST
    Then status 201

  @CreateInstanceStatus
  Scenario: create instance status
    * configure headers = headersAdmin
    * def instanceStatusId = karate.get('extInstanceStatusId', defaultInstanceStatusId)

    Given path 'instance-statuses'
    And request
    """
    {
      "id": "#(instanceStatusId)",
      "code": "temp",
       "name": "Temporary",
       "source": "folio"
    }
    """
    When method POST
    Then status 201

  @CreateLoanType
  Scenario: create create loan-type
    * configure headers = headersAdmin
    * def loanTypeId = karate.get('extLoanTypeId', defaultLoanTypeId)

    Given path 'loan-types'
    And request
    """
    {
      "id": "#(loanTypeId)",
      "name": "Can circulate",
      "metadata": {
        "createdDate": "2020-04-17T02:44:38.672",
        "updatedDate": "2020-04-17T02:44:38.672+0000"
      }
    }
    """
    When method POST
    Then status 201

  @CreateMaterialType
  Scenario: create instance material types
    * configure headers = headersAdmin
    * def materialTypeId = karate.get('extMaterialTypeId', defaultMaterialTypeIdElec)
    * def materialTypeName = karate.get('extMaterialTypeName', 'Elec')

    Given path 'material-types'
    And request
    """
    {
      "id": "#(materialTypeId)",
      "name": "#(materialTypeName)"
    }
    """
    When method POST
    Then status 201

  @CreateContributorNameType
  Scenario: create instance contributor name types
    * configure headers = headersAdmin
    * def contributorNameTypeId = karate.get('extContributorNameTypeId', defaultContributorNameTypeId)

    Given path 'contributor-name-types'
    And request
    """
    {
      "id": "#(contributorNameTypeId)",
      "name": "contributorNameType"
    }
    """
    When method POST
    Then status 201

  @CreateElectronicAccessRelationship
  Scenario: create inventory electronic-access-relationships
    * configure headers = headersAdmin
    * def electronicAccessRelationshipId = karate.get('extElectronicAccessRelationshipId', defaultElectronicAccessRelationshipId)

    Given path 'electronic-access-relationships'
    And request
    """
    {
      "id": "#(electronicAccessRelationshipId)",
      "name": "Resource",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

  @CreateInstitution
  Scenario: create institution
    * configure headers = headersAdmin
    * def instructionId = karate.get('extInstructionId', defaultInstructionId)

    Given path 'location-units/institutions'
    And request
    """
    {
        "id": "#(instructionId)",
        "name": "Universitet",
        "code": "TU"
    }
    """
    When method POST
    Then status 201

  @CreateCampus
  Scenario: create campus
    * configure headers = headersAdmin
    * def campusId = karate.get('extCampusId', defaultCampusId)
    * def instructionId = karate.get('extInstructionId', defaultInstructionId)

    Given path 'location-units/campuses'
    And request
    """
    {
        "id": "#(campusId)",
        "institutionId": "#(instructionId)",
        "name": " Campus",
        "code": "TC"
    }
    """
    When method POST
    Then status 201

  @CreateLibrary
  Scenario: create library
    * configure headers = headersAdmin
    * def libraryId = karate.get('extLibraryId', defaultLibraryId)
    * def campusesId = karate.get('extCampusesId', defaultCampusId)

    Given path 'location-units/libraries'
    And request
    """
    {
        "id": "#(libraryId)",
        "campusId": "#(campusesId)",
        "name": "Library",
        "code": "TL"
    }
    """
    When method POST
    Then status 201

  @CreateServicePoint
  Scenario: create service point
    * configure headers = headersAdmin
    * def servicePointId = karate.get('extServicePointId', defaultServicePointId)

    Given path 'service-points'
    And request
    """
    {
        "id": "#(servicePointId)",
        "name": "Service point",
        "code": "TSP",
        "discoveryDisplayName": "Service point 1"
    }
    """
    When method POST
    Then status 201

  @CreateHoldingsSource
  Scenario: create holdings source
    * configure headers = headersAdmin
    * def holdingsSourceId = karate.get('extHoldingsSourceId', defaultHoldingsSourceId)

    Given path 'holdings-sources'
    And request
    """
    {
        "id": "#(holdingsSourceId)",
        "name": "FOLIO"
    }
    """
    When method POST
    Then status 201

  @CreateLocation
  Scenario: create location
    * configure headers = headersAdmin
    * def locationId = karate.get('extLocationId', defaultLocationId)
    * def institutionId = karate.get('extInstitutionId', defaultInstructionId)
    * def campusId = karate.get('extCampusId', defaultCampusId)
    * def libraryId = karate.get('extLibraryId', defaultLibraryId)
    * def servicePointId = karate.get('extServicePointId', defaultServicePointId)

    Given path 'locations'
    And request
    """
    {
        "id": "#(locationId)",
        "name": "Location 1",
        "code": "LOC1",
        "isActive": true,
        "institutionId": "#(institutionId)",
        "campusId": "#(campusId)",
        "libraryId": "#(libraryId)",
        "primaryServicePoint": "#(servicePointId)",
        "servicePointIds": [
            "#(servicePointId)"
        ]
    }
    """
    When method POST
    Then status 201

  @CreateInstance
  Scenario: Create instance
    * configure headers = headersAdmin
    * def instanceId = karate.get('extInstanceId', defaultInstanceId)
    * def instanceTypeId = karate.get('extInstanceTypeId', defaultInstanceTypeId)

    Given path 'inventory/instances'
    And request
      """
      {
        "id": "#(instanceId)",
        "source": "FOLIO",
        "title": "A semantic web primer for instance 1",
        "instanceTypeId": "#(instanceTypeId)"
      }
      """
    When method POST
    Then status 201

  @CreateHolding
  Scenario: Create holding
    * configure headers = headersAdmin
    * def holdingId = karate.get('extHoldingId', defaultHoldingId)
    * def instanceId = karate.get('extInstanceId', defaultInstanceId)
    * def locationId = karate.get('extLocationId', defaultLocationId)
    * def holdingsSourceId = karate.get('extHoldingsSourceId', defaultHoldingsSourceId)

    Given path 'holdings-storage/holdings'
    And request
      """
      {
        id: "#(holdingId)",
        instanceId: "#(instanceId)",
        permanentLocationId: "#(locationId)",
        sourceId : "#(holdingsSourceId)"
      }
      """
    When method POST
    Then status 201

  @CreatePurchaseAcqMethod
  Scenario: Create 'Purchase' acquisition methods
    * configure headers = headersAdmin
    * def purchaseAcqMethodId = karate.get('extPurchaseAcqMethodId', defaultPurchaseAcqMethodId)

    Given path 'orders/acquisition-methods'
    And request
    """
    {
      "id": "#(purchaseAcqMethodId)",
      "value": "Purchase Method for Karate tests",
      "source": "System"
    }
    """
    When method POST
    Then status 201
