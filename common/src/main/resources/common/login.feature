Feature: login

  Background:
    * url baseUrl
    * configure cookies = null

  Scenario: login user
    Given path 'realms', 'diku', 'protocol', 'openid-connect', 'auth'
    And params { client_id: 'diku-application', response_type: 'code', redirect_uri: 'https://folio-edev-dojo-diku.ci.folio.org/oidc-landing&scope=openid' }
#    https://folio-edev-dojo-keycloak.ci.folio.org/realms/diku/protocol/openid-connect/auth?client_id=diku-application&response_type=code&redirect_uri=https://folio-edev-dojo-diku.ci.folio.org/oidc-landing&scope=openid
#    https://folio-edev-dojo-keycloak.ci.folio.org/realms/consortium/protocol/openid-connect/auth?client_id=consortium-application&response_type=code&redirect_uri=https://folio-edev-dojo-consortium.ci.folio.org/oidc-landing&scope=openid
    When method GET
    Then status 200
    * def actionForm = response.match('<form id="kc-form-login"[^>]*?action="([^"]+)"')[0]
    * def actionValue = actionForm.match('action="([^"]+)"')[1]

    Given url actionValue
#    And request { username: '#(name)', password: '#(password)' }
    And form field username = 'diku_admin'
    And form field password = 'admin'
    And header Accept = 'multipart/form-data'
    When method POST
    Then status 200
    * def keycloakIdentity = responseCookies['KEYCLOAK_IDENTITY'].value
    * def keycloakSession = responseCookies['KEYCLOAK_SESSION'].value
    * configure cookies = null

