Feature: create user, item, service point

  Background:
    * url baseUrl
    * callonce login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * callonce variables

  @CreateInstanceType
  Scenario: create instance type
    Given path 'instance-types'
    And request
    """
    {
    "id": "#(instanceTypeId)",
    "name": "#(instanceTypeName)",
    "code": "#(instanceTypeCode)",
    "source": "#(instanceTypeSource)"
    }
    """
    When method POST

  @CreateInstance
  Scenario: create instance
    Given path 'instance-storage/instances'
    And request
    """
    {
    "id": "#(instanceId)",
    "source": "#(instanceSource)",
    "instanceTypeId": "#(instanceTypeId)",
    "title": "#(instanceTitle)"
    }
    """
    When method POST

  @CreateServicePoint
  Scenario: Create service point
    Given path 'service-points'
    And request
    """
    {
    "id": "#(servicePointId)",
    "code": "#(servicePointCode)",
    "name": "#(servicePointName)",
    "discoveryDisplayName": "#(servicePointDiscoveryDisplayName)",
    "pickupLocation": true,
    "holdShelfExpiryPeriod": {
       "duration": 10,
          "intervalId": "Weeks"
       }
    }
    """
    When method POST

  @CreateServicePointNoPickup
  Scenario: Create service point no pickup
    Given path 'service-points'
    And request
    """
    {
    "id": "#(servicePointNoPickupId)",
    "code": "#(servicePointNoPickupCode)",
    "name": "#(servicePointNoPickupName)",
    "discoveryDisplayName": "#(servicePointDiscoveryDisplayName)",
    "pickupLocation": false
    }
    """
    When method POST

  @CreateInstitution
  Scenario: Create institution
    Given path 'location-units/institutions'
    And request
    """
    {
    "id": "#(institutionId)",
    "name": "#(institutionName)",
    "code": "#(institutionCode)"
    }
    """
    When method POST

  @CreateCampus
  Scenario: Create campus
    Given path 'location-units/campuses'
    And request
    """
    {
    "id": "#(campusId)",
    "name": "#(campusName)",
    "code": "#(campusCode)",
    "institutionId": "#(institutionId)"
    }
    """
    When method POST

  @CreateLibrary
  Scenario: Create library
    Given path 'location-units/libraries'
    And request
    """
    {
    "id": "#(libraryId)",
    "name": "#(libraryName)",
    "code": "#(libraryCode)",
    "campusId": "#(campusId)"
    }
    """
    When method POST

  @CreateLocation
  Scenario: create location
    Given path 'locations'
    And request
    """
    {
    "id": "#(locationId)",
    "primaryServicePoint": "#(servicePointId)",
    "institutionId": "#(institutionId)",
    "libraryId": "#(libraryId)",
    "name": "#(locationName)",
    "code": "#(locationCode)",
    "campusId": "#(campusId)",
    "servicePointIds": [
      "#(servicePointId)"
    ]
    }
    """
    When method POST

  @CreateHolding
  Scenario: create holding
    Given path 'holdings-storage/holdings'
    And request
    """
    {
    "id": "#(holdingsRecordId)",
    "instanceId": "#(instanceId)",
    "permanentLocationId": "#(locationId)"
    }
    """
    When method POST

  @CreateLoanType
  Scenario: create loan type
    Given path 'loan-types'
    And request
    """
    {
    "id": "#(loanTypeId)",
    "name": "#(loanTypeName)"
    }
    """
    When method POST

  @CreateMaterialType
  Scenario: create material type
    Given path 'material-types'
    And request
    """
    {
    "id": "#(materialTypeId)",
    "name": "#(materialTypeName)"
    }
    """
    When method POST

  @CreateUserGroup
  Scenario: Create user group
    Given path 'groups'
    And request
    """
    {
    "group": "#(userGroup)",
    "desc": "#(userGroupDesc)",
    "id": "#(userGroupId)",
    "expirationOffsetInDays": 730
    }
    """
    When method POST

  @CreateUser
  Scenario: Create user
    Given path 'users'
    And request
    """
    {
    "username": "#(username)",
    "id": "#(userid)",
    "barcode": "#(userBarcode)",
    "active": true,
    "type": "patron",
    "patronGroup": "#(userGroupId)"
    }
    """
    When method POST

  @CreateItemLoan
  Scenario: Create item for loanEvent.feature
    Given path 'inventory/items'
    And request
    """
    {
    "id": "#(itemIdLoan)",
    "barcode": "#(itemBarcodeLoan)",
    "status": {
        "name": "Available"
    },
    "materialType": {
        "id": "#(materialTypeId)"
    },
    "permanentLoanType": {
        "id": "#(loanTypeId)"
    },
    "holdingsRecordId": "#(holdingsRecordId)"
    }
    """
    When method POST

  @CreateItemRequest
  Scenario: Create item for requestEvent.feature
    Given path 'inventory/items'
    And request
    """
    {
    "id": "#(itemIdRequest)",
    "barcode": "#(itemBarcodeRequest)",
    "status": {
        "name": "Available"
    },
    "materialType": {
        "id": "#(materialTypeId)"
    },
    "permanentLoanType": {
        "id": "#(loanTypeId)"
    },
    "holdingsRecordId": "#(holdingsRecordId)"
    }
    """
    When method POST

  @CreateItemCheckInCheckOut
  Scenario: Create item for requestEvent.feature
    Given path 'inventory/items'
    And request
    """
    {
    "id": "#(itemIdCheckInCheckOut)",
    "barcode": "#(itemBarcodeCheckInCheckOut)",
    "status": {
        "name": "Available"
    },
    "materialType": {
        "id": "#(materialTypeId)"
    },
    "permanentLoanType": {
        "id": "#(loanTypeId)"
    },
    "holdingsRecordId": "#(holdingsRecordId)"
    }
    """
    When method POST

  @CreateLoanPolicy
  Scenario: Create loan policy
    Given path 'loan-policy-storage/loan-policies'
    And request
    """
    {
    "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
    "name": "#(loanPolicyName)",
    "loanable": true,
    "loansPolicy": {
        "profileId": "Rolling",
        "period": {
            "duration": 1,
            "intervalId": "Hours"
        },
        "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE_TIME"
    },
    "renewable": true,
    "renewalsPolicy": {
        "unlimited": false,
        "numberAllowed": 3.0,
        "renewFromId": "SYSTEM_DATE",
        "differentPeriod": false
    }
    }
    """
    When method POST

  @CreateRequestPolicy
  Scenario: Create request policy
    Given path 'request-policy-storage/request-policies'
    And request
    """
    {
    "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
    "name": "#(requestPolicyName)",
    "description": "Allow all request types",
    "requestTypes": [
        "Hold",
        "Page",
        "Recall"
    ]
    }
    """
    When method POST

  @CreateNoticePolicy
  Scenario: Create notice policy
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request
    """
    {
    "id": "122b3d2b-4788-4f1e-9117-56daa91cb75c",
    "name": "#(patronNoticePolicyName)",
    "description": "A basic notice policy that does not define any notices",
    "active": true,
    "loanNotices": [],
    "feeFineNotices": [],
    "requestNotices": []
    }
    """
    When method POST

  @CreateOverdueFinePolicy
  Scenario: Create overdue fine policy
    Given path 'overdue-fines-policies'
    And request
    """
    {
    "name": "#(overdueFinePolicyName)",
    "description": "Test overdue fine policy",
    "countClosed": true,
    "maxOverdueFine": 0.0,
    "forgiveOverdueFine": true,
    "gracePeriodRecall": true,
    "maxOverdueRecallFine": 0.0,
    "id": "cd3f6cac-fa17-4079-9fae-2fb28e521412"
    }
    """
    When method POST

  @CreateLostItemFeesPolicy
  Scenario: Create lost item fees policy
    Given path 'lost-item-fees-policies'
    And request
    """
    {
    "name": "#(lostItemFeesPolicyName)",
    "description": "Test lost item fee policy",
    "chargeAmountItem": {
        "chargeType": "actualCost",
        "amount": 0.0
    },
    "lostItemProcessingFee": 0.0,
    "chargeAmountItemPatron": true,
    "chargeAmountItemSystem": true,
    "lostItemChargeFeeFine": {
        "duration": 2,
        "intervalId": "Days"
    },
    "returnedLostItemProcessingFee": true,
    "replacedLostItemProcessingFee": true,
    "replacementProcessingFee": 0.0,
    "replacementAllowed": true,
    "lostItemReturned": "Charge",
    "id": "ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
    }
    """
    When method POST

  @CirculationRules
  Scenario: Update circulation rules
    Given path 'circulation/rules'
    And request
    """
    {
    "id": "1721f01b-e69d-5c4c-5df2-523428a04c55",
    "rulesAsText": "priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709 \nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
    }
    """
    When method PUT
    * callonce sleep 5