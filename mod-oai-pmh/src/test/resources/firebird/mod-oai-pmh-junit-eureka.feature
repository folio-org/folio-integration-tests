Feature: bulk operations integration tests

  Background:
    * url baseUrl
    * table modules
      | name                              |
      | 'mod-permissions'                 |
      | 'mod-oai-pmh'                     |
      | 'mod-login'                       |
      | 'mod-configuration'               |
      | 'mod-source-record-storage'       |
      | 'mod-inventory-storage'           |

    * table userPermissions
      | name                              |
      | 'oai-pmh.all'                     |
      | 'configuration.all'               |
      | 'inventory-storage.all'           |
      | 'source-storage.all'              |

    * url pmhUrl
    * def checkDateByRegEx = '#regex \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z'
    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal', 'app-oai-pmh']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: init global data
    * callonce read('classpath:firebird/oaipmh/verbs/get_record.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/identify.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/list_identifiers.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/list_records.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/list_sets.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/metadata_prefix.feature')