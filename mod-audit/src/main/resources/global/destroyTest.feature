Feature: remove all test data

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * callonce variables

  @DeleteItem
  Scenario: Delete item
    Given path 'inventory/items', itemId
    When method DELETE

  @DeleteMaterialType
  Scenario: Delete material type
    Given path 'material-types', materialTypeId
    When method DELETE

  @DeleteHolding
  Scenario: Delete holding
    Given path 'holdings-storage/holdings', holdingsRecordId
    When method DELETE

  @DeleteInstance
  Scenario: Delete instance
    Given path 'instance-storage/instances', instanceId
    When method DELETE

  @DeleteInstanceType
  Scenario: Delete instance type
    Given path 'instance-types', instanceTypeId
    When method DELETE

  @DeleteLoanType
  Scenario: Delete loan type
    Given path 'loan-types', loanTypeId
    When method DELETE

  @DeleteUser
  Scenario: Delete user
    Given path 'users', userid
    When method DELETE

  @DeleteServicePoint
  Scenario: Delete user
    Given path 'service-points', servicePointId
    When method DELETE