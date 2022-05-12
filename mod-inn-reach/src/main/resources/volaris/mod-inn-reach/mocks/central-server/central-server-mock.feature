Feature: central server mock

  Background:
    * def token = function(){ return org.apache.commons.lang3.randomAlphanumeric(32) }

  Scenario: pathMatches('/auth/v1/oauth2/token')
#            && paramValue('grant_type') == 'client_credentials'
#            && paramValue('scope') == 'innreach_tp'
             && methodIs('post')
#            && karate.get('requestHeaders.Authorization[0]')
    * print 'mocked /auth/v1/oauth2/token called'
    * def authToken = token()
    * print 'returning token: ' + authToken
    * def response = read(mocksPath + "central-server/oauth-token-response.json")

  Scenario:
    # catch-all
    * print request
    * def responseStatus = 404
    * def responseHeaders = { 'Content-Type': 'text/html; charset=utf-8' }
    * def response = <html><body>Not Found</body></html>