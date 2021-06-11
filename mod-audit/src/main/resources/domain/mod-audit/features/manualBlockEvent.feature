Feature: mod audit data MANUAL_BLOCK event

  # Should be added new log record

  @Undefined
  Scenario: Generate MANUAL_BLOCK event with 'borrowing' 'true', 'renewals' 'true', 'requests' 'true' and verify number of MANUAL_BLOCK records (created)
    * print 'undefined'

  @Undefined
  Scenario: Generate MANUAL_BLOCK event with 'borrowing' 'false', 'renewals' 'false', 'requests' 'false' and verify number of MANUAL_BLOCK records (modified)
    * print 'undefined'

  @Undefined
  Scenario: Generate MANUAL_BLOCK event with 'borrowing' 'true', 'renewals' 'false', 'requests' 'true' and verify number of MANUAL_BLOCK records (deleted)
    * print 'undefined'

  # Should not be added new log record

  @Undefined
  Scenario: Generate MANUAL_BLOCK event with invalid 'userId' and verify number of MANUAL_BLOCK records
    * print 'undefined'

  @Undefined
  Scenario: Generate MANUAL_BLOCK event with invalid 'type' and verify number of MANUAL_BLOCK records
    * print 'undefined'