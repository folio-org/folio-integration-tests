Feature: Test integration with inventory-storage into /oai-pmh/filtering-conditions endpoint logic

  Background:
    * def filteringConditionsUrl = baseUrl + '/oai-pmh/filtering-conditions'
    * url filteringConditionsUrl
    #=========================SETUP================================================
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }
    * callonce read('classpath:global/init_data/setup-filtering-conditions-data.feature')

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
    And match $.setsFilteringConditions contains {name:"format", values:["audio -- audio belt","instanceFormat"]}
    And match $.setsFilteringConditions contains {name:"resourceType", values:["instanceType"]}
    And match $.setsFilteringConditions contains {name:"location", values:["location"]}
    And match $.setsFilteringConditions contains {name:"materialType", values:["materialType"]}