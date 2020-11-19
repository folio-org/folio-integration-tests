Feature: data export basic tests
  #
  # Tests according to http://www.openarchives.org/Register/ValidateSite
  #
  Background:
    * table modules
      | name                              |
      | 'mod-permissions'                 |
      | 'mod-data-export'                 |
      | 'mod-login'                       |
      | 'mod-configuration'               |
      | 'mod-source-record-storage'       |

    * table userPermissions
      | name                              |
      | 'data-export.all'                 |
      | 'configuration.all'               |
      | 'inventory-storage.all'           |
      | 'source-storage.all'              |

    * url baseUrl

    * configure afterFeature =  function(){ karate.call(destroyData, {tenant: testUser.tenant})}
    #=========================SETUP================================================
    * callonce read('classpath:common/tenant.feature@create')
    * callonce read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testUser.tenant)'}
    * callonce read('classpath:common/setup-users.feature')
    * callonce read('classpath:common/login.feature') testUser
    * def testUserToken = responseHeaders['x-okapi-token'][0]
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/plain', 'x-okapi-token': '#(testUserToken)', 'x-okapi-tenant': '#(testUser.tenant)' }
    #=========================SETUP=================================================

    * callonce read('classpath:domain/dataexport/mapping-profile.feature')



