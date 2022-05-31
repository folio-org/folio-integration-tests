package org.folio.util;

import java.sql.SQLOutput;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class UserUtil {

    private static final int CREATED_DATE_INDEX = 21;
    private static final int UPDATED_DATE_INDEX = 22;

    /**
     * Compares user csv file content without taking into account the user CreatedDate and UpdateDate fields
     * since the expected csv file is hardcoded and those fields will not be matching
     *
     * @param expectedCsv - file system expectedCsv file
     * @param obtainedCsv - obtainedCsv file from bulk-edit API
     */
    public boolean compareUsersCsvFilesString(String expectedCsv, String obtainedCsv) {
        String editedExpectedCsv = replaceCreatedAndUpdatedDatesWithEmptyStrings(expectedCsv, true);
        String editedObtainedCsv = replaceCreatedAndUpdatedDatesWithEmptyStrings(obtainedCsv, false);
        if (editedExpectedCsv.equals(editedObtainedCsv)) {
            System.out.println("strings are equal");
            return true;
        }
        System.out.println("strings are not equal");
        return false;
    }

    public boolean compareItemsCsvFilesString(String expectedCsv, String obtainedCsv) {
        if (expectedCsv.trim().equalsIgnoreCase(obtainedCsv.trim())) {
            System.out.println("strings are equal");
            return true;
        }
        System.out.println("strings are not equal");
        return false;
    }

    private String replaceCreatedAndUpdatedDatesWithEmptyStrings(String csvStringToModify, boolean shouldUseSystemLineSeparator) {
        String lineSeparator = shouldUseSystemLineSeparator ? System.lineSeparator() : "\\n";
        List<String> csvStrings = Arrays.asList(csvStringToModify.split(lineSeparator));
        List<String> editedCsvStrings = new ArrayList<>();
        editedCsvStrings.add(csvStrings.get(0));
        csvStrings.stream()
                .skip(1)
                .map(csvString -> {
                    StringBuilder editedCsvString = new StringBuilder();
                    List<String> csvStringValues = Arrays.asList(csvString.split(","));
                    csvStringValues.set(UPDATED_DATE_INDEX, "");
                    csvStringValues.set(CREATED_DATE_INDEX, "");
                    csvStringValues.forEach(csvColumnValue -> editedCsvString.append(csvColumnValue)
                            .append(","));
                    return editedCsvString.toString();
                })
                .collect(Collectors.toCollection(() -> editedCsvStrings));

        StringBuilder modifiedCsvString = new StringBuilder();
        editedCsvStrings.forEach(str -> modifiedCsvString.append(str)
                .append(System.lineSeparator()));
        return modifiedCsvString.toString();
    }

    public boolean compareErrorsCsvFiles(String expectedCsv, String obtainedCsv) {
        String expectedErrorsCsv = String.join(",", Arrays.asList(expectedCsv.split(System.lineSeparator())));
        String obtainedErrorsCsv = String.join(",", Arrays.asList(obtainedCsv.split("\\n")));
        return expectedErrorsCsv.equals(obtainedErrorsCsv);
    }

}
