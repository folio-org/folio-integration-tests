Feature: Get vocabularies by name

  Background:
    * url baseUrl

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Get bookformat vocabulary and verify entry exists by @id
    * def bookformatId = 'http://id.loc.gov/vocabulary/bookformat/folio'

    Given path 'linked-data/vocabularies/bookformat'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == bookformatId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get carriers vocabulary and verify entry exists by @id
    * def carriersId = 'http://id.loc.gov/vocabulary/carriers/cd'

    Given path 'linked-data/vocabularies/carriers'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == carriersId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get contentTypes vocabulary and verify entry exists by @id
    * def contentTypesId = 'http://id.loc.gov/vocabulary/contentTypes/txt'

    Given path 'linked-data/vocabularies/contentTypes'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == contentTypesId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get countries vocabulary and verify entry exists by @id
    * def countriesId = 'http://id.loc.gov/vocabulary/countries/xxu'

    Given path 'linked-data/vocabularies/countries'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == countriesId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get frequencies vocabulary and verify entry exists by @id
    * def frequenciesId = 'http://id.loc.gov/vocabulary/frequencies/mon'

    Given path 'linked-data/vocabularies/frequencies'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == frequenciesId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get idstatus vocabulary and verify entry exists by @id
    * def idstatusId = 'http://id.loc.gov/vocabulary/mstatus/current'

    Given path 'linked-data/vocabularies/idstatus'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == idstatusId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get issuance vocabulary and verify entry exists by @id
    * def issuanceId = 'http://id.loc.gov/vocabulary/issuance/mono'

    Given path 'linked-data/vocabularies/issuance'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == issuanceId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get languages vocabulary and verify entry exists by @id
    * def languagesId = 'http://id.loc.gov/vocabulary/languages/eng'

    Given path 'linked-data/vocabularies/languages'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == languagesId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get maudience vocabulary and verify entry exists by @id
    * def maudienceId = 'http://id.loc.gov/vocabulary/maudience/adu'

    Given path 'linked-data/vocabularies/maudience'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == maudienceId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get mediaTypes vocabulary and verify entry exists by @id
    * def mediaTypesId = 'http://id.loc.gov/vocabulary/mediaTypes/n'

    Given path 'linked-data/vocabularies/mediaTypes'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == mediaTypesId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get mgovtpubtype vocabulary and verify entry exists by @id
    * def mgovtpubtypeId = 'http://id.loc.gov/vocabulary/mgovtpubtype/f'

    Given path 'linked-data/vocabularies/mgovtpubtype'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == mgovtpubtypeId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get millus vocabulary and verify entry exists by @id
    * def millusId = 'http://id.loc.gov/vocabulary/millus/ill'

    Given path 'linked-data/vocabularies/millus'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == millusId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get mnotetype vocabulary and verify entry exists by @id
    * def mnotetypeId = 'http://id.loc.gov/vocabulary/mnotetype/index'

    Given path 'linked-data/vocabularies/mnotetype'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == mnotetypeId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get mserialpubtype vocabulary and verify entry exists by @id
    * def mserialpubtypeId = 'http://id.loc.gov/vocabulary/mserialpubtype/journal'

    Given path 'linked-data/vocabularies/mserialpubtype'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == mserialpubtypeId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get mstatus vocabulary and verify entry exists by @id
    * def mstatusId = 'http://id.loc.gov/vocabulary/mstatus/current'

    Given path 'linked-data/vocabularies/mstatus'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == mstatusId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get msupplcont vocabulary and verify entry exists by @id
    * def msupplcontId = 'http://id.loc.gov/vocabulary/msupplcont/bibliography'

    Given path 'linked-data/vocabularies/msupplcont'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == msupplcontId })[0]
    * match entry == '#notnull'

  @Positive
  Scenario: Get relators vocabulary and verify entry exists by @id
    * def relatorsId = 'http://id.loc.gov/vocabulary/relators/fmo'

    Given path 'linked-data/vocabularies/relators'
    When method GET
    Then status 200

    * match response == '#array'
    * def entry = karate.filter(response, function(x){ return x['@id'] == relatorsId })[0]
    * match entry == '#notnull'
