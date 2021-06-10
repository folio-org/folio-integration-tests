Feature: mod audit data CRUD/errors

  @Undefined
  Scenario: Post new log record with CHECK_IN_EVENT and verify that number of N_A, LOAN, and REQUEST records are incremented by one
    * print 'undefined'

  @Undefined
  Scenario: Post new log record with CHECK_OUT_THROUGH_OVERRIDE_EVENT and verify that number of LOAN and REQUEST records are incremented by one
    * print 'undefined'

  @Undefined
  Scenario: Post new log record with REQUEST_CREATED_THROUGH_OVERRIDE_EVENT and verify that number of REQUEST records are incremented by one
    * print 'undefined'

  @Undefined
  Scenario: Post new log record with REQUEST_CREATED_EVENT and verify that number of REQUEST records are incremented by one
    * print 'undefined'

  @Undefined
  Scenario: Post new log record with REQUEST_UPDATED_EVENT and verify that number of REQUEST records are incremented by one
    * print 'undefined'

  @Undefined
  Scenario: Post new log record with REQUEST_EXPIRED_EVENT and verify that number of REQUEST records are incremented by one
    * print 'undefined'

  @Undefined
  Scenario: Post new log record with REQUEST_MOVED_EVENT and verify that number of REQUEST records are incremented by one
    * print 'undefined'

  @Undefined
  Scenario: Post new log record with REQUEST_REORDERED_EVENT and verify that number of REQUEST records are incremented by one
    * print 'undefined'

  # ERRORS

  @Undefined
  Scenario: Post new log record with REQUEST_CREATED_EVENT and invalid user id, and verify that number of REQUEST records remains the same
    * print 'undefined'