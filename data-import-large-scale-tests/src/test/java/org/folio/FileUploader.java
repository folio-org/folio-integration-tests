package org.folio;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.InputStreamEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

import java.io.ByteArrayInputStream;
import java.io.IOException;

/**
 * Utility class for uploading files to a specified URL using HTTP PUT method
 * for excluding binary data from the request body in tests results.
 */
public class FileUploader {

    public static HttpResponse uploadBytes(String url, String contentType, byte[] data) throws IOException {
        try (CloseableHttpClient client = HttpClients.createDefault();
             ByteArrayInputStream bais = new ByteArrayInputStream(data)) {

            HttpPut put = new HttpPut(url);
            put.setHeader("Content-Type", contentType);

            InputStreamEntity reqEntity = new InputStreamEntity(bais, data.length);
            put.setEntity(reqEntity);
            return client.execute(put);
        }
    }
}