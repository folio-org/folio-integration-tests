package test.java;

import com.intuit.karate.Logger;
import org.marc4j.MarcReader;
import org.marc4j.MarcStreamReader;
import org.marc4j.MarcStreamWriter;
import org.marc4j.MarcWriter;
import org.marc4j.marc.ControlField;
import org.marc4j.marc.DataField;
import org.marc4j.marc.Record;
import org.marc4j.marc.Subfield;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;

public class WriteData {
    private static Logger LOGGER = new Logger();

    public static void writeByteArrayToFile(byte[] buffer, String fileName) {
        try (FileOutputStream fileOutputStream = new FileOutputStream(fileName);
             BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(fileOutputStream)) {
            bufferedOutputStream.write(buffer, 0, buffer.length);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static byte[] replaceHrIdFieldInMarcFile(byte[] file, String oldHrId, String newHrId) {
       String text = new String(file);
       return (text.replaceFirst(oldHrId, newHrId)).getBytes();
    }

    /**
     * Modifies a MARC record by updating the value of a specific subfield within a given field.
     *
     * @param marc21ByteArray   the byte array representing the MARC record in MARC21 format
     * @param fieldTag          the tag of the field to be modified
     * @param fieldIndicator1   the first indicator of the field (applicable only for data fields)
     * @param fieldIndicator2   the second indicator of the field (applicable only for data fields)
     * @param subfieldCode      the subfield code of the subfield to be modified
     * @param subfieldValue     the new value for the subfield
     * @return                  the modified MARC record as a byte array in MARC21 format
     * @throws Exception        if an error occurs during the modification process
     */
    public static byte[] modifyMarcRecord(byte[] marc21ByteArray, String fieldTag, char fieldIndicator1, char fieldIndicator2, char subfieldCode, String subfieldValue) throws Exception {
        ByteArrayInputStream bais = new ByteArrayInputStream(marc21ByteArray);
        MarcReader reader = new MarcStreamReader(bais);
        Record record = reader.next();

        // Check if the field is a control field or a data field
        if (fieldTag.matches("00\\d")) {
            // Control field
            ControlField field = (ControlField) record.getVariableField(fieldTag);
            if (field != null) {
                record.removeVariableField(field);
                field.setData(subfieldValue);
                record.addVariableField(field);
            }
        } else {
            // Data field
            DataField field = (DataField) record.getVariableField(fieldTag);
            if (field != null) {
                field.setIndicator1(fieldIndicator1);
                field.setIndicator2(fieldIndicator2);
                Subfield subfield = field.getSubfield(subfieldCode);
                if (subfield != null) {
                    record.removeVariableField(field);
                    subfield.setData(subfieldValue);
                    record.addVariableField(field);
                }
                else {
                    LOGGER.info("modifyMarcRecord:: subfield " + subfieldCode + " not found in field " + fieldTag);
                }
            } else {
                LOGGER.info("modifyMarcRecord:: Field " + fieldTag + " not found in the record.");
            }
        }

        // Write the modified record to a byte array
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        MarcWriter writer = new MarcStreamWriter(baos, "UTF-8");
        writer.write(record);
        writer.close();

        return baos.toByteArray();
    }
}
