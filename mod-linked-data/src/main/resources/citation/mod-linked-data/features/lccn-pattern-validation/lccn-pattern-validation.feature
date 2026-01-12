Feature: LCCN pattern validation

  Background:
    * url baseUrl

    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  @C624318
  Scenario: Create resources with enabled validation and then repeat with disabled validation
    # Step 1: Enable validation
    * configure headers = testAdminHeaders
    * def getSpecificationsCall = call getSpecifications { profileParam: "bibliographic", familyParam: "MARC" }
    * def specificationId = getSpecificationsCall.response.specifications[0].id
    * def getRulesCall = call getRules { specificationId: '#(specificationId)' }
    * def ruleId = karate.filter(getRulesCall.response.rules, function (rule) { return rule.code === "invalidLccnSubfieldValue" })[0].id
    * call patchRule { specificationId: '#(specificationId)', ruleId: '#(ruleId)', isEnabled: true }

    # Step 2: Create a work
    * configure headers = testUserHeaders
    * def workRequest = read('samples/work-request.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    * def workId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'].id

    # Step 3: Create valid instance
    * def validInstanceRequest = read('samples/valid-instance-request.json')
    * call postResource { resourceRequest: '#(validInstanceRequest)' }

    # Step 4: Fail to create invalid instance
    * def invalidInstanceRequest = read('samples/invalid-instance-request.json')
    Given path 'linked-data/resource'
    And request invalidInstanceRequest
    When method POST
    Then status 400
    And match $.errors[0].code == "lccn_does_not_match_pattern"

    # Step 5: Disable validation
    * configure headers = testAdminHeaders
    * call patchRule { specificationId: '#(specificationId)', ruleId: '#(ruleId)', isEnabled: false }

    # Step 6: Create invalid instance
    * configure headers = testUserHeaders
    * call postResource { resourceRequest: '#(invalidInstanceRequest)' }