@ignore
Feature: Common schemas

  Scenario: Define common schemas
    * def isValidDateTime = read(globalPath + 'datetime-validator.js')
    * def metadataSchema =
    """
    {
      "createdDate": '#? isValidDateTime(_)',
      "createdByUserId": '#uuid',
      "createdByUsername": '#string',
      "updatedDate": '##? isValidDateTime(_)',
      "updatedByUserId": '##uuid',
      "updatedByUsername": '##string'
    }
    """
    * def errorDetailsSchema = { fieldName: '#string', message: '#string' }
    * def validationErrorSchema = { code: 400, message: 'Validation failed', validationErrors: '#[] errorDetailsSchema' }
