Feature: mod-data-import integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 300000

    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      # We must enable mod-data-import and friends later...see scenario 'install mod-data-import' below

    * table userPermissions
      | name |
      # Actual DI permissions must be added later as the module is installed later
      # done as part of initialize scenario/feature below

  Scenario: create tenant and users for testing
    * call read('classpath:common/setup-users.feature')

    # mod-data-import requires authtoken, however, `setup-users.feature` must run before authtoken is enabled
    # therefore, we must enable DI after initialization is complete.
    # Also, it seems like mod-entities-links (depended on my mod-SRM, mod-SRS, and others) requires authtoken
    # to be installed (even though it does not actually depend the on authtoken interface), causing module
    # install to fail unless authtoken is present.  Therefore, it and the other related modules are all installed
    # after the users are created and authtoken is enabled.
  Scenario: install mod-data-import
    * table diModules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-users-bl'              |
      | 'mod-configuration'         |
      | 'mod-source-record-storage' |
      | 'mod-source-record-manager' |
      | 'mod-inventory-storage'     |
      | 'mod-di-converter-storage'  |
      | 'mod-inventory'             |
      | 'mod-data-export'           |
      | 'mod-data-import'           |
      | 'mod-organizations-storage' |
      | 'mod-invoice'               |
      | 'mod-invoice-storage'       |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-finance'               |
      | 'mod-finance-storage'       |
      | 'mod-copycat'               |
      | 'mod-organizations'         |
      | 'mod-entities-links'        |

    * call login admin
    * def checkDepsDuringModInstall = karate.get('checkDepsDuringModInstall', 'true')
    * call read('classpath:common/tenant.feature@install') ({ modules: diModules, tenant: testTenant, depCheck: checkDepsDuringModInstall })

  Scenario: Load permissions and reference data
    Given call read("initialize.feature")
