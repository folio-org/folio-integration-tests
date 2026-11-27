# For CIRC-2691, https://foliotest.testrail.io/index.php?/cases/view/1621488, https://foliotest.testrail.io/index.php?/cases/view/1621489, https://foliotest.testrail.io/index.php?/cases/view/1621490, https://foliotest.testrail.io/index.php?/cases/view/1621491, https://foliotest.testrail.io/index.php?/cases/view/1621492
Feature: Check in with in-house use of a checked-out item

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = headersUser
    * def instanceId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def holdingSourceId = call uuid1
    * def holdingSourceName = random_string()
    * def itemId = call uuid1
    * def groupId = call uuid1
    * def getTimeNow = read('classpath:vega/mod-circulation/features/util/get-time-now-function.js')


  @C1621488
  @Negative
  Scenario: In-house use of a checked-out item without confirmation is rejected and nothing changes
    # Prerequisites: service point SP serving location L, item A in location L checked out to patron P
    * def extItemBarcode = 'C1621488-item-' + random_string()
    * def extUserBarcode = 'C1621488-user-' + random_string()
    * def extUserId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

    # 1. Check In Item A At SP With In-House Use, Without Confirming The Override
    * def checkInDate = getTimeNow()
    Given path 'circulation', 'check-in-by-barcode'
    And request { itemBarcode: '#(extItemBarcode)', servicePointId: '#(servicePointId)', checkInDate: '#(checkInDate)', inHouseUse: true }
    When method POST
    Then status 422
    And match response.errors[0].code == 'CHECKED_OUT_ITEM_IN_HOUSE_USE_REQUIRES_CONFIRMATION'
    And match response.errors[0].message == 'Item is checked out. Confirmation is required to check it in and register in-house use'
    And match response.errors[0].overridableBlock == { name: 'checkedOutItemInHouseUseOverride', missingPermissions: [] }

    # 2. Check The Loan Of Item A
    Given path 'circulation', 'loans'
    And param query = 'itemId==' + itemId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.loans[0].status.name == 'Open'

    # 3. Check The Status Of Item A
    Given path 'inventory', 'items', itemId
    When method GET
    Then status 200
    And match response.status.name == 'Checked out'

    # 4. Check The Check-In Records Of Item A
    Given path 'check-in-storage', 'check-ins'
    And param query = 'itemId==' + itemId
    When method GET
    Then status 200
    And match response.totalRecords == 0


  @C1621489
  @Positive
  Scenario: Confirmed in-house use of a checked-out item results in a regular check-in followed by an in-house use check-in
    # Prerequisites: service point SP serving location L, item A in location L checked out to patron P (loan LN)
    * def extItemBarcode = 'C1621489-item-' + random_string()
    * def extUserBarcode = 'C1621489-user-' + random_string()
    * def extUserId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

    # 1. Check In Item A At SP With In-House Use And Confirm The Override
    * def checkInDate = getTimeNow()
    Given path 'circulation', 'check-in-by-barcode'
    And request { itemBarcode: '#(extItemBarcode)', servicePointId: '#(servicePointId)', checkInDate: '#(checkInDate)', inHouseUse: true, checkedOutItemInHouseUseOverride: true }
    When method POST
    Then status 200
    And match response.inHouseUse == false
    And match response.loan.action == 'checkedin'
    And match response.loan.status.name == 'Closed'
    And match response.item.status.name == 'Available'
    And match response.subsequentCheckIns == '#[1]'
    * def subsequentCheckIn = response.subsequentCheckIns[0]
    And match subsequentCheckIn.inHouseUse == true
    And match subsequentCheckIn.loan == '#notpresent'
    And match subsequentCheckIn.item.status.name == 'Available'
    And match subsequentCheckIn.subsequentCheckIns == '#notpresent'

    # 2. Check Loan LN
    Given path 'circulation', 'loans'
    And param query = 'itemId==' + itemId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.loans[0].status.name == 'Closed'

    # 3. Check The Check-In Records Of Item A
    Given path 'check-in-storage', 'check-ins'
    And param query = 'itemId==' + itemId
    When method GET
    Then status 200
    And match response.totalRecords == 2
    * def inHouseUseCheckIns = karate.filter(response.checkIns, function(x){ return x.inHouseUse == true })
    * def regularCheckIns = karate.filter(response.checkIns, function(x){ return x.inHouseUse != true })
    And match inHouseUseCheckIns == '#[1]'
    And match regularCheckIns == '#[1]'


  @C1621490
  @Positive
  Scenario: In-house use check-in of a checked-out item uses the status left by the regular check-in when the item goes in transit
    # Prerequisites: service point SP1 serving location L, service point SP2 not serving location L, item A in location L checked out to patron P
    * def extItemBarcode = 'C1621490-item-' + random_string()
    * def extUserBarcode = 'C1621490-user-' + random_string()
    * def extUserId = call uuid1
    * def extServicePointId2 = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { extServicePointId: #(extServicePointId2) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

    # 1. Check In Item A At SP2 With In-House Use And Confirm The Override
    * def checkInDate = getTimeNow()
    Given path 'circulation', 'check-in-by-barcode'
    And request { itemBarcode: '#(extItemBarcode)', servicePointId: '#(extServicePointId2)', checkInDate: '#(checkInDate)', inHouseUse: true, checkedOutItemInHouseUseOverride: true }
    When method POST
    Then status 200
    And match response.loan.status.name == 'Closed'
    And match response.item.status.name == 'In transit'
    And match response.subsequentCheckIns == '#[1]'
    And match response.subsequentCheckIns[0].inHouseUse == true
    And match response.subsequentCheckIns[0].item.status.name == 'In transit'

    # 2. Check The Status Of Item A
    Given path 'inventory', 'items', itemId
    When method GET
    Then status 200
    And match response.status.name == 'In transit'

    # 3. Check The Check-In Records Of Item A
    Given path 'check-in-storage', 'check-ins'
    And param query = 'itemId==' + itemId
    When method GET
    Then status 200
    And match response.totalRecords == 2
    * def inHouseUseCheckIns = karate.filter(response.checkIns, function(x){ return x.inHouseUse == true })
    And match inHouseUseCheckIns == '#[1]'
    And match inHouseUseCheckIns[0].itemStatusPriorToCheckIn == 'In transit'


  @C1621491
  @Positive
  Scenario: In-house use of an available item does not require confirmation
    # Prerequisites: service point SP serving location L, available item A in location L without loans and requests
    * def extItemBarcode = 'C1621491-item-' + random_string()
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }

    # 1. Check In Item A At SP With In-House Use, Without Confirming The Override
    * def checkInDate = getTimeNow()
    Given path 'circulation', 'check-in-by-barcode'
    And request { itemBarcode: '#(extItemBarcode)', servicePointId: '#(servicePointId)', checkInDate: '#(checkInDate)', inHouseUse: true }
    When method POST
    Then status 200
    And match response.inHouseUse == true
    And match response.item.status.name == 'Available'
    And match response.subsequentCheckIns == '#notpresent'

    # 2. Check The Check-In Records Of Item A
    Given path 'check-in-storage', 'check-ins'
    And param query = 'itemId==' + itemId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.checkIns[0].inHouseUse == true


  @C1621492
  @Positive
  Scenario: Confirming the in-house use override without in-house use results in a regular check-in only
    # Prerequisites: service point SP serving location L, item A in location L checked out to patron P (loan LN)
    * def extItemBarcode = 'C1621492-item-' + random_string()
    * def extUserBarcode = 'C1621492-user-' + random_string()
    * def extUserId = call uuid1
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup') { extUserGroupId: #(groupId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

    # 1. Check In Item A At SP Without In-House Use, With The In-House Use Override Confirmed
    * def checkInDate = getTimeNow()
    Given path 'circulation', 'check-in-by-barcode'
    And request { itemBarcode: '#(extItemBarcode)', servicePointId: '#(servicePointId)', checkInDate: '#(checkInDate)', inHouseUse: false, checkedOutItemInHouseUseOverride: true }
    When method POST
    Then status 200
    And match response.inHouseUse == false
    And match response.loan.status.name == 'Closed'
    And match response.item.status.name == 'Available'
    And match response.subsequentCheckIns == '#notpresent'

    # 2. Check The Check-In Records Of Item A
    Given path 'check-in-storage', 'check-ins'
    And param query = 'itemId==' + itemId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.checkIns[0].inHouseUse != true
