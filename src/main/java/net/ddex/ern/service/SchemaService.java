package net.ddex.ern.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;
import java.io.InputStream;


/**
 * Created by rdewilde on 4/16/2017.
 */

@Service("schemaService")
public class SchemaService {

    private static final Logger logger = LoggerFactory.getLogger(SchemaService.class);

    /** TODO:
     *  See if we can validate XSD using stream parser.
     *  DOM parser has potential to cause memory issues with larger documents
     */


    // TODO: look intializing doucmentbuilder.  Is it expensive to build?  Threadsafe?
    public Document validate(InputStream is) throws ParserConfigurationException, IOException , SAXException{
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        DocumentBuilder parser = null;
        parser = dbf.newDocumentBuilder();
        Document ret = parser.parse(is);
        return ret;
    }



    public Document parseDocument() throws ParserConfigurationException, SAXException, IOException{
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        DocumentBuilder parser = dbf.newDocumentBuilder();
        System.out.println("Zoinks!!!!");
        return null;
    }
}
