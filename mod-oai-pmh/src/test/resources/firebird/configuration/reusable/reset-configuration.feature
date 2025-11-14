#===========HOW TO USE VARIABLES=============================
Feature: Reset default OAIPMH configs

  Background:
    * url baseUrl+ '/configurations/entries'
    #Init variables for templates
    * callonce variables

    * callonce login testUser

  Scenario: reset oai-pmh configuration

    * def result =  callonce read('classpath:firebird/configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def technical = $configResponse.configurationSettings[?(@.configName=='technical')].id
    * def technicalId = '' + technical
    * def general = $configResponse.configurationSettings[?(@.configName=='general')].id
    * def generalId = '' + general
    * def behavior = $configResponse.configurationSettings[?(@.configName=='behavior')].id
    * def behaviorId = '' + behavior

    # if you need to redefine default values, do it like this before loading templates: * def enableOaiServiceConfig = 'UPDATED'
    # fill placeholders with variables
    * call read('classpath:firebird/configuration/reusable/config-templates.feature')

    * call read('classpath:firebird/configuration/reusable/update-configuration.feature@TechnicalConfig') {id: '#(technicalId)', data: '#(technicalValue)'}

    * call read('classpath:firebird/configuration/reusable/update-configuration.feature@GeneralConfig') {id: '#(generalId)', data: '#(generalValue)'}

    * call read('classpath:firebird/configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(behaviorValue)'}


