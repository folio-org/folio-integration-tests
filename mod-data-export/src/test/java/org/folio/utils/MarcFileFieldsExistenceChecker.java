package org.folio.utils;

import java.util.List;
import java.util.stream.IntStream;
import org.marc4j.marc.DataField;
import org.marc4j.marc.Record;

public class MarcFileFieldsExistenceChecker {

    public static boolean checkForFieldsExistence(byte[] marcFile) {
        Record actual = MarcFileData.convertByteArrayToRecordSortedByTag(marcFile);
        Record expected = MarcFileData.createTestRecordSortedByTag();
        List<DataField> actualDataFields = actual.getDataFields();
        List<DataField> expectedDataFields = expected.getDataFields();

        return IntStream.range(0, actualDataFields.size()).allMatch(index -> compareTwoFields(index, actualDataFields, expectedDataFields));
    }

    private static boolean compareTwoFields(int index, List<DataField> actualFields, List<DataField> expectedDataFields) {
        return actualFields.get(index).compareTo(expectedDataFields.get(index)) == 0;
    }
}
