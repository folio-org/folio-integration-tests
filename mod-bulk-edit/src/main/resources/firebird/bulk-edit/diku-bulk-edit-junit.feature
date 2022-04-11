Feature: bulk-edit integration tests

  Background:
    * url baseUrl

  Scenario: setup users for testing
    Given call read('classpath:global/diku-setup-users.feature')

  Scenario: init test data
    * callonce read('classpath:global/mod_users_init_data.feature')