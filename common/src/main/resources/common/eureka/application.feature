Feature: Applications

  Background:
    * url baseUrl

  @applicationSearch
  Scenario: searchApplication
    * def modules = $modules[*].name
    * def appIds = []
    * def dependencyNames = []
    * def dependencyIds = []

    Given path 'applications'
    When method GET
    Then status 200
    * def totalAmount = response.totalRecords

    Given path 'applications'
    And param limit = totalAmount
    When method GET
    Then status 200
    * def appDescriptions = response.applicationDescriptors

    # search applications that contain modules and uimodules, extract application's id, remove id duplicates
    * karate.forEach(modules, moduleName =>  appIds = appIds.concat(appDescriptions.filter(descriptor => descriptor.modules.some(m => m.name == moduleName)).map(descriptor => descriptor.id)))
    * karate.forEach(modules, moduleName =>  appIds = appIds.concat(appDescriptions.filter(descriptor => descriptor.uiModules.some(m => m.name == moduleName)).map(descriptor => descriptor.id)))
    * def uniqueAppIds = karate.distinct(appIds)

    # search dependencies among found applications, extract dependencies names, remove dependencies name duplicates
    * karate.forEach(uniqueAppIds, appId => dependencyNames.push(appDescriptions.filter(descriptor => descriptor.id == appId).flatMap(x => x.dependencies ? x.dependencies.map(dep => dep.name) : [])))
    * def flattenedArray = []
    * karate.forEach(dependencyNames, arr =>  flattenedArray = flattenedArray.concat(arr))
    * def uniqueDependencyNames = karate.distinct(flattenedArray)

    # Function for determining transitive dependencies by name depending on
    * def findTransitiveDependencies =
      """
      function findDepsIteratively(dependencyName) {
        var result = [];
        var queue = [dependencyName];  // Используем очередь для хранения зависимостей для обработки

        while (queue.length > 0) {
          var currentDep = queue.shift();
          if (result.indexOf(currentDep) === -1) {
            result.push(currentDep);

            var neededApp = karate.filter(appDescriptions, app => app.name == currentDep).flatMap(x => x.dependencies ? x.dependencies.map(dep => dep.name) : [])

            neededApp.forEach(function(name) {
              if (result.indexOf(name) === -1) {
                queue.push(name);
              }
            });
          }
        }
        return result;
      }
      """

    * karate.forEach(uniqueDependencyNames, depName => dependencyNames = dependencyNames.concat(findTransitiveDependencies(depName)))
    * def uniqueDependencyNames = karate.distinct(dependencyNames)

    # search application id by dependencies names, combine all ids together
    * karate.forEach(uniqueDependencyNames, dependencyName => dependencyIds = dependencyIds.concat(appDescriptions.filter(descriptor => descriptor.name == dependencyName).flatMap(x => x.id)))
    * def appIds = karate.distinct(appIds.concat(dependencyIds))
    * karate.set('applicationIds', appIds)
