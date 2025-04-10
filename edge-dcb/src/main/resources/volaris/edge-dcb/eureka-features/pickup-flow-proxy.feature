Feature: Pickup flow

  Background:
    * url baseUrl
    * callonce login admin
    * def api = apikey


  Scenario: Create DCB Transaction
    * callonce read(featuresPath + 'pickup-flow.feature@CreateDCBTransaction') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after creating DCB transaction
    * callonce read(featuresPath + 'pickup-flow.feature@GetTransactionStatusAfterCreatingDCBTransaction') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to Open
    * callonce read(featuresPath + 'pickup-flow.feature@UpdateTransactionStatusToOpen') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to Open
    * callonce read(featuresPath + 'pickup-flow.feature@GetTransactionStatusAfterUpdatingToOpen') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Manual Check In 1
    * callonce read(featuresPath + 'pickup-flow.feature@CheckIn1') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after manual check in 1
    * callonce read(featuresPath + 'pickup-flow.feature@GetTransactionStatusAfterCheckIn1') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Manual Check out
    * callonce read(featuresPath + 'pickup-flow.feature@CheckOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after manual check out
    * callonce read(featuresPath + 'pickup-flow.feature@GetTransactionStatusAfterCheckOut') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Manual Check In 2
    * callonce read(featuresPath + 'pickup-flow.feature@CheckIn2') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after manual check in 2
    * callonce read(featuresPath + 'pickup-flow.feature@GetTransactionStatusAfterCheckIn2') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Update transaction status to closed
    * callonce read(featuresPath + 'pickup-flow.feature@UpdateTransactionStatusToClosed') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after updating to closed
    * callonce read(featuresPath + 'pickup-flow.feature@GetTransactionStatusAfterUpdatingToClosed') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}
