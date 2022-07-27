Feature: test server mock

  Background:
    * def mocksPath = 'classpath:volaris/edge-inn-reach/mocks/'
    * def token = function(){ return org.apache.commons.lang3.RandomStringUtils.randomAlphanumeric(32) }

  Scenario: pathMatches('/auth/v1/oauth2/token')
            && paramValue('grant_type') == 'client_credentials'
            && paramValue('scope') == 'innreach_tp'
            && methodIs('post')
            && karate.get('requestHeaders.Authorization[0]')
    * print 'Mock called: /auth/v1/oauth2/token'
    * def authToken = token()
    * print 'Returning token: ' + authToken
    * def response = read(mocksPath + "general/oauth-token-response.json")
