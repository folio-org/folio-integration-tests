Feature: Borrowing-Pickup flow

  Background:
    * url baseUrl
    * callonce login admin
    * def api = apikey


  Scenario: Create DCB Transaction
    * callonce read(featuresPath + 'borrowing-pickup.feature@PerformDCBStatusTransitionForBorrowingPickupRole') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}