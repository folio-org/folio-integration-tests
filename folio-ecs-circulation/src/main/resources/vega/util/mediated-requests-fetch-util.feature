@ignore
Feature: Reusable fetch helpers for mediated-requests scenarios (requests, items, circulation items)

  Background:
    * url baseUrl

  # Parameters accepted by @FetchRequestStorageRequest:
  #   okapitoken  - tenant token
  #   tenant      - tenant name (x-okapi-tenant)
  #   requestId   - request-storage request UUID
  # Returns: request (the fetched request-storage request body)
  @FetchRequestStorageRequest
  Scenario: fetch a request from request-storage in a given tenant
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)' }
    Given path 'request-storage/requests', requestId
    When method GET
    Then status 200
    * def request = response

  # Parameters accepted by @FetchInventoryItem:
  #   okapitoken  - tenant token
  #   tenant      - tenant name (x-okapi-tenant)
  #   itemId      - item-storage item UUID
  # Returns: item (the fetched item-storage item body)
  @FetchInventoryItem
  Scenario: fetch an item from item-storage in a given tenant
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)' }
    Given path 'item-storage/items', itemId
    When method GET
    Then status 200
    * def item = response

  # Parameters accepted by @FetchCirculationItem:
  #   okapitoken  - tenant token
  #   tenant      - tenant name (x-okapi-tenant)
  #   itemId      - circulation item UUID
  # Returns: item (the fetched circulation item body)
  @FetchCirculationItem
  Scenario: fetch a circulation item in a given tenant
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(tenant)' }
    Given path 'circulation-item', itemId
    When method GET
    Then status 200
    * def item = response
