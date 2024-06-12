package org.folio.utils;

import org.marc4j.MarcReader;
import org.marc4j.MarcStreamReader;
import org.marc4j.marc.*;
import org.marc4j.marc.Record;
import org.marc4j.marc.impl.MarcFactoryImpl;

import java.io.ByteArrayInputStream;
import java.util.Comparator;

public class MarcFileHoldingFieldsExistenceChecker {

    private final Record record;
    private final MarcFactory marcFactory;
    private static final char EMPTY_CHAR = ' ';


    public MarcFileHoldingFieldsExistenceChecker(byte[] marcFile) {
        this.record = convertByteArrayToRecordSortedByTag(marcFile);
        this.marcFactory = new MarcFactoryImpl();
    }

    public boolean checkForHrId() {
        ControlField expectedField = marcFactory.newControlField();
        expectedField.setData("oho00016100198");
        expectedField.setTag("001");
        return record.getControlFields().stream().anyMatch(actualField -> actualField.compareTo(expectedField) == 0);
    }

    public boolean checkForInstanceId() {
        ControlField expectedField = marcFactory.newControlField();
        expectedField.setData("inst83oromwtp");
        expectedField.setTag("004");
        return record.getControlFields().stream().anyMatch(actualField -> actualField.compareTo(expectedField) == 0);
    }

    public boolean checkForHoldingStatementField() {
        DataField expectedField = marcFactory.newDataField();
        expectedField.setIndicator1(EMPTY_CHAR);
        expectedField.setIndicator2('0');
        expectedField.setTag("866");
        return record.getDataFields().stream().anyMatch(dataField -> compareTwoDataFields(dataField, expectedField));
    }

    public boolean checkForHoldingStatementSubField() {
        Subfield holdingStatement = marcFactory.newSubfield();
        holdingStatement.setCode('a');
        holdingStatement.setData("testHoldingStatement");
        return record.getDataFields().stream().flatMap(dataField -> dataField.getSubfields().stream()).anyMatch(subfield -> compareTwoSubfields(subfield, holdingStatement));
    }

    public boolean checkForHoldingStatementNoteSubField() {
        Subfield holdingStatementPublicNote = marcFactory.newSubfield();
        holdingStatementPublicNote.setCode('z');
        holdingStatementPublicNote.setData("testStatementPublicNote");
        return record.getDataFields().stream().flatMap(dataField -> dataField.getSubfields().stream()).anyMatch(subfield -> compareTwoSubfields(subfield, holdingStatementPublicNote));
    }

    public boolean checkForHoldingStatementForSupplementsField() {
        DataField expectedField = marcFactory.newDataField();
        expectedField.setIndicator1(EMPTY_CHAR);
        expectedField.setIndicator2('0');
        expectedField.setTag("867");
        return record.getDataFields().stream().anyMatch(dataField -> compareTwoDataFields(dataField, expectedField));
    }

    public boolean checkForHoldingStatementForSupplementsSubField() {
        Subfield holdingStatement = marcFactory.newSubfield();
        holdingStatement.setCode('a');
        holdingStatement.setData("testStatementForSupplements");
        return record.getDataFields().stream()
                .flatMap(dataField -> dataField.getSubfields().stream())
                .anyMatch(subfield -> compareTwoSubfields(subfield, holdingStatement));
    }

    public boolean checkForHoldingStatementForSupplementsNoteSubField() {
        Subfield holdingStatement = marcFactory.newSubfield();
        holdingStatement.setCode('z');
        holdingStatement.setData("testStatementForSupplementsPublicNote");
        return record.getDataFields().stream()
                .flatMap(dataField -> dataField.getSubfields().stream())
                .anyMatch(subfield -> compareTwoSubfields(subfield, holdingStatement));
    }

    public boolean checkForHoldingStatementForIndexesField() {
        DataField expectedField = marcFactory.newDataField();
        expectedField.setIndicator1(EMPTY_CHAR);
        expectedField.setIndicator2('0');
        expectedField.setTag("868");
        return record.getDataFields().stream().anyMatch(dataField -> compareTwoDataFields(dataField, expectedField));
    }

    public boolean checkForHoldingStatementForIndexesSubField() {
        Subfield holdingStatement = marcFactory.newSubfield();
        holdingStatement.setCode('a');
        holdingStatement.setData("testStatementForIndexes");
        return record.getDataFields().stream()
                .flatMap(dataField -> dataField.getSubfields().stream())
                .anyMatch(subfield -> compareTwoSubfields(subfield, holdingStatement));
    }

    public boolean checkForHoldingStatementForIndexesNoteSubField() {
        Subfield holdingStatement = marcFactory.newSubfield();
        holdingStatement.setCode('z');
        holdingStatement.setData("testStatementForIndexesPublicNote");
        return record.getDataFields().stream()
                .flatMap(dataField -> dataField.getSubfields().stream())
                .anyMatch(subfield -> compareTwoSubfields(subfield, holdingStatement));
    }

    public boolean checkForHoldingUuidField() {
        DataField expectedField = marcFactory.newDataField();
        expectedField.setIndicator1('f');
        expectedField.setIndicator2('f');
        expectedField.setTag("999");
        return record.getDataFields().stream()
                .anyMatch(actualField -> compareTwoDataFields(actualField, expectedField));
    }

    public boolean checkForHoldingUuidSubfield() {
        Subfield expectedField = marcFactory.newSubfield();
        expectedField.setCode('i');
        expectedField.setData("1aafaeef-4928-477b-86f5-9431ba754692");
        return record.getDataFields().stream()
                .flatMap(dataField -> dataField.getSubfields().stream())
                .anyMatch(subfield -> compareTwoSubfields(subfield, expectedField));
    }

    private static boolean compareTwoSubfields(Subfield subfield, Subfield holdingStatement) {
        return subfield.getCode() == holdingStatement.getCode() && subfield.getData().equals(holdingStatement.getData());
    }

    private static boolean compareTwoDataFields(DataField dataField, DataField expectedField) {
        return expectedField.getIndicator1() == dataField.getIndicator1() &&
                expectedField.getIndicator2() == dataField.getIndicator2() &&
                expectedField.getTag().equals(dataField.getTag());
    }

    private Record convertByteArrayToRecordSortedByTag(byte[] marcFile) {
        ByteArrayInputStream inputStream = new ByteArrayInputStream(marcFile);
        MarcReader reader = new MarcStreamReader(inputStream);
        Record record = reader.next();
        record.getDataFields().sort(Comparator.comparing(DataField::getTag));
        return record;
    }
}
