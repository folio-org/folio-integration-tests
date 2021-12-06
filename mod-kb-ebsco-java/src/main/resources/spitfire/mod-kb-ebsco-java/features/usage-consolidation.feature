Feature: Usage Consolidation

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

 #   ================= positive test cases =================

  @Undefined
  Scenario: GET Usage Consolidation settings by KB credentials id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Usage Consolidation settings by KB credentials id with 201 on success
    * print 'undefined'

  @Undefined
  Scenario: PATCH Usage Consolidation settings by KB credentials id with 204 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Usage Consolidation settings customer key by KB credentials id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Usage Consolidation settings with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Usage Consolidation credentials with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Usage Consolidation credentials with 204 on success
    * print 'undefined'

#   ================= negative test cases =================
  @Undefined
  Scenario: GET Usage Consolidation settings by KB credentials id should return 404 if no settings present
    * print 'undefined'

  @Undefined
  Scenario: POST Usage Consolidation settings by KB credentials id should return 400 if no request data attributes provided
    * print 'undefined'

  @Undefined
  Scenario: POST Usage Consolidation settings by KB credentials id should return 422 if no request data attributes currency provided
    * print 'undefined'

  @Undefined
  Scenario: POST Usage Consolidation settings by KB credentials id should return 422 if empty request data attributes currency provided
    * print 'undefined'

  @Undefined
  Scenario: POST Usage Consolidation settings by KB credentials id should return 422 if invalid request data attributes startMonth provided
    * print 'undefined'

  @Undefined
  Scenario: POST Usage Consolidation settings by KB credentials id should return 422 if invalid request data attributes platformType provided
    * print 'undefined'

  @Undefined
  Scenario: POST Usage Consolidation settings by KB credentials id should return 422 if invalid request data attributes metricType provided
    * print 'undefined'

  @Undefined
  Scenario: PATCH Usage Consolidation settings by KB credentials id should return 404 if no settings found
    * print 'undefined'

  @Undefined
  Scenario: PATCH Usage Consolidation settings by KB credentials id should return 422 if invalid request data attributes startMonth provided
    * print 'undefined'

  @Undefined
  Scenario: PATCH Usage Consolidation settings by KB credentials id should return 422 if invalid request data attributes platformType provided
    * print 'undefined'

  @Undefined
  Scenario: GET Usage Consolidation settings customer key by KB credentials id should return 404 if no customer key found
    * print 'undefined'

  @Undefined
  Scenario: GET Usage Consolidation settings should return 404 if no settings found
    * print 'undefined'

  @Undefined
  Scenario: PUT Usage Consolidation credentials should return 422 if no clientId provided
    * print 'undefined'

  @Undefined
  Scenario: PUT Usage Consolidation credentials should return 422 if empty clientId provided
    * print 'undefined'

  @Undefined
  Scenario: PUT Usage Consolidation credentials should return 422 if no clientSecret provided
    * print 'undefined'

  @Undefined
  Scenario: PUT Usage Consolidation credentials should return 422 if empty clientSecret provided
    * print 'undefined'
