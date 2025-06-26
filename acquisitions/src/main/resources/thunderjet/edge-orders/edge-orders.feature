Feature: edge-orders integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create tenant and users for testing
    * call read("classpath:common/eureka/setup-users.feature")

  Scenario: Ebsconet
    Given call read("features/ebsconet.feature")

  Scenario: GOBI
    Given call read("features/gobi.feature")

  Scenario: MOSAIC
    Given call read("features/mosaic.feature")

  Scenario: COMMON
    Given call read("features/common.feature")

  Scenario: Wipe data
    Given call read("classpath:common/eureka/destroy-data.feature")
