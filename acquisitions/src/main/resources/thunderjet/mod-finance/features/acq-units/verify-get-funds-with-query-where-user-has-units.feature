Feature: Get funds where filter is provided should take into account acquisition units

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_finance'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * callonce variables

#    * def fundAllowFundViewAcqUnitId = "19d6b6ed-54d7-4ab5-977c-0e67166c1ceb"
#    * def restrictFundViewAcqUnitId = "19d6b6ed-54d7-4ab5-977c-0e67166c2ceb"
#    * def externalAccountNo = "16922222222269"
#
#    * def fundNoAcqId = "29d6b6ed-54d7-4ab5-977c-0e67166c1ceb"
#    * def fundAllowViewAcqId = "29d6b6ed-54d7-4ab5-977c-0e67166c2ceb"
#    * def fundRestrictViewAcqId = "29d6b6ed-54d7-4ab5-977c-0e67166c3ceb"
#    * def fundAllowViewAndRestrictViewAcqId = "29d6b6ed-54d7-4ab5-977c-0e67166c4ceb"

    * def fundAllowFundViewAcqUnitId = callonce uuid1
    * def restrictFundViewAcqUnitId = callonce uuid2
    * def externalAccountNo = "16922222222269"

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
    Given path 'acquisitions-units-storage/units'
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
      | acqUnitId                 | name                           |protectCreate|protectRead|protectUpdate|protectDelete|
      | fundAllowFundViewAcqUnitId| 'TST_ALLOW_FUND_VIEW_ACQ_1'    |false        |false      |true         |true         |
      | restrictFundViewAcqUnitId | 'TST_RESTRICT_FUND_VIEW_ACQ_1' |true         |true       |false        |true         |

  Scenario Outline: Setup funds with appropriate acq units <code>
    * def fundId = <fundId>
    * def code = <code>
    * def acqUnitIds = <acqUnitIds>
    Given path 'finance-storage/funds'
    And headers headersAdmin
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
      | fundId                            | code                                     |acqUnitIds                                                   |
      | fundNoAcqId                       | 'TST_FND_NO_ACQ_1'                       |[]                                                           |
      | fundAllowViewAcqId                | 'TST_ALLOW_FUND_VIEW_ACQ_1'              |[#(fundAllowFundViewAcqUnitId)]                              |
      | fundRestrictViewAcqId             | 'TST_RESTRICT_FUND_VIEW_ACQ_1'           |[#(restrictFundViewAcqUnitId)]                               |
      | fundAllowViewAndRestrictViewAcqId | 'TST_ALLOW_AND_RESTRICT_FUND_VIEW_ACQ_1' |[#(fundAllowFundViewAcqUnitId), #(restrictFundViewAcqUnitId)]|

  Scenario: Verify get funds with providing query and user doesn't belong to any acq units
    Given path 'finance/funds'
    And param query = 'externalAccountNo==' + externalAccountNo + ' and (acqUnitIds==*\"'+ restrictFundViewAcqUnitId +'\"*)'
    And headers headersUser
    When method GET
    Then status 200
    * def funds = $.funds
    And match $.totalRecords == 1
    And match funds[*].id contains ["#(fundAllowViewAndRestrictViewAcqId)"]

  Scenario: Assign restrict view acquisitions units memberships to user
    Given path 'acquisitions-units-storage/memberships'
    And headers headersAdmin
    And request
    """
    {
      "userId": "00000000-1111-5555-9999-999999999992",
      "acquisitionsUnitId": "#(restrictFundViewAcqUnitId)"
    }
    """
    When method POST
    Then status 201

  Scenario: Verify get funds with providing query and user has restrict view acquisitions units memberships
    Given path 'finance/funds'
    And param query = 'externalAccountNo==' + externalAccountNo + ' and (acqUnitIds==*\"'+ restrictFundViewAcqUnitId +'\"*)'
    And headers headersUser
    When method GET
    Then status 200
    * def funds = $.funds
    And match $.totalRecords == 2
    And match funds[*].id contains ["#(fundRestrictViewAcqId)","#(fundAllowViewAndRestrictViewAcqId)"]

  Scenario: Assign allow view acquisitions units memberships to user
    Given path 'acquisitions-units-storage/memberships'
    And headers headersAdmin
    And param query = 'acquisitionsUnitId==' + restrictFundViewAcqUnitId + ' and userId==00000000-1111-5555-9999-999999999992'
    When method GET
    Then status 200
    * def acqMember = $.acquisitionsUnitMemberships[0]
    * def acqMemberId = acqMember.id

    Given path 'acquisitions-units-storage/memberships', acqMemberId
    * set acqMember.acquisitionsUnitId = fundAllowFundViewAcqUnitId
    * remove acqMember.metadata
    And headers headersAdmin
    And header Accept = 'text/plain'
    And request acqMember
    When method PUT
    Then status 204

  Scenario: Verify get funds with providing query and user has allow view acquisitions units memberships
    Given path 'finance/funds'
    And param query = 'externalAccountNo==' + externalAccountNo + ' and (acqUnitIds==*\"'+ restrictFundViewAcqUnitId +'\"*)'
    And headers headersUser
    When method GET
    Then status 200
    * def funds = $.funds
    And match $.totalRecords == 1
    And match funds[*].id contains ["#(fundAllowViewAndRestrictViewAcqId)"]

  Scenario: Again assign restrict view acquisitions units memberships to user
    Given path 'acquisitions-units-storage/memberships'
    And headers headersAdmin
    And request
    """
    {
      "userId": "00000000-1111-5555-9999-999999999992",
      "acquisitionsUnitId": "#(restrictFundViewAcqUnitId)"
    }
    """
    When method POST
    Then status 201

  Scenario: Verify get funds without providing query and user has both allow and restrict view acquisitions units memberships
    Given path 'finance/funds'
    And param query = 'externalAccountNo==' + externalAccountNo + ' and (acqUnitIds==*\"'+ restrictFundViewAcqUnitId +'\"* or acqUnitIds==*\"'+ fundAllowFundViewAcqUnitId +'\"*)'
    And headers headersUser
    When method GET
    Then status 200
    * def funds = $.funds
    And match $.totalRecords == 3
    And match funds[*].id contains ["#(fundAllowViewAcqId)", "#(fundRestrictViewAcqId)","#(fundAllowViewAndRestrictViewAcqId)"]

  Scenario Outline: DELETE acquisitions units and memberships <acqUnitId>
    * def acqUnitId = <acqUnitId>
    Given path 'acquisitions-units-storage/memberships'
    And headers headersAdmin
    And param query = 'acquisitionsUnitId==' + acqUnitId + ' and userId==00000000-1111-5555-9999-999999999992'
    When method GET
    Then status 200
    * def acqMember = $.acquisitionsUnitMemberships[0]
    * def acqMemberId = acqMember.id

    Given path 'acquisitions-units-storage/memberships', acqMemberId
    And headers headersAdmin
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    Given path 'acquisitions-units-storage/units', acqUnitId
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
    And headers headersAdmin
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204
    Examples:
      | fundId                            |
      | fundNoAcqId                       |
      | fundAllowViewAcqId                |
      | fundRestrictViewAcqId             |
      | fundAllowViewAndRestrictViewAcqId |