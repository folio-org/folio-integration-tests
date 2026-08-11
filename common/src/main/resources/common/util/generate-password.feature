@ignore
Feature: Shared password generator for test-created users

  # Returns a `generatePassword(username)` function that produces a deterministic,
  # FIPS/TLS-compliant password. Loaded once per test run via karate.callSingle
  # from every karate-config.js so callers don't duplicate the implementation.
  #
  # Every character of the username is interleaved with '.' so:
  #   - the full username never appears as a substring   (rule: no_user_name)
  #   - no two adjacent chars are equal, even if the username has 'nn'/'aa'
  #                                                      (rule: repeating_characters)
  #   - no keyboard sequence like 'qwe' or '123' can form (rule: keyboard_sequence)
  # The prefix 'Ab7!Kx9$' and suffix '#Zr3Qp!Xt' supply the required
  # upper+lower+digit+special classes AND pad the length so entropy stays
  # >= 112 bits even for short usernames (Keycloak/FIPS threshold).
  Scenario:
    * def generatePassword =
      """
      function(username) {
        var name = String(username || 'user');
        return 'Ab7!Kx9$' + name.split('').join('.') + '#Zr3Qp!Xt';
      }
      """
