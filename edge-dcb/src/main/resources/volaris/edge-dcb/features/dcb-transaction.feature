Feature: dcb transaction api

  Background:
    * url baseUrl
    * callonce login admin
    * def api = apikey




  Scenario: Proxying mod-dcb api calls(Get Transaction status)
    * callonce read(featuresPath + 'lending-flow.feature@GetTransactionStatus') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}




