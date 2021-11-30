Feature: oai-pmh basic tests
  #
  # Tests according to http://www.openarchives.org/Register/ValidateSite
  #
  Background:
    * table modules
      | name                              |
      | 'mod-permissions'                 |
      | 'mod-oai-pmh'                     |
      | 'mod-login'                       |
      | 'mod-configuration'               |
      | 'mod-source-record-storage'       |

    * table userPermissions
      | name                              |
      | 'oai-pmh.all'                     |
      | 'configuration.all'               |
      | 'inventory-storage.all'           |
      | 'source-storage.all'              |

    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    * configure afterFeature =  function(){ karate.call('classpath:common/destroy-data.feature', {tenant: testUser.tenant})}
    #=========================SETUP================================================
    * callonce read('classpath:common/tenant.feature@create')
    * callonce read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testUser.tenant)'}
    * callonce read('classpath:common/setup-users.feature')
    * callonce read('classpath:common/login.feature') testUser
    * def testUserToken = responseHeaders['x-okapi-token'][0]
    * callonce read('classpath:common/setup-data.feature')
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/xml', 'x-okapi-token': '#(testUserToken)', 'x-okapi-tenant': '#(testUser.tenant)' }
    #=========================SETUP=================================================

    * def checkDateByRegEx = '#regex \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z'

    * callonce read('classpath:firebird/oaipmh/verbs/get_record.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/identify.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/list_identifiers.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/list_records.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/list_sets.feature')
    * callonce read('classpath:firebird/oaipmh/verbs/metadata_prefix.feature')


    # Common Unhappy path cases

  Scenario: check badVerb error
    Given param verb = 'junk'
    When method GET
    Then status 400

  Scenario: check badVerb error with only parameter junk
    And param junk = 'junk'
    When method GET
    Then status 400

  Scenario: check badArgument error
    Given param verb = 'ListRecord'
    When method GET
    Then status 400
