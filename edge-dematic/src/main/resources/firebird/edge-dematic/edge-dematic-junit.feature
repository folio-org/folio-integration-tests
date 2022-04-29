Feature: edge-dematic integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-remote-storage'


    * table adminAdditionalPermissions
      | name  |

    * table userPermissions
      | name               |
      |'remote-storage.all'|


  Scenario: init data
    Given call read('classpath:common/setup-users.feature')
    Given call read('classpath:common/tenant.feature@install') {modules: [{name : 'edge-dematic'}], tenant: '#(testTenant)'}
