package org.folio.utils;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.marc4j.MarcReader;
import org.marc4j.MarcStreamReader;
import org.marc4j.marc.DataField;
import org.marc4j.marc.Leader;
import org.marc4j.marc.MarcFactory;
import org.marc4j.marc.Record;
import org.marc4j.marc.Subfield;
import org.marc4j.marc.impl.MarcFactoryImpl;
import org.marc4j.marc.impl.SubfieldImpl;

public class MarcFileInstanceFieldsExistenceChecker {

    private final List<Record> records;
    private final MarcFactory marcFactory;
    private static final char EMPTY_CHAR = ' ';


    public MarcFileInstanceFieldsExistenceChecker(byte[] marcFile) {
        this.records = convertByteArrayToRecordSortedByTag(marcFile);
        System.out.println("Total records parsed: " + records.size());
        this.marcFactory = new MarcFactoryImpl();
    }

    public boolean checkLeaderStatus(char status) {
        var leader = marcFactory.newLeader();
        leader.setRecordStatus(status);
        return checkForLeaderStatus(leader);
    }

    public boolean checkLccn() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("010");
        SubfieldImpl subfield = new SubfieldImpl('a', "LCCN");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkCancelledSystemControlNumbers() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("019");
        Subfield subfield = new SubfieldImpl('a', "Cancelled System Control Numbers");
        dataField.addSubfield(subfield);
        records.forEach(rec -> rec.addVariableField(dataField));
        return checkForFieldExistence(dataField);
    }

    public boolean checkIsbn() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("020");
        Subfield subfield = new SubfieldImpl('a', "ISBN");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkInvalidIsbn() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("020");
        Subfield subfield = new SubfieldImpl('a', "0552142352");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "97805521423510");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkIssn() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("022");
        Subfield subfield = new SubfieldImpl('a', "ISSN");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('l', "Linkin ISSN");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "Invalid ISSN");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkUpc() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('1');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "UPC");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkInvalidUpc() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('1');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('z', "Invalid UPC");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkIsmn() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('2');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "ISMN");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkInvalidIssn() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('2');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('z', "Invalid ISMN");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkDoi() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('7');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "DOI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('2', "doi");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkHandle() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('7');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "Handle");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('2', "hdl");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkUrn() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('7');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "URN");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('2', "urn");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkAsin() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "ASIN");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "ASIN");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkBnb() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "97805521423512");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "BNB");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkLocalIdentifier() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "97805521423516");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "Local identifier");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkOtherStandartIdentifier() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "97805521423524");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "Other standard identifier");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkStdEdNl() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "97805521423519");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "StEdNL");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkUkMac() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        Subfield subfield = new SubfieldImpl('a', "UkMac");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "UkMac");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkPublisherDistributionNumber() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('5');
        dataField.setIndicator2('2');
        dataField.setTag("028");
        Subfield subfield = new SubfieldImpl('a', "Publisher or Distributor Number");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkCoden() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("030");
        Subfield subfield = new SubfieldImpl('a', "CODEN");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkSystemControlNumber() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("035");
        Subfield subfield = new SubfieldImpl('a', "System Control Number");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkGpoItemNumber() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("074");
        Subfield subfield = new SubfieldImpl('a', "GPO Item Number");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "97805521423529");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkReportNumber() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("088");
        Subfield subfield = new SubfieldImpl('a', "$aReport number");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkUniformTitle() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("130");
        Subfield subfield = new SubfieldImpl('a', "Uniform title");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkTitle() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2('0');
        dataField.setTag("245");
        Subfield subfield = new SubfieldImpl('a', "e5822478-4a72-487c-a250-031dac248001");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkVariantTitle() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("246");
        Subfield subfield = new SubfieldImpl('a', "Variant title");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkFormerTitle() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2('0');
        dataField.setTag("247");
        Subfield subfield = new SubfieldImpl('a', "Former title");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkEdition() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("250");
        Subfield subfield = new SubfieldImpl('a', "Edition");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkPlacePublisherPublicationDate() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2('1');
        dataField.setTag("264");
        Subfield subfield = new SubfieldImpl('a', "Place");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('b', "Publisher");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('c', "Publication date");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkPublicationFrequency() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("310");
        Subfield subfield = new SubfieldImpl('a', "Publication frequency");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkText() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("336");
        Subfield subfield = new SubfieldImpl('a', "text");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkPublicationRange() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('1');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("362");
        Subfield subfield = new SubfieldImpl('a', "Publication range");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkSeriesStatements() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("490");
        Subfield subfield = new SubfieldImpl('a', "Series statements");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkGeneralNote() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("500");
        Subfield subfield = new SubfieldImpl('a', "General note");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkSubjects() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("653");
        Subfield subfield = new SubfieldImpl('a', "Subjects");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkGenre() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2('4');
        dataField.setTag("655");
        Subfield subfield = new SubfieldImpl('a', "comic (book)");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkContributorPersonalName() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('1');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("700");
        Subfield subfield = new SubfieldImpl('a', "Pratchett, Terry");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkContributorCorporateName() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('2');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("710");
        Subfield subfield = new SubfieldImpl('a', "Corporate name");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkContributorMeetingName() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('2');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("711");
        Subfield subfield = new SubfieldImpl('a', "Meeting name");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkElectronicAccessResourceRelationship() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('4');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("856");
        Subfield subfield = new SubfieldImpl('u', "URI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('y', "Link text");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "URL public note");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('3', "Material specified");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkElectronicAccessVersionOfResourceRelationship() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('4');
        dataField.setIndicator2('0');
        dataField.setTag("856");
        Subfield subfield = new SubfieldImpl('u', "URI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('y', "Link text");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "URL public note");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('3', "Material specified");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkElectronicAccessRelatedResourceRelationship() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('4');
        dataField.setIndicator2('1');
        dataField.setTag("856");
        Subfield subfield = new SubfieldImpl('u', "URI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('y', "Link text");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "URL public note");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('3', "Material specified");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkElectronicAccessOtherRelationship() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('4');
        dataField.setIndicator2('2');
        dataField.setTag("856");
        Subfield subfield = new SubfieldImpl('u', "URI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('y', "Link text");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "URL public note");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('3', "Material specified");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkId() {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('f');
        dataField.setIndicator2('f');
        dataField.setTag("999");
        Subfield subfield = new SubfieldImpl('i', "b73eccf0-57a6-495e-898d-32b9b2210f2f");
        dataField.addSubfield(subfield);
        return checkForFieldExistence(dataField);
    }

    public boolean checkDeletedAuthority(String idI, String idS) {
        return checkAuthorityIdExists(idI, idS) && checkLeaderStatus('d');
    }

    private boolean checkAuthorityIdExists(String idI, String idS) {
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1('f');
        dataField.setIndicator2('f');
        dataField.setTag("999");
        Subfield subfieldS = new SubfieldImpl('s', idS);
        dataField.addSubfield(subfieldS);
        Subfield subfieldI = new SubfieldImpl('i', idI);
        dataField.addSubfield(subfieldI);
        return checkForFieldExistence(dataField);
    }

    private List<Record> convertByteArrayToRecordSortedByTag(byte[] marcFile) {
        List<Record> records = new ArrayList<>();
        ByteArrayInputStream inputStream = new ByteArrayInputStream(marcFile);
        MarcReader reader = new MarcStreamReader(inputStream);
        while (reader.hasNext()) {
            Record record = reader.next();
            record.getDataFields().sort(Comparator.comparing(DataField::getTag));
            records.add(record);
        }
        return records;
    }

    private boolean checkForFieldExistence(DataField expectedField) {
        return records.stream().flatMap(rec -> rec.getDataFields().stream()).anyMatch(actualField -> actualField.compareTo(expectedField) == 0);
    }

    private boolean checkForLeaderStatus(Leader expectedLeader) {
        return records.stream().map(Record::getLeader).anyMatch(rec -> rec.getRecordStatus() == expectedLeader.getRecordStatus());
    }
}
