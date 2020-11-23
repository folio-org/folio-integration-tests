package org.folio;//package org.folio;


import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import com.gurock.testrail.APIClient;

public class TestRailUtilsNew{

    static {
        APIClient client = new APIClient("http://<server>/testrail/");

    }

        public static Properties loadProperties(){
//        String env = Optional.ofNullable(System.getProperty("env")).orElse("localhost");
        String env = "testrail";
        Properties properties = new Properties();
        InputStream is = ClassLoader.class.getResourceAsStream("/" +env + ".properties");
        try {
            properties.load(is);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return properties;
    }

}