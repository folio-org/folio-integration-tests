# For FAT-XXXX, Create Karate tests for ILR and TLR ECS requests via edge-patron
@parallel=false
Feature: Cross-Module Integration Tests for ILR and TLR ECS Requests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create ECS TLR request
    * call read('classpath:consortia/features/batch-ecs-requests.feature')
