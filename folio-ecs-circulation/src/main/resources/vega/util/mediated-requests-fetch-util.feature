@ignore
Feature: Reusable fetch helpers for mediated-requests scenarios (requests, items, circulation items)

  # These scenarios rely on the caller having already set the desired tenant headers
  # (e.g. `* configure headers = headersCentral`) before invoking them with `call`.
  # Karate shares the calling scenario's variable/config scope with the called feature,
  # so there is no need to pass okapitoken/tenant explicitly - only the identifiers vary.

  Background:
    * url baseUrl

  # Parameters accepted by @FetchRequestStorageRequest:
  #   requestId   - request-storage request UUID
  # Returns: request (the fetched request-storage request body)
  @FetchRequestStorageRequest
  Scenario: fetch a request from request-storage in the currently configured tenant
    Given path 'request-storage/requests', requestId
    When method GET
    Then status 200
    * def request = response

  # Parameters accepted by @FetchInventoryItem:
  #   itemId      - item-storage item UUID
  # Returns: item (the fetched item-storage item body)
  @FetchInventoryItem
  Scenario: fetch an item from item-storage in the currently configured tenant
    Given path 'item-storage/items', itemId
    When method GET
    Then status 200
    * def item = response

  # Parameters accepted by @FetchCirculationItem:
  #   itemId      - circulation item UUID
  # Returns: item (the fetched circulation item body)
  @FetchCirculationItem
  Scenario: fetch a circulation item in the currently configured tenant
    Given path 'circulation-item', itemId
    When method GET
    Then status 200
    * def item = response
