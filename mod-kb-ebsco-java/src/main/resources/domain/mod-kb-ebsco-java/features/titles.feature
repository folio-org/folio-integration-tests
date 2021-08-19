Feature: Titles

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

  @Undefined
  Scenario: GET all Titles filtered by tags with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Titles filtered by access-type with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Titles filtered by selected with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Titles filtered by type with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Titles filtered by name with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Titles filtered by isxn with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Titles filtered by subject with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Titles filtered by publisher with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Titles should return 400 if filter param is missing
    * print 'undefined'

  @Undefined
  Scenario: POST Titles should create a new Custom Title with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Titles should return 400 if custom Title with the provided name already exists
    * print 'undefined'

  @Undefined
  Scenario: POST Titles should return 422 if Identifier subtype is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Title by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Title by id should return 404 if Title not found
    * print 'undefined'

  @Undefined
  Scenario: PUT Title by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Title by id should return 422 if Identifier subtype is invalid
    * print 'undefined'
