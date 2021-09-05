Feature: KB Credentials

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

 ################ Positive test cases ################
  @Undefined
  Scenario: GET /eholdings/kb-credentials should return status 200 and json file
    * print 'undefined'

  @Undefined
  Scenario: GET /eholdings/user-kb-credential should return status 200 and json file
    * print 'undefined'

  @Undefined
  Scenario: POST /eholdings/kb-credentials should return status 201 and json file
    * print 'undefined'

  @Undefined
  Scenario: GET /eholdings/kb-credentials/{id} should return status 200 and json file
    * print 'undefined'

  @Undefined
  Scenario: PATCH /eholdings/kb-credentials/{id} should return status 204
    * print 'undefined'

  @Undefined
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 204
    * print 'undefined'

  @Undefined
  Scenario: DELETE /eholdings/kb-credentials/{id} should return status 204
    * print 'undefined'

  @Undefined
  Scenario: GET /eholdings/kb-credentials/{id}/key should return status 200 and json file
    * print 'undefined'


     ################ Negative test cases ################
  @Undefined
  Scenario: GET /eholdings/kb-credentials/{id}/key should return status 400 and json if customerId invalid
    * print 'undefined'

  @Undefined
  Scenario: GET /eholdings/kb-credentials/{id}/key should return status 404 and json if customerId not exist
    * print 'undefined'

  @Undefined
  Scenario: GET /eholdings/user-kb-credential should return status 404 and json if user not assigned
    * print 'undefined'



  @Undefined
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if credentials invalid
    * print 'undefined'

  @Undefined
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if name longer than 255 characters
    * print 'undefined'

  @Undefined
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if name is empty
    * print 'undefined'

  @Undefined
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if name is already exist
    * print 'undefined'

  @Undefined
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if url is empty
    * print 'undefined'

  @Undefined
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if customerId is empty
    * print 'undefined'



  @Undefined
  Scenario: PUT /eholdings/kb-credentials{id} should return status 400 and json if customerId invalid
    * print 'undefined'

  @Undefined
  Scenario: PUT /eholdings/kb-credentials{id} should return status 404 and json if customerId not exist
    * print 'undefined'

  @Undefined
  Scenario: PUT /eholdings/kb-credentials{id} should return status 422 and json if credentials invalid
    * print 'undefined'

  @Undefined
  Scenario: PUT /eholdings/kb-credentials should return status 422 and json if name longer than 255 characters
    * print 'undefined'

  @Undefined
  Scenario: PUT /eholdings/kb-credentials should return status 422 and json if name is empty
    * print 'undefined'

  @Undefined
  Scenario: PUT /eholdings/kb-credentials should return status 422 and json if name is already exist
    * print 'undefined'

  @Undefined
  Scenario: PUT /eholdings/kb-credentials should return status 422 and json if url is empty
    * print 'undefined'

  @Undefined
  Scenario: PUT /eholdings/kb-credentials should return status 422 and json if customerId is empty
    * print 'undefined'



  @Undefined
  Scenario: PATCH /eholdings/kb-credentials{id} should return status 400 and json if customerId invalid
    * print 'undefined'

  @Undefined
  Scenario: PATCH /eholdings/kb-credentials{id} should return status 404 and json if customerId not exist
    * print 'undefined'

  @Undefined
  Scenario: PATCH /eholdings/kb-credentials{id} should return status 422 and json if credentials invalid
    * print 'undefined'

  @Undefined
  Scenario: PATCH /eholdings/kb-credentials should return status 422 and json if name longer than 255 characters
    * print 'undefined'

  @Undefined
  Scenario: PATCH /eholdings/kb-credentials should return status 422 and json if name is empty
    * print 'undefined'

  @Undefined
  Scenario: PATCH /eholdings/kb-credentials should return status 422 and json if name is already exist
    * print 'undefined'

  @Undefined
  Scenario: PATCH /eholdings/kb-credentials should return status 422 and json if url is empty
    * print 'undefined'

  @Undefined
  Scenario: PATCH /eholdings/kb-credentials should return status 422 and json if customerId is empty
    * print 'undefined'



  @Undefined
  Scenario: DELETE /eholdings/kb-credentials{id} should return status 400 and json if customerId invalid
    * print 'undefined'

  @Undefined
  Scenario: DELETE /eholdings/kb-credentials{id} should return status 400 and json if customerId invalid
    * print 'undefined'

  @Undefined
  Scenario: DELETE /eholdings/kb-credentials{id} should return status 404 and json if customerId not exist
    * print 'undefined'