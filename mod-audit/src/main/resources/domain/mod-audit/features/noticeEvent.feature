Feature: mod audit data NOTICE event

  # Should be added new log record

  @Undefined
  Scenario: Generate NOTICE event and verify number of NOTICE records
    * print 'undefined'

  # Should not be added new log record

  @Undefined
  Scenario: Generate NOTICE event with invalid 'userBarcode' and verify number of NOTICE records
    * print 'undefined'

  @Undefined
  Scenario: Generate NOTICE event with invalid 'accountId' and verify number of NOTICE records
    * print 'undefined'

  @Undefined
  Scenario: Generate NOTICE event with invalid 'source' and verify number of NOTICE records
    * print 'undefined'

  @Undefined
  Scenario: Generate NOTICE event with invalid 'items' and verify number of NOTICE records
    * print 'undefined'