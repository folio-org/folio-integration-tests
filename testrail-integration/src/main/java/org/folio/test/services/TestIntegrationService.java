package org.folio.test.services;

import com.fasterxml.jackson.core.JsonEncoding;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import net.masterthought.cucumber.json.support.Status;
import org.apache.commons.lang3.StringUtils;
import org.folio.test.config.TestModuleConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestIntegrationService {

  private static final Logger logger = LoggerFactory.getLogger(TestIntegrationService.class);
  private static final String PROJECT_NAME = "ThunderJet";

  private final Map<String, Results> resultsMap;
  private final TestModuleConfiguration testModuleConfiguration;

  private final ObjectMapper mapper;


  public TestIntegrationService(TestModuleConfiguration testModuleConfiguration) {
    this.testModuleConfiguration = testModuleConfiguration;
    this.resultsMap = new ConcurrentHashMap<>();

    mapper = new ObjectMapper();
    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

  }

  private void internalRun(String path, String featureName) {
    Results results = Runner.path(path)
        .tags("~@Ignore", "~@NoTestRail")
        .parallel(1);

    try {
      generateReport(results.getReportDir());
    } catch (IOException ioe) {
      logger.error("Error occurred during feature's report generation: {}", ioe.getMessage());
    }
    resultsMap.put(featureName, results);

    assert results.getFailCount() == 0;
    logger.debug("feature {} run result {} ", path, results.getErrorMessages());
  }

  public void runFeatureTest(String testFeatureName) {
    if (StringUtils.isBlank(testFeatureName)) {
      logger.warn("No test feature name specified");
      return;
    }
    if (!testFeatureName.endsWith("feature")) {
      testFeatureName = testFeatureName.concat(".feature");
    }
    internalRun(testModuleConfiguration.getBasePath().concat(testFeatureName), testFeatureName);
  }

  public Collection<File> listFiles(Path start) throws IOException {
    return Files.walk(start, Integer.MAX_VALUE)
        .map(Path::toFile)
        .filter(s -> s.getAbsolutePath().endsWith(".json"))
        .collect(Collectors.toList());
  }

  public void generateReport(String karateOutputPath) throws IOException {
    Collection<File> jsonFiles = listFiles(Paths.get(karateOutputPath));
    List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
    jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
    Configuration config = new Configuration(new File("target"), PROJECT_NAME);
    config.setNotFailingStatuses(Collections.singleton(Status.UNDEFINED));
    ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);


    jsonPaths.forEach(path->{
      try {
        JsonNode jsonNode = mapper.readTree(new File(path));
        jsonNode.findParents("tags").stream()
            .filter(parent -> parent.get("steps") != null && parent.get("tags").findValue("name") != null
              && parent.get("tags").findValue("name").textValue().equals("@Undefined"))
            .forEach(parent -> {
              Optional.ofNullable((ObjectNode) parent.findPath("result"))
                  .ifPresent(result -> result.put("status", "undefined"));
            });

        JsonGenerator generator = mapper.getFactory().createGenerator(new File(path), JsonEncoding.UTF8);
        mapper.writeTree(generator, jsonNode);

      } catch (IOException e) {
        logger.error("Exception in updating statuses for undefined tests", e);
      }
    });

    reportBuilder.generateReports();
  }

  public TestModuleConfiguration getTestConfiguration() {
    return testModuleConfiguration;
  }

  public void addResult(String testName, Results results) {
    resultsMap.put(testName, results);
  }
}
