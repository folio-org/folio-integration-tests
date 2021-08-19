Feature: Providers

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

  @Undefined
  Scenario: Get all Providers
    * print 'undefined'

  @Undefined
  Scenario: GET all Providers filtered by tags with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Provider by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Provider by id should return 404 if Provider not found
    * print 'undefined'

  @Undefined
  Scenario: PUT Provider by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Tags assigned to Provider by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Tags assigned to Provider by id should return 404 if Provider not found
    * print 'undefined'

  @Undefined
  Scenario: PUT Tags assigned to Provider by id should return 422 if name is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Packages associated with a given Provider with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Packages associated with a given Provider filtered by tags with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Packages associated with a given Provider filtered by access-type with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Packages associated with a given Provider filtered by selected with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Packages associated with a given Provider filtered by type with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Packages associated with a given Provider should return 400 if search parameter is empty
    * print 'undefined'

  @Undefined
  Scenario: GET Packages associated with a given Provider should return 404 if Provider not found
    * print 'undefined'
