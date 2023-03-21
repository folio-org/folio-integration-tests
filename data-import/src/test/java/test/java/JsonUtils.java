package test.java;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class JsonUtils {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    /**
     * compare json objects for equality, accounting for nested objects as well
     * @return true if both objects are equal
     * @throws JsonProcessingException
     */
    public static Boolean compareJson(String json1, String json2) throws JsonProcessingException {
        JsonNode json1Node = OBJECT_MAPPER.readTree(json1);
        JsonNode json2Node = OBJECT_MAPPER.readTree(json2);
        return json1Node.equals(json2Node);
    }
}
