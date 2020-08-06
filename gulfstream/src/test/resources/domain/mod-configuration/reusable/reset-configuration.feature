#===========HOW TO USE VARIABLES=============================
Feature: Reset default OAIPMH configs

  Background:
    * url baseUrl+ '/configurations/entries'
    #Init variables for templates
    * callonce variables

  Scenario: reset oai-pmh configuration

    * def result =  callonce read('classpath:domain/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def technicalId = $configResponse.configs[?(@.configName=='technical')].id
    * def generalId = $configResponse.configs[?(@.configName=='general')].id
    * def behaviorId = $configResponse.configs[?(@.configName=='behavior')].id

    # if you need to redefine default values, do it like this before loading templates: * def enableOaiServiceConfig = 'UPDATED'
    # fill placeholders with variables
    * call read('classpath:domain/mod-configuration/reusable/mod-config-templates.feature')

    * copy valueTemplate = technicalValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@TechnicalConfig') {id: '#(technicalId)', data: '#(valueTemplateString)'}

    * copy valueTemplate = generalValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@GeneralConfig') {id: '#(generalId)', data: '#(valueTemplateString)'}

    * copy valueTemplate = behaviorValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:domain/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}


