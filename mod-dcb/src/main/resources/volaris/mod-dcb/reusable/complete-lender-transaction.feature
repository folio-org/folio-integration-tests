Feature: Complete DCB lender transaction flow from OPEN to CLOSED

  Scenario: Drive lender transaction through OPEN -> AWAITING_PICKUP -> ITEM_CHECKED_OUT -> ITEM_CHECKED_IN -> CLOSED
    * url baseUrl
    * configure retry = { count: 10, interval: 2000 }
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def updateToAwaitingPickup = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def updateToItemCheckOut = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def updateToItemCheckIn = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')

    Given path 'transactions', txnId, 'status'
    And retry until response.status == 'OPEN'
    When method GET
    Then status 200

    Given path 'transactions', txnId, 'status'
    And request updateToAwaitingPickup
    When method PUT
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId, 'status'
    And request updateToItemCheckOut
    When method PUT
    Then status 200

    Given path 'transactions', txnId, 'status'
    And request updateToItemCheckIn
    When method PUT
    Then status 200

    * def finalCheckIn = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * finalCheckIn.servicePointId = checkInServicePointId
    * finalCheckIn.itemBarcode = itemBarcode
    Given path 'circulation', 'check-in-by-barcode'
    And request finalCheckIn
    When method POST
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200
