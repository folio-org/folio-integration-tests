Feature: create user, item, service point

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * callonce variables

  @CreateInstanceType
  Scenario: create instance type
    Given path 'instance-types'
    And request
    """
    {
    "id": "#(instanceTypeId)",
    "name": "test name6",
    "code": "test code6",
    "source": "test source6"
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
    "source": "test source6",
    "instanceTypeId": "#(instanceTypeId)",
    "title": "test title6"
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
    "name": "test name6"
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
    "name": "test name6"
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
    "patronGroup": "3684a786-6671-4268-8ed0-9db82ebca60b"
    }
    """
    When method POST

  @CreateItem
  Scenario: Create item
    Given path 'inventory/items'
    And request
    """
    {
    "id": "#(itemId)",
    "barcode": "#(itemBarcode)",
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

  @CreateServicePoint
  Scenario: Create service point
    Given path 'service-points'
    And request
    """
    {
    "id": "#(servicePointId)",
    "code": "test code6",
    "name": "test name6",
    "discoveryDisplayName": "test",
    "pickupLocation": true,
    "holdShelfExpiryPeriod": {
       "duration": 10,
          "intervalId": "Weeks"
       }
    }
    """
    When method POST