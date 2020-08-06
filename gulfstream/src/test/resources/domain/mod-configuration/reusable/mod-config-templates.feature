Feature: Load shared templates
  #--------!Important use in your feature only :
  # copy newInvoice =  $invoiceTemplate  - creates a clone
  Scenario: Load mod-configuration templates

    * def behaviorTemplate = read('classpath:samples/configuration/behavior.json')
    * def behaviorValue = read('classpath:samples/configuration/behavior_value.json')

    * def generalTemplate = read('classpath:samples/configuration/general.json')
    * def generalValue = read('classpath:samples/configuration/general_value.json')

    * def technicalTemplate = read('classpath:samples/configuration/technical.json')
    * def technicalValue = read('classpath:samples/configuration/technical_value.json')