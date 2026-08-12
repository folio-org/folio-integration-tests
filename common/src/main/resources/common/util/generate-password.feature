@ignore
Feature: Shared password generator for test-created users

  # Returns two functions:
  #
  # generatePassword(username):
  #   Deterministic, FIPS/TLS-compliant password for a specific user. Every
  #   character of the username is interleaved with '.' so:
  #     - the full username never appears as a substring   (rule: no_user_name)
  #     - no two adjacent chars are equal, even if the username has 'nn'/'aa'
  #                                                        (rule: repeating_characters)
  #     - no keyboard sequence like 'qwe' or '123' can form (rule: keyboard_sequence)
  #   The prefix 'Ab7!Kx9$' and suffix '#Zr3Qp!Xt' supply the required
  #   upper+lower+digit+special classes AND pad the length so entropy stays
  #   >= 112 bits even for short usernames (Keycloak/FIPS threshold).
  #
  # generateEdgeUserPassword():
  #   Single shared FIPS/TLS-compliant password used by EVERY user whose
  #   credentials are duplicated in an edge module's ephemeral.properties
  #   (that file is generated from pipelines-shared-library
  #    resources/edge/config_eureka.yaml and resources/edge/config.yaml).
  #   Both the karate side and the pipelines-shared-library YAML must hold the
  #   same literal; if you change this value, update the YAML in the same
  #   release, otherwise every edge module test will 401 on user login.
  #   The literal has no username substring, no '$' (Groovy-template safe),
  #   and clears the 112-bit entropy threshold.
  Scenario:
    * def generatePassword =
      """
      function(username) {
        var name = String(username || 'user');
        return 'Ab7!Kx9$' + name.split('').join('.') + '#Zr3Qp!Xt';
      }
      """
    * def generateEdgeUserPassword =
      """
      function() {
        return 'Ab7@Kx9!FipsAlphaBravo#Zr3Qp!Xt';
      }
      """
