Feature: mod audit data CHECK_IN_CHECK_OUT event

  # Should be added new log record

  @Undefined
  Scenario: Generate CHECK_IN event with 'true' 'isLoanClosed' and verify number of CHECK_IN records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_OUT event with 'false' 'isLoanClosed' and verify number of CHECK_OUT records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_IN event with 'In transit' 'itemStatusName' and verify number of CHECK_IN records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_OUT event with 'Checked out' 'itemStatusName' and verify number of CHECK_OUT records
    * print 'undefined'

  # Should not be added new log record

  @Undefined
  Scenario: Generate CHECK_IN event with 'false' 'isLoanClosed' and verify number of CHECK_IN records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_OUT event with 'true' 'isLoanClosed' and verify number of CHECK_OUT records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_IN event with invalid 'userId' and verify number of CHECK_IN records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_OUT event with invalid 'userId' and verify number of CHECK_OUT records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_IN event with invalid 'userBarcode' and verify number of CHECK_IN records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_OUT event with invalid 'userBarcode' and verify number of CHECK_OUT records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_IN event with invalid 'itemId' and verify number of CHECK_IN records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_OUT event with invalid 'itemId' and verify number of CHECK_OUT records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_IN event with invalid 'itemBarcode' and verify number of CHECK_IN records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_OUT event with invalid 'itemBarcode' and verify number of CHECK_OUT records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_IN event with invalid 'itemStatusName' and verify number of CHECK_IN records
    * print 'undefined'

  @Undefined
  Scenario: Generate CHECK_OUT event with invalid 'itemStatusName' and verify number of CHECK_OUT records
    * print 'undefined'