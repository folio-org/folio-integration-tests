Feature: Loans tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def instanceId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def itemId = callonce uuid1
    * def groupId = call uuid1
    * def userId = call uuid1
    * def checkOutByBarcodeId = call uuid1

  Scenario: Get checkIns records, define current item checkIn record and its status
    #post an item
    * call read('classpath:domain/mod-circulation/features/util/postItemWithBarcodeByUser.feature@PostItemWithBarcodeByUser') { varUserBarcode: '77777', varItemBarcode: '555555'  }

    # checkOut an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { varCheckOutUserBarcode: '77777', varCheckOutItemBarcode: '555555' }

    # checkIn an item with certain itemBarcode
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: '555555' }

    # get check-ins and assert checkedIn record
    Given path 'check-in-storage', 'check-ins'
    When method GET
    Then status 200
    * def checkedInRecord = response.checkIns[response.totalRecords - 1]
    And match checkedInRecord.itemId == itemId

    Given path 'check-in-storage', 'check-ins', checkedInRecord.id
    When method GET
    Then status 200
    And match response.itemStatusPriorToCheckIn == 'Checked out'
    And match response.itemId == itemId