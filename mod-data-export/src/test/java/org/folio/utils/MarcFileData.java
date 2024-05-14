package org.folio.utils;

import java.io.ByteArrayInputStream;
import java.util.Comparator;
import org.marc4j.MarcReader;
import org.marc4j.MarcStreamReader;
import org.marc4j.marc.DataField;
import org.marc4j.marc.MarcFactory;
import org.marc4j.marc.Record;
import org.marc4j.marc.impl.MarcFactoryImpl;
import org.marc4j.marc.impl.SubfieldImpl;

public class MarcFileData {

    private static final char EMPTY_CHAR = ' ';

    public static Record convertByteArrayToRecordSortedByTag(byte[] marcFile) {
        ByteArrayInputStream inputStream = new ByteArrayInputStream(marcFile);
        MarcReader reader = new MarcStreamReader(inputStream);
        Record record = reader.next();
        record.getDataFields().sort(Comparator.comparing(DataField::getTag));
        return record;
    }

    public static Record createTestRecordSortedByTag() {
        MarcFactory marcFactory = new MarcFactoryImpl();
        Record record = marcFactory.newRecord();

        //0
        DataField dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("010");
        SubfieldImpl subfield = new SubfieldImpl('a', "97805521423518");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //1
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("019");
        subfield = new SubfieldImpl('a', "97805521423527");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //2
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("020");
        subfield = new SubfieldImpl('a', "0552142352");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "97805521423510");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //3
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("020");
        subfield = new SubfieldImpl('a', "9780552142352");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //4
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("022");
        subfield = new SubfieldImpl('a', "97805521423521");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('l', "97805521423523");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "97805521423522");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //5
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('1');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423534");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //6
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('1');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('z', "97805521423535");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //7
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('2');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423532");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //8
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('2');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('z', "97805521423533");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //9
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('7');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423514");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('2', "doi");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //10
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('7');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423515");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('2', "hdl");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //11
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('7');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423517");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('2', "urn");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //12
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423511");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "ASIN");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //13
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423512");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "BNB");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //14
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423516");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "Local identifier");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //15
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423519");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "StEdNL");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //16
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423524");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "Other standard identifier");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //17
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('8');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("024");
        subfield = new SubfieldImpl('a', "97805521423530");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('q', "UkMac");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //18
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('5');
        dataField.setIndicator2('2');
        dataField.setTag("028");
        subfield = new SubfieldImpl('a', "97805521423525");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //19
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("030");
        subfield = new SubfieldImpl('a', "97805521423513");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //20
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("035");
        subfield = new SubfieldImpl('a', "97805521423526");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //21
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("074");
        subfield = new SubfieldImpl('a', "97805521423528");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "97805521423529");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //22
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("088");
        subfield = new SubfieldImpl('a', "97805521423531");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //23
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("130");
        subfield = new SubfieldImpl('a', "Uniform title");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //24
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2('0');
        dataField.setTag("245");
        subfield = new SubfieldImpl('a', "e5822478-4a72-487c-a250-031dac248001");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //25
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("246");
        subfield = new SubfieldImpl('a', "Variant title");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //26
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2('0');
        dataField.setTag("247");
        subfield = new SubfieldImpl('a', "Former title");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //27
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("250");
        subfield = new SubfieldImpl('a', "Edition");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //28
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2('1');
        dataField.setTag("264");
        subfield = new SubfieldImpl('a', "Place");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('b', "Publisher");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('c', "Publication date");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //29
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("310");
        subfield = new SubfieldImpl('a', "Publication frequency");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //30
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("336");
        subfield = new SubfieldImpl('a', "text");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //31
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('1');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("362");
        subfield = new SubfieldImpl('a', "Publication range");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //32
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('0');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("490");
        subfield = new SubfieldImpl('a', "Series statements");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //33
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("500");
        subfield = new SubfieldImpl('a', "General note");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //34
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("653");
        subfield = new SubfieldImpl('a', "Subjects");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //35
        dataField = marcFactory.newDataField();
        dataField.setIndicator1(EMPTY_CHAR);
        dataField.setIndicator2('4');
        dataField.setTag("655");
        subfield = new SubfieldImpl('a', "comic (book)");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //36
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('1');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("700");
        subfield = new SubfieldImpl('a', "Pratchett, Terry");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //37
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('2');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("710");
        subfield = new SubfieldImpl('a', "Corporate name");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //38
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('2');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("711");
        subfield = new SubfieldImpl('a', "Meeting name");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //39
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('4');
        dataField.setIndicator2(EMPTY_CHAR);
        dataField.setTag("856");
        subfield = new SubfieldImpl('u', "URI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('y', "Link text");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "URL public note");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('3', "Material specified");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //40
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('4');
        dataField.setIndicator2('0');
        dataField.setTag("856");
        subfield = new SubfieldImpl('u', "URI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('y', "Link text");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "URL public note");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('3', "Material specified");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //41
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('4');
        dataField.setIndicator2('1');
        dataField.setTag("856");
        subfield = new SubfieldImpl('u', "URI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('y', "Link text");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "URL public note");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('3', "Material specified");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //42
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('4');
        dataField.setIndicator2('2');
        dataField.setTag("856");
        subfield = new SubfieldImpl('u', "URI");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('y', "Link text");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('z', "URL public note");
        dataField.addSubfield(subfield);
        subfield = new SubfieldImpl('3', "Material specified");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        //43
        dataField = marcFactory.newDataField();
        dataField.setIndicator1('f');
        dataField.setIndicator2('f');
        dataField.setTag("999");
        subfield = new SubfieldImpl('i', "b73eccf0-57a6-495e-898d-32b9b2210f2f");
        dataField.addSubfield(subfield);
        record.addVariableField(dataField);

        record.getDataFields().sort(Comparator.comparing(DataField::getTag));

        return record;
    }
}
