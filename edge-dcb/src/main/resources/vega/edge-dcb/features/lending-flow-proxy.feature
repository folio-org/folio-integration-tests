Feature: lending flow

  Background:
    * url baseUrl
    * callonce login admin
    * def api = apikey
    * def proxyStartDate = callonce getCurrentUtcDate


  Scenario: Create DCB Transaction
    * callonce read(featuresPath + 'lending-flow.feature@CreateDCBTransaction') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after creating DCB transaction
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusAfterCreatingDCBTransaction') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Manual Check In 1
    * callonce read(featuresPath + 'lending-flow.feature@CheckIn1') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after manual check in 1
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusAfterCheckIn1') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status list after Open
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusListAfterOpen') { proxyCall: true, proxyPath: '/dcbService/', key: #(api), proxyStartDate: #(proxyStartDate)}

  Scenario: Update transaction status to Awaiting Pickup
    * callonce read(featuresPath + 'lending-flow.feature@UpdateTransactionStatusToAwaitingPickup') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to Awaiting Pickup
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusAfterUpdatingToAwaitingPickup') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status list after Awaiting pickup
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusListAfterAwaitingPickup') { proxyCall: true, proxyPath: '/dcbService/', key: #(api), proxyStartDate: #(proxyStartDate)}

  Scenario: Update transaction status to ITEM_CHECKED_OUT
    * callonce read(featuresPath + 'lending-flow.feature@UpdateTransactionStatusToItemCheckedOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to ITEM_CHECKED_OUT
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusAfterUpdatingToItemCheckedOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status list after Item checked out
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusListAfterItemCheckedOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api), proxyStartDate: #(proxyStartDate)}

  Scenario: Update transaction status to ITEM_CHECKED_IN
    * callonce read(featuresPath + 'lending-flow.feature@UpdateTransactionStatusToItemCheckedIn') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to ITEM_CHECKED_IN
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusAfterUpdatingToItemCheckedIn') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status list after Item checked in
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusListAfterItemCheckedIn') { proxyCall: true, proxyPath: '/dcbService/', key: #(api), proxyStartDate: #(proxyStartDate)}

  Scenario: Manual Check In 2
    * callonce read(featuresPath + 'lending-flow.feature@CheckIn2') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after manual check in 2
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusAfterCheckIn2') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status list after Closed
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatusListAfterClosed') { proxyCall: true, proxyPath: '/dcbService/', key: #(api), proxyStartDate: #(proxyStartDate)}

