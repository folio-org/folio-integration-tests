package test.java;

import org.marc4j.MarcJsonReader;
import org.marc4j.MarcStreamWriter;
import org.marc4j.marc.Record;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class MarcConverter {

    /**
     * Converts a MARC JSON file at the given path to MARC binary format
     *
     * @param jsonFilePath the path to the MARC JSON file
     * @return byte array containing the MARC binary data
     * @throws IOException if the file cannot be read or the conversion fails
     */
    public static byte[] convertJsonFileToBinary(String jsonFilePath) throws IOException {
        // Read the MARC JSON file
        String jsonContent = new String(Files.readAllBytes(Paths.get(jsonFilePath)));
        return convertJsonStringToBinary(jsonContent);
    }

    /**
     * Converts MARC JSON content string to MARC binary format
     *
     * @param jsonContent the MARC JSON content as a string
     * @return byte array containing the MARC binary data
     * @throws IOException if the conversion fails
     */
    public static byte[] convertJsonStringToBinary(String jsonContent) throws IOException {
        try {
            // Create an input stream from the JSON content
            ByteArrayInputStream inputStream = new ByteArrayInputStream(jsonContent.getBytes());

            // Create a MarcJsonReader
            MarcJsonReader reader = new MarcJsonReader(inputStream);

            // Create an output stream for the binary MARC data
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            MarcStreamWriter writer = new MarcStreamWriter(outputStream, "UTF-8");

            // Read the MARC record and write it to the output stream
            if (reader.hasNext()) {
                Record record = reader.next();
                writer.write(record);
            }

            writer.close();
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new IOException("Failed to convert MARC JSON to binary: " + e.getMessage(), e);
        }
    }
}
