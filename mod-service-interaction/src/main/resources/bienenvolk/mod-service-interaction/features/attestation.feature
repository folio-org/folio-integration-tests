Feature: Attested assertion tokens

  # RFC 8693 attestation: a short-lived RS256-signed JWT vouching for the
  # calling user and tenant, used for module-to-module federated trust. The
  # signing key pair is created on demand and stored per tenant.

  Background:
    * url baseUrl
    * def user = uuid()
    * def actor = asUser(user)
    * def decodeSegment =
      """
      function (segment) {
        var bytes = java.util.Base64.getUrlDecoder().decode(segment);
        return karate.fromString(new java.lang.String(bytes, 'UTF-8'));
      }
      """
    * def jwtHeader = function (token) { return decodeSegment(token.split('.')[0]) }
    * def jwtClaims = function (token) { return decodeSegment(token.split('.')[1]) }

  Scenario: The endpoint answers a token envelope
    Given path 'servint', 'attestation', 'token'
    And headers actor
    When method GET
    Then status 200
    # Exactly two fields: the compact JWS and the status discriminator.
    And match response == { token: '#string', status: 'OK' }
    * def parts = response.token.split('.')
    * match parts == '#[3]'

  Scenario: The JWS header names RS256 and the signing key
    Given path 'servint', 'attestation', 'token'
    And headers actor
    When method GET
    Then status 200
    * def header = jwtHeader(response.token)
    * match header.alg == 'RS256'
    * match header.typ == 'JWT'
    # Registered deviation D-21: legacy sets kid to the usage string, which
    # cannot distinguish keys across rotation; the port sets it to the signing
    # key record's id so a receiver can select the exact public key.
    * match header.kid == '#string'
    * def kidAsExpected = impl == 'legacy' ? header.kid == 'extApp' : header.kid.length == 36
    * assert kidAsExpected

  Scenario: The claim set attests the caller and the tenant
    Given path 'servint', 'attestation', 'token'
    And headers actor
    When method GET
    Then status 200
    * def claims = jwtClaims(response.token)
    * match claims.iss == 'FOLIO::mod-service-interaction'
    * match claims.sub == user
    * match claims.tenant == testTenant
    * match claims.jti == '#uuid'
    # The audience is the usage the key was minted for.
    * def audience = karate.toString(claims.aud)
    * match audience contains 'extApp'
    # Five minute lifetime.
    * assert claims.exp - claims.iat == 300

  Scenario: An unidentifiable caller is attested as UNKNOWN
    # Neither an x-okapi-user-id header nor a user_id claim in the token.
    * def anonymous =
      """
      {
        'Content-Type': 'application/json',
        'X-Okapi-Tenant': '#(testTenant)',
        'X-Okapi-Url': '#(okapiUrl)',
        'X-Okapi-Token': 'DUMMY'
      }
      """
    Given path 'servint', 'attestation', 'token'
    And headers anonymous
    When method GET
    Then status 200
    * def claims = jwtClaims(response.token)
    * match claims.sub == 'UNKNOWN'
    * match claims.tenant == testTenant

  Scenario: Repeated calls reuse the tenant's key pair
    Given path 'servint', 'attestation', 'token'
    And headers actor
    When method GET
    Then status 200
    * def firstKid = jwtHeader(response.token).kid
    * def firstJti = jwtClaims(response.token).jti

    Given path 'servint', 'attestation', 'token'
    And headers actor
    When method GET
    Then status 200
    * def secondKid = jwtHeader(response.token).kid
    * def secondJti = jwtClaims(response.token).jti

    # Same signing key, a fresh token id every time.
    * match secondKid == firstKid
    * assert secondJti != firstJti
