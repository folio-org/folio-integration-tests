Feature: Tags

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

#   ================= positive test cases =================
  @Undefined
  Scenario: GET all tags with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all tags filtered by record types with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all unique tags with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all unique tags filtered by record types with 200 on success
    * print 'undefined'

#   ================= negative test cases =================
  @Undefined
  Scenario: GET all tags filtered by record types should return 400 if filter parameter is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET all unique tags filtered by record types should return 400 if filter parameter is invalid
    * print 'undefined'
