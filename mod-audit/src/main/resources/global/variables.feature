Feature: global variables

  @GlobalVariables
  Scenario: use global variables
    * def locationId = 'fcd64ce1-6995-48f0-840e-89ffa2288371'
    * def username = 'testModAudit000'
    * def userid = '32c287f8-c23f-5134-982b-0d4478a45000'
    * def userBarcode = '00056000'
    * def itemId = '9ea1fd0b-0259-4edb-95a3-eb2f9a065000'
    * def itemBarcode = '00025000'
    * def servicePointId = 'c4c90014-c8c9-4ade-8f24-b5e313314000'
    * def loanTypeId = 'eedd13c4-7d40-4b1e-8f77-b0b9d19a8000'
    * def materialTypeId = 'eedd13c4-7d40-4b1e-8f77-b0b9d19a8000'
    * def instanceTypeId = 'eedd13c4-7d40-4b1e-8f77-b0b9d19a5000'
    * def instanceId = 'eedd13c4-7d40-4b1e-8f77-b0b9d19a8000'
    * def holdingsRecordId = 'eedd13c4-7d40-4b1e-8f77-b0b9d19a8000'
    * def checkInDate = call isoDate
    * def requestId = 'eedd13c4-7d40-4b1e-8f77-b0b9d19b0000'