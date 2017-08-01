package net.ddex.ern.controller;

import net.ddex.ern.exception.ValidatorException;
import net.ddex.ern.service.SchemaService;
import net.ddex.ern.service.SchematronService;
import net.ddex.ern.vo.ValidationResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerException;
import javax.xml.xpath.XPathExpressionException;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
public class ValidateController {

  private static final Logger logger = LoggerFactory.getLogger(ValidateController.class);

  @Autowired
  private SchemaService schemaService;

  @Autowired
  private SchematronService schematronService;

  @PostMapping(path = "/json/{profileVersion}/{profile}", produces = "application/json")
  public List<Map<String, String>> jsonPathParam(@PathVariable String profileVersion, @PathVariable String profile,
                              @RequestParam(value = "ernFile") MultipartFile file) throws IOException, ValidatorException {

    logger.info("Validating ERN version {} against profile {}. ", profileVersion, profile);
    try {
        return schematronService.validate2Map(file.getInputStream(), profileVersion, profile);
    } catch(IOException e) {
        logger.error(e.getMessage());
        throw e;
    } catch(ValidatorException e) {
        logger.error(e.getMessage());
        throw e;
    }
  }

  @PostMapping(path = "/status", produces = "text/plain")
  public String test()
          throws ParserConfigurationException, SAXException, IOException,
          XMLStreamException, TransformerException, XPathExpressionException {

    return "The service is running";
  }

  @PostMapping(path = "/json/validateSchematron", produces = "application/json")
  public List<Map<String, String>> validateSchematronJSON(@RequestParam(value = "ernFile") MultipartFile file,
                                                          @RequestParam(value = "schematronVersion") String schematronVersion,
                                                          @RequestParam(value = "productVersion") String productVersion)
          throws ParserConfigurationException, SAXException, IOException,
          XMLStreamException, TransformerException, XPathExpressionException {
    logger.info("Validating ERN {} as schematron version {} and product version {}. ", file.getOriginalFilename(), schematronVersion, productVersion);
    return schematronService.schematron2Map(file.getInputStream(), schematronVersion, productVersion);
  }

    @PostMapping(path = "/json/validateSchema")
    public String validateSchemaJSON(@RequestParam("schemaVersion") String schemaVersion,
                                   @RequestParam("ernFile") MultipartFile file) throws ValidatorException, ParserConfigurationException, IOException, SAXException {
        logger.info("Validating ERN {} as schema version {}. ", file.getOriginalFilename(), schemaVersion);

        return schemaService.validate(file.getInputStream(), schemaVersion);

    }

    @ExceptionHandler
    public ValidationResponse handleValidatorException(ValidatorException ex) {
        ex.printStackTrace();
        return new ValidationResponse();
    }

}
