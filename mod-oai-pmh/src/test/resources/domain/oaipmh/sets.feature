Feature: Test enhancements to oai-pmh

  Background:
    * table modules
      | name                              |
      | 'mod-permissions'                 |
      | 'mod-oai-pmh'                     |
      | 'mod-login'                       |
      | 'mod-inventory-storage'           |

    * table userPermissions
      | name                              |
      | 'oai-pmh.all'                     |
      | 'configuration.all'               |
      | 'inventory-storage.all'           |
      | 'source-storage.all'              |

    * def filteringConditionsUrl = baseUrl + '/oai-pmh/filtering-conditions'
    * url filteringConditionsUrl
    * configure afterFeature =  function(){ karate.call(destroyData, {tenant: testUser.tenant})}
    #=========================SETUP================================================
    * callonce read('classpath:common/tenant.feature@create')
    * callonce read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testUser.tenant)'}
    * callonce read('classpath:common/setup-users.feature')
    * callonce read('classpath:common/login.feature') testUser
    * def testUserToken = responseHeaders['x-okapi-token'][0]
    * callonce read('classpath:global/init_data/setup-filtering-conditions-data.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(testUserToken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: should return filtering-conditions values composed from inventory entities: ill-policy, instanceType, instanceFormat, location and materialType
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def configGroups = get $.setsFilteringConditions[*].name
    And match configGroups contains 'location'
    And match configGroups contains 'illPolicy'
    And match configGroups contains 'materialType'
    And match configGroups contains 'resourceType'
    And match configGroups contains 'format'
    And match $.setsFilteringConditions contains {name:"illPolicy", values:["illPolicy"]}
    And match $.setsFilteringConditions contains {name:"format", values:["instanceFormat"]}
    And match $.setsFilteringConditions contains {name:"resourceType", values:["instanceType"]}
    And match $.setsFilteringConditions contains {name:"location", values:["location"]}
    And match $.setsFilteringConditions contains {name:"materialType", values:["materialType"]}