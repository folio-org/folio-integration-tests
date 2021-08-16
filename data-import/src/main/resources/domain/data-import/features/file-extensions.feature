Feature: File extensions

  @Undefined
  Scenario: Get non-existent file extension
    * print 'Verify 404 response'

  @Undefined
  Scenario: Create file extension
    * print 'Create file extension'

  @Undefined
  Scenario: Update existing file extension
    * print 'Create and then update a file extension'

  @Undefined
  Scenario: Fail to duplicate existing file extension
    * print 'Try to create file extension with the same name'

  @Undefined
  Scenario: Fail to save invalid file extension
    * print 'Try to create file extension with empty body, incorrect name, and invalid field'

  @Undefined
  Scenario: Return a list of existing file extensions
    * print 'Return a list of existing file extensions'

  @Undefined
  Scenario: Return a list of file extensions for which import is blocked
    * print 'Return a list of file extensions for which import is blocked'

  @Undefined
  Scenario: Delete file extension
    * print 'Delete file extension'

  @Undefined
  Scenario: Fail to delete non-existent extension
    * print 'Verify 404 response'

  @Undefined
  Scenario: Restore default file extensions
    * print 'Restore default file extensions'
