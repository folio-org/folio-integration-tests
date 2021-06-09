Feature: mod audit data CRUD/errors

  # CRUD

  @Undefined
  Scenario: Get a list of all audit records
    * print 'undefined'

  @Undefined
  Scenario: Create audit record
    * print 'undefined'

  @Undefined
  Scenario: Get audit record by id
    * print 'undefined'

  @Undefined
  Scenario: Update audit record by id
    * print 'undefined'

  @Undefined
  Scenario: Delete audit record by id
    * print 'undefined'

  @Undefined
  Scenario: Get all circulation logs
    * print 'undefined'

  @Undefined
  Scenario: Initialize tenant / Register module
    * print 'undefined'

  @Undefined
  Scenario: Get tenant by id
    * print 'undefined'

  @Undefined
  Scenario: Delete tenant by id
    * print 'undefined'

    # Errors

  @Undefined
  Scenario: Should return 404 if audit record not found by id to get
    * print 'undefined'

  @Undefined
  Scenario: Should return 404 if audit record not found by id to delete
    * print 'undefined'

  @Undefined
  Scenario: Should return 400 when trying to update audit record without body of PUT
    * print 'undefined'

  @Undefined
  Scenario: Should return 422 when trying to update audit record with missing 'tenant' in body of PUT
    * print 'undefined'

  @Undefined
  Scenario: Should return 404 when trying to update audit record with id that cannot be found
    * print 'undefined'

  @Undefined
  Scenario: Should return 404 when trying to register module, but no module found for tenant
    * print 'undefined'

  @Undefined
  Scenario: Should return 404 when tenant not found by id to get
    * print 'undefined'

  @Undefined
  Scenario: Should return 404 when tenant not found by id to delete
    * print 'undefined'