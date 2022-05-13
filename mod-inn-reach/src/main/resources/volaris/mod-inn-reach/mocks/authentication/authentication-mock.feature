Feature: authentication mock

  Background:
    * def mocksPath = 'classpath:volaris/mod-inn-reach/mocks/'
    * call read (mocksPath + "/general/auth-mock.feature")

    Scenario: pathMatches('/authentication') && methodIs('post')
      * print 'Mock called: /authentication'
      * def responseStatus = 200