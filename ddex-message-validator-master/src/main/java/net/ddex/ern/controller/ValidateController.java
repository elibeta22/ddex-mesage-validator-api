package net.ddex.ern.controller;

import net.ddex.ern.exception.ValidatorException;
import net.ddex.ern.schema.ThreeFourOneSchema;
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

    @PostMapping(path = "/xml/{ernVersion}/{profileVersion}", produces = "text/plain")
    public String xmlPathParam(@PathVariable String ernVersion, @PathVariable String profileVersion,
                               @RequestParam(value = "ernFile") MultipartFile file)
            throws ParserConfigurationException, SAXException, IOException,
            XMLStreamException, TransformerException, XPathExpressionException {

        logger.info("Validating ERN version {} against profile {}. ", ernVersion, profileVersion);
        schematronService.schematron2XML(file.getInputStream());
        return "";
    }

  @PostMapping(path = "/status", produces = "text/plain")
  public String test()
          throws ParserConfigurationException, SAXException, IOException,
          XMLStreamException, TransformerException, XPathExpressionException {

    return "The service is running";
  }

  @PostMapping(path = "/json/validateSchematron", produces = "application/json")
  public List<Map<String, String>> validateSchematronJSON(@RequestParam(value = "ernFile") MultipartFile file)
          throws ParserConfigurationException, SAXException, IOException,
          XMLStreamException, TransformerException, XPathExpressionException {
    logger.info("Validating ERN {} as version {}. ", file.getOriginalFilename(), "ERN-3.4.1");
    return schematronService.schematron2Map(file.getInputStream());
  }

    @PostMapping(path = "/json/validateSchema")
    public String validateSchemaJSON(@RequestParam(value = "ernFile") MultipartFile file) throws ValidatorException, ParserConfigurationException, IOException, SAXException {
        logger.info("Test validate method {}", "Blam");
        //FileInputStream is  = new FileInputStream(new File("xml/sme-album.xml"));
//        ThreeFourOneSchema schema = new ThreeFourOneSchema();
        ThreeFourOneSchema schemaLove = new ThreeFourOneSchema();

        try {
            return schemaLove.validate(schemaService.validate(file.getInputStream()),null);
        } catch(IOException e) {
            logger.error(e.getMessage());
            return e.getMessage();
        } catch(ValidatorException e) {
            logger.error(e.getMessage());
            return e.getMessage();
        }catch (SAXException e){
            logger.error(e.getMessage());
            return e.getMessage();

        }

    }

    @ExceptionHandler
    public ValidationResponse handleValidatorException(ValidatorException ex) {
        ex.printStackTrace();
        return new ValidationResponse();
    }

}
