Feature: Refresh shadow locations for DCB

  Background:
    * url baseUrl
    * callonce login admin
    * def api = apikey
    * def proxyStartDate = callonce getCurrentUtcDate


  Scenario: Create a shadow location from location with agency for borrower transaction
    * callonce read(featuresPath + 'refresh-shadow-locations.feature@CreateTwoShadowLocations') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Get Transaction status after creating DCB transaction
    * callonce read(featuresPath + 'refresh-shadow-locations.feature@RepeatCreationOfTwoShadowLocations') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}

  Scenario: Create a shadow location from agency (AGB2) for borrower transaction
    * callonce read(featuresPath + 'refresh-shadow-locations.feature@CreateShadowLocationFromAgency') { proxyCall: true, proxyPath: '/dcbService/', key: #(api)}
