Feature: mod-mosaic integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create tenant and users for testing
    * call read('classpath:common/setup-users.feature')

  # Custom scenario(s):
  Scenario: Validate Order
    Given call read('features/validate-order.feature')

  Scenario: Create Order From Minimal Template
    Given call read('features/create-order-1-from-minimal-template.feature')

  Scenario: Create Order From Default Template
    Given call read('features/create-order-2-from-default-template.feature')

  Scenario: Create Order From Physical Template
    Given call read('features/create-order-3-from-physical-template.feature')

  Scenario: Create Order From Electronic Template
    Given call read('features/create-order-4-from-electronic-template.feature')

  Scenario: Create Order From P/E Mix Template
    Given call read('features/create-order-5-from-pe-mix-template.feature')

  Scenario: Create Order With Open Workflow Status
    Given call read('features/create-order-6-with-open-workflow-status.feature')

  Scenario: Create Order With Check In Items
    Given call read('features/create-order-7-with-check-in-items.feature')

  Scenario: Wipe data
    Given call read('classpath:common/destroy-data.feature')
