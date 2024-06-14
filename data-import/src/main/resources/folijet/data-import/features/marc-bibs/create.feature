Feature: Create Instance, Holdings & Items

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario: FAT-937 Upload MARC file and Create Instance, Holdings, Items.
    * print 'Upload MARC file and Create Instance, Holdings, Items.'
    * call read(importHoldingFeature) {testIdentifier: "FAT-937"}
