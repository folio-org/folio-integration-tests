Feature: MARC Derived Records

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Validate MARC derived record
    * def getMarcCall = call getDerivedMarc { resourceId:  '#(instanceId)' }
    * def fields = getMarcCall.response.parsedRecord.content.fields
    * match fields contains { 001: "#(hrid)" }
    * match fields contains { 005: "#notnull" }
    * match fields contains { 010: { subfields: [ { a: "  1234567890" } ], ind1: " ", ind2: " " } }
    * match fields contains { 020: { subfields: [ { a: "0987654321" }, { q: "Hardcover" } ], ind1: " ", ind2: " " } }
    * match fields contains { 022: { subfields: [ { a: "ISSN Value" } ], ind1: " ", ind2: " " } }
    * match fields contains { 024: { subfields: [ { a: "IAN value" }, { q: "IAN Qualifier" } ], ind1: "3", ind2: " " } }
    * match fields contains { 024: { subfields: [ { a: "Other ID value" }, { q: "Other ID qualifier" } ], ind1: "8", ind2: " " } }
    * match fields contains { 040: { subfields: [ { a: "DLC" }, { b: "eng" }, { c: "LoC" }, { d: "LC" }, { d: "AGR" } ], ind1: " ", ind2: " " } }
    * match fields contains { 041: { subfields: [ { a: "eng" } ], ind1: " ", ind2: " " } }
    * match fields contains { 041: { subfields: [ { b: "fre" } ], ind1: " ", ind2: " " } }
    * match fields contains { 041: { subfields: [ { h: "fre" } ], ind1: " ", ind2: " " } }
    * match fields contains { 041: { subfields: [ { t: "ger" } ], ind1: " ", ind2: " " } }
    * match fields contains { 257: { subfields: [ { a: "United States" } ], ind1: " ", ind2: " " } }
    * match fields contains { 300: { subfields: [ { a: "20 pages" }, { b: "illustrations (some color)" }, { c: "8x8" }, { e: "reference manual" }, { 3: "ref print." } ], ind1: " ", ind2: " " } }
    * match fields contains { 336: { subfields: [ { a: "cartographic image" }, { b: "cri" } ], ind1: " ", ind2: " " } }
    * match fields contains { 337: { subfields: [ { a: "unspecified" }, { b: "z" } ], ind1: " ", ind2: " " } }
    * match fields contains { 338: { subfields: [ { a: "audio belt" }, { b: "sb" } ], ind1: " ", ind2: " " } }
    * match fields contains { 856: { subfields: [ { u: "http://url_of_instance" }, { z: "url of instance note" } ], ind1: " ", ind2: " " } }