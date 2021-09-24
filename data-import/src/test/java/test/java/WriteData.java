package test.java;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;

public class WriteData{
    public static void writeData(String arg)
    {
        PrintWriter writer = null;
        try {
            writer = new PrintWriter("FAT-939-1.mrc", "UTF-8");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        writer.println(arg);
        writer.close();
    }
}