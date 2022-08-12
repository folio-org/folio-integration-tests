@ignore
@parallel=false
Feature: Inn reach circulation

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser


  @Undefined
  Scenario: Create inn reach transaction item hold
    * print 'Create inn reach transaction item hold'

  @Undefined
  Scenario: Create patron hold
    * print 'Create patron hold'

  @Undefined
  Scenario: Update item shipped
    * print 'Put item shipped'

  @Undefined
  Scenario: Cancel patron hold
    * print 'cancel patron hold'

  @Undefined
  Scenario: Create local hold
    * print 'create local hold'

  @Undefined
  Scenario: Update item in transit
    * print 'create local hold'

  @Undefined
  Scenario: Transfer request
    * print 'Transfer request'

  @Undefined
  Scenario: Cancel item hold
    * print 'Cancel item hold'

  @Undefined
  Scenario: Receive unshipped
    * print 'Receive unshipped'

  @Undefined
  Scenario: Return uncirculated
    * print 'Return uncirculated'

  @Undefined
  Scenario: Item received
    * print 'Item received'

  @Undefined
  Scenario: Recall with trackingId and central code
    * print 'Recall with trackingId and central code'

  @Undefined
  Scenario: Borrower renew loan
    * print 'Borrower renew loan'

  @Undefined
  Scenario: Owner renew loan
    * print 'Owner renew loan'

  @Undefined
  Scenario: Final check in
    * print 'Final check in'
