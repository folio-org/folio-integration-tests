Feature: mod bulk operations user features

  Background:
    * callonce read('init-data/init-data-for-users.feature')

  Scenario: mod bulk operations update user positive scenario
    * call read('users-positive-scenarios.feature')

  Scenario: mod bulk operations update user negative scenario
    * call read('users-negative-scenarios.feature')

