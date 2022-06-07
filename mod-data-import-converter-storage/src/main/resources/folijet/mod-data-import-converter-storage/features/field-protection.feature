Feature: Field protections

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': '*/*'  }
    * configure headers = headersUser

  @Undefined
  Scenario: Create new field protection setting for MARC Bib
    * print 'Create new field protection setting'

  @Undefined
  Scenario: Get all existing field protection settings
    * print 'Create a couple of settings and retrieve all of them'

  @Undefined
  Scenario: Get existing field protection settings filtered by source
    * print 'Create a couple of settings and retrieve only created by User or System'

  @Undefined
  Scenario: Fail to create a setting with invalid field/empty body
    * print 'Try to pass an invalid field/empty body while creating a setting, verify that it fails'

  @Undefined
  Scenario: Update field protection setting
    * print 'Successfully update a field protection setting'

  @Undefined
  Scenario: Fail to update a setting with invalid field/empty body
    * print 'Try to pass an invalid field/empty body while update a setting, verify that it fails'

  @Undefined
  Scenario: Fail to get a setting by id if it does not exist
    * print 'Verify 404 on get by id if setting does not exist'

  @Undefined
  Scenario: Fail to update/delete a setting with source System
    * print 'Try to update/delete a setting with source System, verify that it fails'

  @Undefined
  Scenario: Delete field protection setting
    * print 'Delete field protection setting'




