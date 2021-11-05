package test.java;

import java.io.FileOutputStream;
import java.io.BufferedOutputStream;

public class WriteData {
    public static void writeByteArrayToFile(byte[] buffer) {
        try (FileOutputStream fileOutputStream = new FileOutputStream("FAT-939-1.mrc");
             BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(fileOutputStream)) {
            bufferedOutputStream.write(buffer, 0, buffer.length);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}