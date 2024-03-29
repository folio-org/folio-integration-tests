Feature: central server mock

  Background:
    * def mocksPath = 'classpath:volaris/mod-inn-reach/mocks/'
    * def token = function(){ return org.apache.commons.lang3.RandomStringUtils.randomAlphanumeric(32) }

  Scenario: pathMatches('/auth/v1/oauth2/token')
#            && paramValue('grant_type') == 'client_credentials'
#            && paramValue('scope') == 'innreach_tp'
            && methodIs('post')
#            && karate.get('requestHeaders.Authorization[0]')
    * print 'Mock called: /auth/v1/oauth2/token'
    * def authToken = token()
    * print 'Returning token: ' + authToken
    * def response = read(mocksPath + "general/oauth-token-response.json")

  Scenario: pathMatches('/innreach/v2/contribution/locations')
            && methodIs('get')
    * print 'Mock called: GET /innreach/v2/contribution/locations'
    * def response = read(mocksPath + "general/inn-reach-locations-response.json")


  Scenario:
    # catch-all
    * print request
    * def responseStatus = 404
    * def responseHeaders = { 'Content-Type': 'text/html; charset=utf-8' }
    * def response = [Mock] Not Found


  Scenario: pathMatches('/innreach/v2/contribution/localservers')
  && methodIs('get')
    * print 'Mock called: GET /innreach/v2/contribution/localservers'
    * def response = read(mocksPath + "general/inn-reach-local-servers-response.json")