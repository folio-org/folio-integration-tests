package org.folio;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import org.junit.jupiter.api.Test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;

import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;

class GulfstreamTests {

    @Test
    void oaiPmhbasicTests() throws IOException {
        Results results = Runner.path("classpath:domain/oaipmh/oaipmh-basic.feature")
                .tags("~@Ignore")
                .parallel(1);
        generateReport(results.getReportDir());
        assert results.getFailCount() == 0;
    }

    @Test
    void oaiPmhEnhancementTests() throws IOException {
        Results results = Runner.path("classpath:domain/oaipmh/oaipmh-enhancement.feature")
                .tags("~@Ignore")
                .parallel(1);
        generateReport(results.getReportDir());
        assert results.getFailCount() == 0;
    }

    @Test
    void loadDefaultConfigurationTests() throws IOException {
        Results results = Runner.path("classpath:domain/mod-configuration/load-default-pmh-configuration.feature.feature")
                .tags("~@Ignore")
                .parallel(1);
        generateReport(results.getReportDir());
        assert results.getFailCount() == 0;
    }

    static void generateReport(String karateOutputPath) throws IOException {
        Collection<File> jsonFiles = listFiles(Paths.get(karateOutputPath));
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        Configuration config = new Configuration(new File("target"), "gulfstream");
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }

    static Collection<File> listFiles(Path start) throws IOException {
        return Files.walk(start, Integer.MAX_VALUE)
                .map(Path::toFile)
                .filter(s -> s.getAbsolutePath().endsWith(".json"))
                .collect(Collectors.toList());
    }

}
