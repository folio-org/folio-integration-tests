Feature: Add FQM query data
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Add sample data needed for FQM queries
    # Add address type
    * def addressRequest = {addressType:  'Home address', id:  '12345678-a4ef-47ca-b29c-0a5ad7bbf321'}
    Given path '/addresstypes'
    And request addressRequest
    When method POST
    Then status 201

    # Add users
    * def userRequest = read('classpath:corsair/mod-fqm-manager/features/samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId = $.id

    * userRequest.username = 'integration_test_user_456'
    * userRequest.id = '00000000-1111-2222-9999-44444444442'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * userRequest.username = 'integration_test_other_user'
    * userRequest.id = '00000000-1111-2222-9999-44444444443'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * userRequest.username = 'user_to_delete'
    * userRequest.id = '00000000-1111-2222-9999-44444444444'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * def userRequest = read('classpath:corsair/mod-fqm-manager/features/samples/user-request-with-address.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * def userRequest = read('classpath:corsair/mod-fqm-manager/features/samples/user-request-missing-address-fields.json')
    Given path '/users'
    And request userRequest
    When method POST
    Then status 201

    # Add instance type
    * def instanceTypeId = 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804f'
    * def instanceTypeRequest = {id: '#(instanceTypeId)', 'name': 'still image', "code": 'sti', "source": 'rdacarrier'}
    Given path '/instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    # Add instance
    * def instanceId = 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804e'
    * def instanceRequest = {id: '#(instanceId)', title: 'Some title', source: 'Local', instanceTypeId: '#(instanceTypeId)', languages: ['eng', 'fre']}
    Given path '/instance-storage/instances'
    And request instanceRequest
    When method POST
    Then status 201

    # Wait until last instance is indexed
    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    # Add institution
    * def institutionId = call uuid1
    * def institutionRequest = {id: '#(institutionId)', name: 'Main Institution', code: 'MI'}
    Given path '/location-units/institutions'
    And request institutionRequest
    When method POST
    Then status 201

    # Add campus
    * def campusId = call uuid1
    * def campusRequest = {id: '#(campusId)', institutionId: '#(institutionId)', name: 'Main Campus', code: 'MC'}
    Given path '/location-units/campuses'
    And request campusRequest
    When method POST
    Then status 201

    # Add library
    * def libraryId = call uuid1
    * def libraryRequest = {id: '#(libraryId)', campusId: '#(campusId)', name: 'Main Campus', code: 'MC'}
    Given path '/location-units/libraries'
    And request libraryRequest
    When method POST
    Then status 201

    # Add location
    * def servicePointId = call uuid1
    * def permanentLocationId = call uuid1
    * def locationRequest = {id:  '#(permanentLocationId)', name: 'Location 1', code: 'loc1', primaryServicePoint: '#(servicePointId)', libraryId:  '#(libraryId)', campusId:  '#(campusId)', institutionId: '#(institutionId)', servicePointIds:  ['#(servicePointId)']}
    Given path '/locations'
    And request locationRequest
    When method POST
    Then status 201

    # Add finance data for purchase order line fund distributions
    * def fqmFiscalYearId = 'c8448540-0000-4000-8000-000000000001'
    * def fqmLedgerId = 'c8448540-0000-4000-8000-000000000002'
    * def canadianHistoryFundId = 'c8448540-0000-4000-8000-000000000003'
    * def exchangesFundId = 'c8448540-0000-4000-8000-000000000004'
    * def historyMiscFundId = 'c8448540-0000-4000-8000-000000000005'

    * def fiscalYearRequest = { id: '#(fqmFiscalYearId)', name: 'FQM Fiscal Year 2026', code: 'FQM2026', description: 'FQM query test fiscal year', periodStart: '2026-01-01T00:00:00Z', periodEnd: '2026-12-31T23:59:59Z', series: 'FQM' }
    Given path 'finance/fiscal-years'
    And request fiscalYearRequest
    When method POST
    Then status 201

    * def ledgerRequest = { id: '#(fqmLedgerId)', name: 'FQM fund distribution ledger', code: 'FQMFD', fiscalYearOneId: '#(fqmFiscalYearId)', ledgerStatus: 'Active', restrictEncumbrance: false, restrictExpenditures: false }
    Given path 'finance/ledgers'
    And request ledgerRequest
    When method POST
    Then status 201

    * def canadianHistoryFundRequest = { fund: { id: '#(canadianHistoryFundId)', code: 'CANHIST', description: '', externalAccountNo: 'FQM-CANHIST', fundStatus: 'Active', ledgerId: '#(fqmLedgerId)', name: 'Canadian History' } }
    * def exchangesFundRequest = { fund: { id: '#(exchangesFundId)', code: 'EXCH-SUBN', description: '', externalAccountNo: 'FQM-EXCH-SUBN', fundStatus: 'Active', ledgerId: '#(fqmLedgerId)', name: 'Exchanges' } }
    * def historyMiscFundRequest = { fund: { id: '#(historyMiscFundId)', code: 'MISCHIST', description: '', externalAccountNo: 'FQM-MISCHIST', fundStatus: 'Active', ledgerId: '#(fqmLedgerId)', name: 'History Misc' } }
    Given path 'finance/funds'
    And request canadianHistoryFundRequest
    When method POST
    Then status 201
    Given path 'finance/funds'
    And request exchangesFundRequest
    When method POST
    Then status 201
    Given path 'finance/funds'
    And request historyMiscFundRequest
    When method POST
    Then status 201

    # Add a holdings source
    * def holdingsSourceId = call uuid1
    * def holdingsRecordRequest = {id: '#(holdingsSourceId)', name: 'test source', source: 'local'}
    Given path '/holdings-sources'
    And request holdingsRecordRequest
    When method POST
    Then status 201

    # Add a call number type
    * def callNumberTypeId = '512173a7-bd09-490e-b773-17d83f2b63fe'
    * def callNumberTypeName = 'LC Modified'
    * def callNumberTypeRequest = {id: '#(callNumberTypeId)', name: '#(callNumberTypeName)', source: 'folio'}
    Given path '/call-number-types'
    And request callNumberTypeRequest
    When method POST
    Then status 201

    # Add holdings
    * def holdingsId = call uuid1
    * def holdingsRequest = {id: '#(holdingsId)', instanceId: '#(instanceId)', permanentLocationId:  '#(permanentLocationId)', sourceId: '#(holdingsSourceId)', callNumberTypeId: '#(callNumberTypeId)'}
    Given path '/holdings-storage/holdings'
    And request holdingsRequest
    When method POST
    Then status 201

    # Add loan type
    * def loanTypeId = call uuid1
    * def loanTypeRequest = {id: '#(loanTypeId)', name: 'Can circulate', source: 'System'}
    Given path '/loan-types'
    And request loanTypeRequest
    When method POST
    Then status 201

    # Add item damaged status
    * def itemDamagedStatusId = 'c1312672-0000-4000-8000-000000000001'
    * def itemDamagedStatusRequest = {id: '#(itemDamagedStatusId)', name: 'Damaged', source: 'local'}
    Given path '/item-damaged-statuses'
    And request itemDamagedStatusRequest
    When method POST
    Then status 201

    # Add material type
    * def materialTypeId = '2ee721ab-70e5-49a6-8b09-1af0217ea3fc'
    * def materialTypeRequest = {id: '#(materialTypeId)', name: 'book'}
    Given path '/material-types'
    And request materialTypeRequest
    When method POST
    Then status 201

    # Add item
    * def itemId = call uuid1
    * def itemRequest = {id: '#(itemId)', holdingsRecordId: '#(holdingsId)', status:  {name: 'Checked out'}, permanentLoanTypeId: '#(loanTypeId)', materialTypeId: '#(materialTypeId)', numberOfMissingPieces: '100', missingPieces: 'Piece 1 - test', missingPiecesDate: '2026-04-19', itemDamagedStatusId: '#(itemDamagedStatusId)', itemDamagedStatusDate: '2026-04-19'}
    Given path '/item-storage/items'
    And request itemRequest
    When method POST
    Then status 201

    # Add loans
    * def loanId = call uuid1
    * def loanRequest = {id: '#(loanId)', itemId:  '#(itemId)', action: 'checkedout', loanDate:  '2017-03-01T23:11:00-01:00', userId: '#(userId)'}
    Given path '/loan-storage/loans'
    And request loanRequest
    When method POST
    Then status 201

    # Add purchase order custom fields
    * def fqmPoCheckboxCustomFieldId = '83195700-0000-4000-8000-000000000001'
    * def fqmPoMultiSelectCustomFieldId = '83195700-0000-4000-8000-000000000002'
    * def fqmPoSingleSelectCustomFieldId = '83195700-0000-4000-8000-000000000003'
    * def fqmPoTextAreaCustomFieldId = '83195700-0000-4000-8000-000000000004'
    * def fqmPoTextFieldCustomFieldId = '83195700-0000-4000-8000-000000000005'
    * def fqmPoCheckboxRefId = 'fqmCheckbox'
    * def fqmPoMultiSelectRefId = 'fqmMultiSelect'
    * def fqmPoSingleSelectRefId = 'fqmSingleSelect'
    * def fqmPoTextAreaRefId = 'fqmTextArea'
    * def fqmPoTextFieldRefId = 'fqmTextField'

    # Custom fields use the generic /custom-fields endpoint routed by x-okapi-module-id.
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': '#("Bearer " + keycloakMasterToken)' }
    Given path 'applications'
    When method GET
    Then status 200
    * def totalApplications = response.totalRecords
    Given path 'applications'
    And param limit = totalApplications
    When method GET
    Then status 200
    * def ordersStorageModules = response.applicationDescriptors.flatMap(app => app.modules || []).filter(module => module.name == 'mod-orders-storage')
    * assert ordersStorageModules.length > 0
    * def ordersStorageModuleId = ordersStorageModules[0].id
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * def fqmPoCheckboxCustomField =
      """
      {
        "id": "#(fqmPoCheckboxCustomFieldId)",
        "name": "FQM - checkbox",
        "type": "SINGLE_CHECKBOX",
        "order": 1,
        "refId": "#(fqmPoCheckboxRefId)",
        "visible": true,
        "required": false,
        "isRepeatable": false,
        "helpText": "",
        "entityType": "purchase_order",
        "checkboxField": {
          "default": false
        }
      }
      """

    * def fqmPoMultiSelectCustomField =
      """
      {
        "id": "#(fqmPoMultiSelectCustomFieldId)",
        "name": "FQM - multi select",
        "type": "MULTI_SELECT_DROPDOWN",
        "order": 2,
        "refId": "#(fqmPoMultiSelectRefId)",
        "visible": true,
        "required": false,
        "isRepeatable": false,
        "helpText": "",
        "entityType": "purchase_order",
        "selectField": {
          "multiSelect": true,
          "options": {
            "values": [
              {
                "id": "opt_0",
                "value": "FQM - multi select1",
                "default": true
              },
              {
                "id": "opt_1",
                "value": "FQM - multi select2",
                "default": false
              }
            ],
            "sortingOrder": "CUSTOM"
          }
        }
      }
      """

    * def fqmPoSingleSelectCustomField =
      """
      {
        "id": "#(fqmPoSingleSelectCustomFieldId)",
        "name": "FQM - single select",
        "type": "SINGLE_SELECT_DROPDOWN",
        "order": 3,
        "refId": "#(fqmPoSingleSelectRefId)",
        "visible": true,
        "required": false,
        "isRepeatable": false,
        "helpText": "",
        "entityType": "purchase_order",
        "selectField": {
          "multiSelect": false,
          "options": {
            "values": [
              {
                "id": "opt_0",
                "value": "FQM - single select1",
                "default": false
              },
              {
                "id": "opt_1",
                "value": "FQM - single select2",
                "default": true
              }
            ],
            "sortingOrder": "CUSTOM"
          }
        }
      }
      """

    * def fqmPoTextAreaCustomField =
      """
      {
        "id": "#(fqmPoTextAreaCustomFieldId)",
        "name": "FQM - text area",
        "type": "TEXTBOX_LONG",
        "order": 4,
        "refId": "#(fqmPoTextAreaRefId)",
        "visible": true,
        "required": false,
        "isRepeatable": false,
        "helpText": "",
        "entityType": "purchase_order"
      }
      """

    * def fqmPoTextFieldCustomField =
      """
      {
        "id": "#(fqmPoTextFieldCustomFieldId)",
        "name": "FQM - text field",
        "type": "TEXTBOX_SHORT",
        "order": 5,
        "refId": "#(fqmPoTextFieldRefId)",
        "visible": true,
        "required": false,
        "isRepeatable": false,
        "helpText": "",
        "entityType": "purchase_order"
      }
      """
    * def fqmPoCustomFields = []
    * set fqmPoCustomFields[0] = fqmPoCheckboxCustomField
    * set fqmPoCustomFields[1] = fqmPoMultiSelectCustomField
    * set fqmPoCustomFields[2] = fqmPoSingleSelectCustomField
    * set fqmPoCustomFields[3] = fqmPoTextAreaCustomField
    * set fqmPoCustomFields[4] = fqmPoTextFieldCustomField
    Given path '/custom-fields'
    And header x-okapi-module-id = ordersStorageModuleId
    And request { customFields: '#(fqmPoCustomFields)', entityType: 'purchase_order' }
    When method PUT
    Then assert responseStatus == 200 || responseStatus == 204

    * configure retry = { count: 60, interval: 5000 }
    Given path '/custom-fields'
    And header x-okapi-module-id = ordersStorageModuleId
    And param limit = 100
    And retry until response.customFields && response.customFields.some(field => field.refId == fqmPoMultiSelectRefId)
    When method GET
    Then status 200

    # Add purchase order
    * def orderId = call uuid1
    * def orderCustomFields = { fqmCheckbox: true, fqmMultiSelect: ['opt_0'], fqmSingleSelect: 'opt_1', fqmTextArea: 'FQM test for text area', fqmTextField: 'FQM test for text field' }
    * def orderRequest = {id: '#(orderId)', metadata: {createdDate: '2018-08-19T00:00:00.000+0000'}, customFields: '#(orderCustomFields)'}
    Given path '/orders-storage/purchase-orders'
    And request orderRequest
    And retry until responseStatus == 201
    When method POST
    Then status 201

     #Add Purchase Order Line
    * def purchaseOrderLineId = call uuid1
    * def cost = {"additionalCost": 4.99, "currency": "USD", "discount": 10, "discountType": "percentage", "exchangeRate": 1.12, "listUnitPriceElectronic": 24.99, "quantityElectronic": 2, "poLineEstimatedPrice": 49.97}
    * def acquisitionMethod = call uuid1
    * def fundDistribution = [{ "code": "serials", "value": 100.0 , "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]
    * def purchaseOrderLineRequest = {id: '#(purchaseOrderLineId)', orderFormat:'P/E Mix' ,source:'User', purchaseOrderId:'#(orderId)', titleOrPackage: 'Kayak Fishing in the Northern Gulf Coast', paymentStatus: 'Fully Paid', fundDistribution : '#(fundDistribution)', cost: '#(cost)', acquisitionMethod: '#(acquisitionMethod)'}
    Given path '/orders-storage/po-lines'
    And request purchaseOrderLineRequest
    When method POST

    # Add Purchase Order Line with multiple fund distributions
    * def purchaseOrderLineWithFundDistributionsId = 'c8448540-0000-4000-8000-000000000006'
    * def fundDistributions = [{ code: 'CANHIST', value: 30.0, fundId: '#(canadianHistoryFundId)', distributionType: 'percentage' }, { code: 'EXCH-SUBN', value: 30.0, fundId: '#(exchangesFundId)', distributionType: 'percentage' }, { code: 'MISCHIST', value: 40.0, fundId: '#(historyMiscFundId)', distributionType: 'percentage' }]
    * def purchaseOrderLineWithFundDistributionsRequest = {id: '#(purchaseOrderLineWithFundDistributionsId)', orderFormat:'P/E Mix' ,source:'User', purchaseOrderId:'#(orderId)', titleOrPackage: 'Purchase order line with fund distributions', paymentStatus: 'Pending', fundDistribution : '#(fundDistributions)', cost: '#(cost)', acquisitionMethod: '#(acquisitionMethod)'}
    Given path '/orders-storage/po-lines'
    And request purchaseOrderLineWithFundDistributionsRequest
    When method POST
    Then status 201

     #Add Organizations
    * def  organizationsId  = call uuid1
    * def organizationsRequest = {id: '#(organizationsId)', name: "test organization", status: "Active", code: "test"}
    Given path '/organizations-storage/organizations'
    And request organizationsRequest
    When method POST
