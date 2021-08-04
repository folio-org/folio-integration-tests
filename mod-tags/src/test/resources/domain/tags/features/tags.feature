Feature: Mod-tags integration tests

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * def tag = read('classpath:samples/tag.json')

 # ================= positive test cases =================
  @Undefined
  Scenario: GET '/tags' should return 200 and collection of tags
    * print 'undefined'

  @Undefined
  Scenario: GET '/tags/{id}' should return 200 and tag with specified id
    * print 'undefined'

  @Undefined
  Scenario: POST '/tags' should return 201 and created tag with id
    * print 'undefined'

  @Undefined
  Scenario: PUT '/tags/{id}' should return 204 if tag was successfully updated
    * print 'undefined'

  @Undefined
  Scenario: DELETE '/tags/{id}' should return 204 if tag was successfully deleted
    * print 'undefined'


  # ================= negative test cases =================
  @Undefined
  Scenario: ALL TYPES '/tags' should return 400 when malformed request body or query parameter
    * print 'undefined'

  @Undefined
  Scenario: ALL TYPES '/tags' should return 401 when user not authorized to perform action
    * print 'undefined'

  @Undefined
  Scenario: GET '/tags/{id}' should return 404 if tag with specified id not found
    * print 'undefined'

  @Undefined
  Scenario: PUT '/tags/{id}' should return 404 if tag with specified id not found
    * print 'undefined'

  @Undefined
  Scenario: DELETE '/tags/{id}' should return 404 if tag with specified id not found
    * print 'undefined'

  @Undefined
  Scenario: GET '/tags/{id}' should return 422 when specified id is not UUID
    * print 'undefined'

  @Undefined
  Scenario: POST '/tags' should return 422 when label parameter is absent
    * print 'undefined'