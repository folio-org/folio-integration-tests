Feature: Root feature that runs extended mod-circulation features

  Background:
    * call read('classpath:vega/mod-circulation/features/root-setup.feature')

  Scenario: Run extended mod-circulation features
    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 3600 }
    * call read('classpath:vega/mod-circulation/features/loans-extended.feature')
    * call read('classpath:vega/mod-circulation/features/requests-extended.feature')
    * call read('classpath:vega/mod-circulation/features/print-events-extended.feature')
