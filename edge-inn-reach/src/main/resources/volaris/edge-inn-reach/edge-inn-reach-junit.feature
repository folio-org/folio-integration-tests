Feature: edge-inn-reach integration tests

  Background:
    * url baseUrl
    * table modules
      | name  |

    * table userPermissions
      | name  |

  Scenario: init data
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * callonce read('classpath:global/prepare-test-data.feature')