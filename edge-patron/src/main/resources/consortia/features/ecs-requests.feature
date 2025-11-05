# For FAT-XXXX, Create Karate tests for ILR and TLR ECS requests via edge-patron
@parallel=false
Feature: Cross-Module Integration Tests for ILR and TLR ECS Requests

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    # Create tenants and users, initialize data
    * callonce read('classpath:consortia/init-consortia.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:consortia/destroy-data.feature'); }

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-users'                 |
      | 'mod-login'                 |
      | 'mod-inventory-storage'     |
      | 'mod-pubsub'                |
      | 'mod-circulation-storage'   |
      | 'mod-source-record-manager' |
      | 'mod-entities-links'        |
      | 'mod-inventory'             |
      | 'folio-custom-fields'       |
      | 'edge-patron'               |
      | 'mod-patron'                |
      | 'mod-tlr'                   |
      | 'mod-circulation'           |
      | 'mod-circulation-bff'       |

  Scenario: Create ECS TLR request
    * def proxyConsortiaAdmin =
      """
      {
        name: '#(consortiaAdmin.username)',
        password: '#(consortiaAdmin.password)',
        tenant: '#(centralTenantName)'
      }
      """

