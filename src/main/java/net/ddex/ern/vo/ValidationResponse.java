package net.ddex.ern.vo;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

/**
 * Created by rdewilde on 5/16/2017.
 */
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class ValidationResponse {

    private Boolean isError = false;
    private Boolean isSchemaValid;
    private Boolean isSchematronValid;

    private List<String> schemaMessages;
    private List<String> schematronMessages;

    public boolean isError() {
        return isError;
    }

    public void setError(Boolean error) {
        isError = error;
    }

    public Boolean isSchemaValid() {
        return isSchemaValid;
    }

    public void setSchemaValid(Boolean schemaValid) {
        isSchemaValid = schemaValid;
    }

    public Boolean isSchematronValid() {

        return isSchematronValid;
    }

    public void setSchematronValid(boolean schematronValid) {
        isSchematronValid = schematronValid;
    }

    public List<String> getSchemaMessages() {
        return schemaMessages;
    }

    public void setSchemaMessages(List<String> schemaMessages) {
        this.schemaMessages = schemaMessages;
    }

    public List<String> getSchematronMessages() {
        return schematronMessages;
    }

    public void setSchematronMessages(List<String> schematronMessages) {
        this.schematronMessages = schematronMessages;
    }
}
