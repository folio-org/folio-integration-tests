Feature: Borrowing flow

  Background:
    * url baseUrl
    * callonce login admin
    * def api = apikey


  Scenario: Create DCB Transaction
    * callonce read(featuresPath + 'borrowing-flow.feature@CreateDCBTransaction') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after creating DCB transaction
    * callonce read(featuresPath + 'borrowing-flow.feature@GetTransactionStatusAfterCreatingDCBTransaction') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to Open
    * callonce read(featuresPath + 'borrowing-flow.feature@UpdateTransactionStatusToOpen') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to Open
    * callonce read(featuresPath + 'borrowing-flow.feature@GetTransactionStatusAfterUpdatingToOpen') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to Awaiting pickup
    * callonce read(featuresPath + 'borrowing-flow.feature@UpdateTransactionStatusToAwaitingPickup') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to Awaiting pickup
    * callonce read(featuresPath + 'borrowing-flow.feature@GetTransactionStatusAfterUpdatingToAwaitingPickup') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to Item checked out
    * callonce read(featuresPath + 'borrowing-flow.feature@UpdateTransactionStatusToItemCheckedOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to Item checked out
    * callonce read(featuresPath + 'borrowing-flow.feature@GetTransactionStatusAfterUpdatingToItemCheckedOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to Item checked in
    * callonce read(featuresPath + 'borrowing-flow.feature@UpdateTransactionStatusToItemCheckedIn') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to Item checked out
    * callonce read(featuresPath + 'borrowing-flow.feature@GetTransactionStatusAfterUpdatingToItemCheckedIn') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to closed
    * callonce read(featuresPath + 'borrowing-flow.feature@UpdateTransactionStatusToClosed') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to closed
    * callonce read(featuresPath + 'borrowing-flow.feature@GetTransactionStatusAfterUpdatingToClosed') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}
