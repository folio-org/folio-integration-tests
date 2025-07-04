Feature: Get funds without providing filter query should take into account acquisition units

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * def res = callonce getUserIdByUsername { user: '#(testUser)' }
    * def testUserId = res.userId

    * callonce variables

    * def fundAllowFundViewAcqUnitId = callonce uuid1
    * def restrictFundViewAcqUnitId = callonce uuid2
    * def externalAccountNo = "1691111111111169"

    * def fundNoAcqId = callonce uuid3
    * def fundAllowViewAcqId = callonce uuid4
    * def fundRestrictViewAcqId = callonce uuid5
    * def fundAllowViewAndRestrictViewAcqId = callonce uuid6

  Scenario Outline: Setup acq units <name>
    * def acqUnitId = <acqUnitId>
    * def name = <name>
    * def protectCreate = <protectCreate>
    * def protectRead = <protectRead>
    * def protectUpdate = <protectUpdate>
    * def protectDelete = <protectDelete>
    Given path 'acquisitions-units/units'
    And headers headersAdmin
    And request
    """
      {
        "id": "#(acqUnitId)",
        "name": "#(name)",
        "isDeleted": "false",
        "protectCreate": "#(protectCreate)",
        "protectRead": "#(protectRead)",
        "protectUpdate": "#(protectUpdate)",
        "protectDelete": "#(protectDelete)"
      }
    """
    When method POST
    Then status 201
    Examples:
      | acqUnitId                 | name                         |protectCreate|protectRead|protectUpdate|protectDelete|
      | fundAllowFundViewAcqUnitId| 'TST_ALLOW_FUND_VIEW_ACQ'    |false        |false      |true         |true         |
      | restrictFundViewAcqUnitId | 'TST_RESTRICT_FUND_VIEW_ACQ' |true         |true       |false        |true         |

  Scenario Outline: Setup funds with appropriate acq units <code>
    * def fundId = <fundId>
    * def code = <code>
    * def acqUnitIds = <acqUnitIds>
    Given path 'finance-storage/funds'
    And headers headersUser
    And request
    """
    {
      "id": "#(fundId)",
      "code": "#(code)",
      "name": "Fund for orders API Tests no ACQ UNITS",
      "description": "Fund for orders API Tests #(code)",
      "externalAccountNo": "#(externalAccountNo)",
      "fundStatus": "Active",
      "ledgerId": "#(globalLedgerId)",
      "acqUnitIds": "#(acqUnitIds)"
    }
    """
    When method POST
    Then status 201
    Examples:
      | fundId                            | code                                   |acqUnitIds                                                   |
      | fundNoAcqId                       | 'TST_FND_NO_ACQ'                       |[]                                                           |
      | fundAllowViewAcqId                | 'TST_ALLOW_FUND_VIEW_ACQ'              |[#(fundAllowFundViewAcqUnitId)]                              |
      | fundRestrictViewAcqId             | 'TST_RESTRICT_FUND_VIEW_ACQ'           |[#(restrictFundViewAcqUnitId)]                               |
      | fundAllowViewAndRestrictViewAcqId | 'TST_ALLOW_AND_RESTRICT_FUND_VIEW_ACQ' |[#(fundAllowFundViewAcqUnitId), #(restrictFundViewAcqUnitId)]|

  Scenario: Verify get funds without providing query and user doesn't belong to any acq units
    Given path 'finance/funds'
    And param query = 'externalAccountNo==' + externalAccountNo
    And headers headersUser
    When method GET
    Then status 200
    * def funds = $.funds
    And match $.totalRecords == 3
    And match funds[*].id contains ["#(fundNoAcqId)", "#(fundAllowViewAcqId)", "#(fundAllowViewAndRestrictViewAcqId)"]

  Scenario: Assign restrict view acquisitions units memberships to user
    Given path 'acquisitions-units/memberships'
    And headers headersAdmin
    And request
    """
    {
      "userId": "#(testUserId)",
      "acquisitionsUnitId": "#(restrictFundViewAcqUnitId)"
    }
    """
    When method POST
    Then status 201

  Scenario: Verify get funds without providing query and user has restrict view acquisitions units memberships
    Given path 'finance/funds'
    And param query = 'externalAccountNo==' + externalAccountNo
    And headers headersUser
    When method GET
    Then status 200
    * def funds = $.funds
    And match $.totalRecords == 4
    And match funds[*].id contains ["#(fundNoAcqId)", "#(fundAllowViewAcqId)", "#(fundRestrictViewAcqId)","#(fundAllowViewAndRestrictViewAcqId)"]

  Scenario: Assign allow view acquisitions units memberships to user
    Given path 'acquisitions-units/memberships'
    And headers headersAdmin
    And param query = 'acquisitionsUnitId==' + restrictFundViewAcqUnitId + ' and userId==' + testUserId
    When method GET
    Then status 200
    * def acqMember = $.acquisitionsUnitMemberships[0]
    * def acqMemberId = acqMember.id

    Given path 'acquisitions-units/memberships', acqMemberId
    * set acqMember.acquisitionsUnitId = fundAllowFundViewAcqUnitId
    * remove acqMember.metadata
    And headers headersAdmin
    And header Accept = 'text/plain'
    And request acqMember
    When method PUT
    Then status 204

  Scenario: Verify get funds without providing query and user has allow view acquisitions units memberships
    Given path 'finance/funds'
    And param query = 'externalAccountNo==' + externalAccountNo
    And headers headersUser
    When method GET
    Then status 200
    * def funds = $.funds
    And match $.totalRecords == 3
    And match funds[*].id contains ["#(fundNoAcqId)", "#(fundAllowViewAcqId)","#(fundAllowViewAndRestrictViewAcqId)"]

  Scenario: Again assign restrict view acquisitions units memberships to user
    Given path 'acquisitions-units/memberships'
    And headers headersAdmin
    And request
    """
    {
      "userId": "#(testUserId)",
      "acquisitionsUnitId": "#(restrictFundViewAcqUnitId)"
    }
    """
    When method POST
    Then status 201

  Scenario: Verify get funds without providing query and user has both allow and restrict view acquisitions units memberships
    Given path 'finance/funds'
    And param query = 'externalAccountNo==' + externalAccountNo
    And headers headersUser
    When method GET
    Then status 200
    * def funds = $.funds
    And match $.totalRecords == 4
    And match funds[*].id contains ["#(fundNoAcqId)", "#(fundAllowViewAcqId)", "#(fundRestrictViewAcqId)","#(fundAllowViewAndRestrictViewAcqId)"]

  Scenario Outline: DELETE acquisitions units and memberships <acqUnitId>
    * def acqUnitId = <acqUnitId>
    Given path 'acquisitions-units/memberships'
    And headers headersAdmin
    And param query = 'acquisitionsUnitId==' + acqUnitId + ' and userId==' + testUserId
    When method GET
    Then status 200
    * def acqMember = $.acquisitionsUnitMemberships[0]
    * def acqMemberId = acqMember.id

    Given path 'acquisitions-units/memberships', acqMemberId
    And headers headersAdmin
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    Given path 'acquisitions-units/units', acqUnitId
    And headers headersAdmin
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204
  Examples:
    | acqUnitId                 |
    | fundAllowFundViewAcqUnitId|
    | restrictFundViewAcqUnitId |

  Scenario Outline: DELETE funds <fundId>
    * def fundId = <fundId>
    Given path 'finance-storage/funds', fundId
    And headers headersUser
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204
    Examples:
      | fundId                            |
      | fundNoAcqId                       |
      | fundAllowViewAcqId                |
      | fundRestrictViewAcqId             |
      | fundAllowViewAndRestrictViewAcqId |
