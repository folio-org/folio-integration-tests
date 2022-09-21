package test.java;

import java.io.FileOutputStream;
import java.io.BufferedOutputStream;

public class WriteData {
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
}