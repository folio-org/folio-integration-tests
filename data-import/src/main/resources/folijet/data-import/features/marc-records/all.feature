Feature: FAT MARC Records Test Suite

  Scenario: Marc Bib Tests
    * call read('this:marc-bibs/all.feature')

  Scenario: Holdings Import Tests
    * call read('this:data-import-holdings-records.feature')

  Scenario: Marc Authority Tests
    * call read('this:data-import-authority-records.feature')

  Scenario: Orders Tests
    * call read('this:data-import-orders.feature')

  Scenario: Set For Deletion Tests
    * call read('this:data-import-set-for-deletion.feature')

  Scenario: Mapping Rules Tests
    * call read('this:mapping-rules/all.feature')
