@parallel=false
Feature: dcb transaction api

  Background:
    * url baseUrl


  Scenario: Get transaction status by using mod-dcb
    * callonce read(featuresPath + 'get-transaction-status-by-id.feature') { proxyCall: true, proxyPath: edgeUrl + '/dcbService/' }

  Scenario: Create circulation request by using mod-dcb
    * callonce read(featuresPath + 'create-circulation-request.feature') { proxyCall: true, proxyPath: edgeUrl + '/dcbService/' }

  Scenario: Update transaction status by using mod-dcb
    * callonce read(featuresPath + 'update-transaction-status') { proxyCall: true, proxyPath: edgeUrl + '/dcbService/' }
