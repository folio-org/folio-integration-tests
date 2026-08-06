@ignore
Feature: Reusable request/item storage helpers for mediated-requests scenarios (GET, POST, PUT, DELETE, etc.)

  # These scenarios rely on the caller having already set the desired tenant headers
  # (e.g. `* configure headers = headersCentral`) before invoking them with `call`.
  # Karate shares the calling scenario's variable/config scope with the called feature,
  # so there is no need to pass okapitoken/tenant explicitly - only the identifiers vary.

  Background:
    * url baseUrl

  @GetRequest
  Scenario: fetch a request from request-storage in the currently configured tenant
    Given path 'request-storage/requests', requestId
    When method GET
    Then status 200

  @GetItem
  Scenario: fetch an item from item-storage in the currently configured tenant
    Given path 'item-storage/items', itemId
    When method GET
    Then status 200

  @GetCirculationItem
  Scenario: fetch a circulation item in the currently configured tenant
    Given path 'circulation-item', itemId
    When method GET
    Then status 200

  @GetMediatedRequest
  Scenario: fetch a mediated request in the currently configured tenant
    Given path 'requests-mediated/mediated-requests', mediatedRequestId
    When method GET
    Then status 200
