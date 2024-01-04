Feature: Borrowing-Pickup flow

  Background:
    * url baseUrl
    * callonce login admin
    * def api = 'eyJzIjoieHFpNzNjNEZzOSIsInQiOiJkaWt1IiwidSI6ImRpa3VfYWRtaW4ifQ=='


  Scenario: Create DCB Transaction
    * callonce read(featuresPath + 'borrowing-pickup.feature@CreateDCBTransaction') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after creating DCB transaction
    * callonce read(featuresPath + 'borrowing-pickup.feature@GetTransactionStatusAfterCreatingDCBTransaction') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to Open
    * callonce read(featuresPath + 'borrowing-pickup.feature@UpdateTransactionStatusToOpen') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to Open
    * callonce read(featuresPath + 'borrowing-pickup.feature@GetTransactionStatusAfterUpdatingToOpen') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Manual Check In 1
    * callonce read(featuresPath + 'borrowing-pickup.feature@CheckIn1') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after manual check in 1
    * callonce read(featuresPath + 'borrowing-pickup.feature@GetTransactionStatusAfterCheckIn1') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Manual Check out
    * callonce read(featuresPath + 'borrowing-pickup.feature@CheckOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after manual check out
    * callonce read(featuresPath + 'borrowing-pickup.feature@GetTransactionStatusAfterCheckOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Manual Check In 2
    * callonce read(featuresPath + 'borrowing-pickup.feature@CheckIn2') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after manual check in 2
    * callonce read(featuresPath + 'borrowing-pickup.feature@GetTransactionStatusAfterCheckIn2') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to closed
    * callonce read(featuresPath + 'borrowing-pickup.feature@UpdateTransactionStatusToClosed') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to closed
    * callonce read(featuresPath + 'borrowing-pickup.feature@GetTransactionStatusAfterUpdatingToClosed') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}
