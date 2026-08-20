@FqmManagerTeardown
Feature: destroy mod-fqm-manager test data

  Scenario: destroy data for tenant
    Given call read('classpath:common/eureka/destroy-data.feature')
