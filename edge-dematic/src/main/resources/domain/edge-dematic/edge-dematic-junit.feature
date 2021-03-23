Feature: edge-dematic integration tests

  Background:
    * url baseUrl
    * table modules
      | name  |

    * table adminAdditionalPermissions
      | name  |

    * table userPermissions
      | name  |

  Scenario: init data
    * call login admin
    * callonce read('classpath:global/prepare-test-data.feature')