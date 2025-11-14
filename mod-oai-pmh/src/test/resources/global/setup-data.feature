Feature: setup date data for tenant

  Background:
    * callonce login testUser

  Scenario: setup test data
    * callonce read('classpath:global/init_data/configuration_init_data.feature')
    * callonce read('classpath:global/init_data/srs_init_data.feature')
    * callonce read('classpath:global/init_data/mod_inventory_init_data.feature')