Feature: remove all test data

  Background:
    * url baseUrl
    * callonce login testAdmin
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

  @DeleteUserGroup
  Scenario: Delete user group
    Given path 'groups', userGroupId
    When method DELETE

  @DeleteServicePoint
  Scenario: Delete user
    Given path 'service-points', servicePointId
    When method DELETE

  @DeleteServicePointNoPickup
  Scenario: Delete user
    Given path 'service-points', servicePointNoPickupId
    When method DELETE

  @DeleteLocation
  Scenario: Delete location
    Given path 'locations', locationId
    When method DELETE

  @DeleteLibrary
  Scenario: Delete library
    Given path 'location-units/libraries', libraryId
    When method DELETE

  @DeleteCampus
  Scenario: Delete campus
    Given path 'location-units/campuses', campusId
    When method DELETE

  @DeleteInstitution
  Scenario: Delete institution
    Given path 'location-units/institutions', institutionId
    When method DELETE

  @DeleteLoanPolicy
  Scenario: Delete loan policy
    Given path 'loan-policy-storage/loan-policies', 'd9cd0bed-1b49-4b5e-a7bd-064b8d177231'
    When method DELETE

  @DeleteRequestPolicy
  Scenario: Delete request policy
    Given path 'request-policy-storage/request-policies', 'd9cd0bed-1b49-4b5e-a7bd-064b8d177231'
    When method DELETE

  @DeleteNoticePolicy
  Scenario: Delete notice policy
    Given path 'patron-notice-policy-storage/patron-notice-policies', '122b3d2b-4788-4f1e-9117-56daa91cb75c'
    When method DELETE

  @DeleteOverdueFinePolicy
  Scenario: Delete overdue fine policy
    Given path 'overdue-fines-policies', 'cd3f6cac-fa17-4079-9fae-2fb28e521412'
    When method DELETE

  @DeleteLostItemFeesPolicy
  Scenario: Delete lost item fees policy
    Given path 'lost-item-fees-policies', 'ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    When method DELETE