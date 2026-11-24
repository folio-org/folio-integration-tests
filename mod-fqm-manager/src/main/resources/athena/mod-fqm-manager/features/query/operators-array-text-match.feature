# For MODFQMMGR-1208, https://foliotest.testrail.io/index.php?/cases/view/1632020, https://foliotest.testrail.io/index.php?/cases/view/1632021
Feature: Text Match Operators On Repeatable Fields

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def organizationsEntityTypeId = 'e0ea4212-4023-458a-adce-8003ff6c5d9e'
    * def notesField = 'organization.accounts[*]->notes'
    * def specialNote = 'NOTE<"library\'s purchasing credentials -- username (texas) and pword (texas987)" per email from vendor 1/28/26/TOrtiz>'
    * def searchedText = '"library\'s purchasing credentials -- username (texas) and pword (texas987)" per email from vendor 1/28/26/TOrtiz'
    * def splitNoteStart = 'Vendor discussion referenced "library\'s purchasing cred'
    * def splitNoteEnd = 'entials -- username (texas) and pword (texas987)" per email from vendor 1/28/26/TOrtiz'
    * def notePrefix = 'NOTE<"library\'s purchasing'
    * def buildQuery =
      """
      function(operator, value, codes) {
        var condition = {};
        condition[notesField] = {};
        condition[notesField][operator] = value;
        return JSON.stringify({ '$and': [ condition, { 'organization.code': { '$in': codes } } ] });
      }
      """

  @C1632020
  @Positive
  Scenario: Contains Query On Organization Account Notes Returns Only The Organization Whose Single Note Contains The Text
    * def suffix = call random_string
    * def codeA = 'acme-' + suffix
    * def codeB = 'beta-' + suffix
    * def codeC = 'gamma-' + suffix
    * def codes = [ '#(codeA)', '#(codeB)', '#(codeC)' ]
    * def orgAId = call uuid
    * def orgBId = call uuid
    * def orgCId = call uuid

    # Prerequisites: Organization A Has One Account Note Containing The Text, Organization B Has The Text Split Across Two Account Notes, Organization C Has An Unrelated Note
    * def orgA = { id: '#(orgAId)', name: '#("Acme Library Services " + suffix)', code: '#(codeA)', status: 'Active', isVendor: true, accounts: [{ name: 'Account 1', accountNo: '1001', accountStatus: 'Active', notes: '#(specialNote)' }, { name: 'Account 2', accountNo: '1002', accountStatus: 'Active', notes: 'Confirmed renewal terms with vendor accounting contact for FY26.' }] }
    * def orgB = { id: '#(orgBId)', name: '#("Beta Booksellers " + suffix)', code: '#(codeB)', status: 'Active', isVendor: true, accounts: [{ name: 'Account 1', accountNo: '2001', accountStatus: 'Active', notes: '#(splitNoteStart)' }, { name: 'Account 2', accountNo: '2002', accountStatus: 'Active', notes: '#(splitNoteEnd)' }] }
    * def orgC = { id: '#(orgCId)', name: '#("Gamma Supplies " + suffix)', code: '#(codeC)', status: 'Active', isVendor: true, accounts: [{ name: 'Account 1', accountNo: '3001', accountStatus: 'Active', notes: 'Standard net-30 payment terms confirmed with accounting.' }] }

    Given path 'organizations-storage/organizations'
    And request orgA
    When method POST
    Then status 201

    Given path 'organizations-storage/organizations'
    And request orgB
    When method POST
    Then status 201

    Given path 'organizations-storage/organizations'
    And request orgC
    When method POST
    Then status 201

    # 1. Query Organizations Where Account Notes Contain The Text With Special Characters
    * def queryRequest = { entityTypeId: '#(organizationsEntityTypeId)', fqlQuery: '#(buildQuery("$contains", searchedText, codes))' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query', queryId
    And params { includeResults: true, limit: 100, offset: 0 }
    When method GET
    Then status 200
    And match $.status == 'SUCCESS'
    And match $.totalRecords == 1
    And match $.content[*]['organization.code'] == [ '#(codeA)' ]

    # 2. Query Organizations Where Account Notes Contain The Same Text In Upper Case
    * def queryRequest = { entityTypeId: '#(organizationsEntityTypeId)', fqlQuery: '#(buildQuery("$contains", searchedText.toUpperCase(), codes))' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query', queryId
    And params { includeResults: true, limit: 100, offset: 0 }
    When method GET
    Then status 200
    And match $.status == 'SUCCESS'
    And match $.totalRecords == 1
    And match $.content[*]['organization.code'] == [ '#(codeA)' ]

  @C1632021
  @Positive
  Scenario: Equals And Starts With Queries On Organization Account Notes Return The Organization With The Matching Note
    * def suffix = call random_string
    * def codeA = 'acme-' + suffix
    * def codeC = 'gamma-' + suffix
    * def codes = [ '#(codeA)', '#(codeC)' ]
    * def orgAId = call uuid
    * def orgCId = call uuid

    # Prerequisites: Organization A Has One Account Note With Special Characters, Organization C Has An Unrelated Note
    * def orgA = { id: '#(orgAId)', name: '#("Acme Library Services " + suffix)', code: '#(codeA)', status: 'Active', isVendor: true, accounts: [{ name: 'Account 1', accountNo: '1001', accountStatus: 'Active', notes: '#(specialNote)' }] }
    * def orgC = { id: '#(orgCId)', name: '#("Gamma Supplies " + suffix)', code: '#(codeC)', status: 'Active', isVendor: true, accounts: [{ name: 'Account 1', accountNo: '3001', accountStatus: 'Active', notes: 'Standard net-30 payment terms confirmed with accounting.' }] }

    Given path 'organizations-storage/organizations'
    And request orgA
    When method POST
    Then status 201

    Given path 'organizations-storage/organizations'
    And request orgC
    When method POST
    Then status 201

    # 1. Query Organizations Where An Account Note Equals The Full Note Text
    * def queryRequest = { entityTypeId: '#(organizationsEntityTypeId)', fqlQuery: '#(buildQuery("$eq", specialNote, codes))' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query', queryId
    And params { includeResults: true, limit: 100, offset: 0 }
    When method GET
    Then status 200
    And match $.status == 'SUCCESS'
    And match $.totalRecords == 1
    And match $.content[*]['organization.code'] == [ '#(codeA)' ]

    # 2. Query Organizations Where An Account Note Starts With The Beginning Of The Note
    * def queryRequest = { entityTypeId: '#(organizationsEntityTypeId)', fqlQuery: '#(buildQuery("$starts_with", notePrefix, codes))' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query', queryId
    And params { includeResults: true, limit: 100, offset: 0 }
    When method GET
    Then status 200
    And match $.status == 'SUCCESS'
    And match $.totalRecords == 1
    And match $.content[*]['organization.code'] == [ '#(codeA)' ]
