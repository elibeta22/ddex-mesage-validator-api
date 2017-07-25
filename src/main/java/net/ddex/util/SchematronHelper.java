package net.ddex.util;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.stax.StAXSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.net.MalformedURLException;

/**
 * Created by rdewilde on 4/17/2017.
 */
public class SchematronHelper {

    private static String PROFILE = "NewReleaseMessage_ReleaseProfile_AudioAlbumMusicOnly_14";
    private static String SCHEMATRON_DIR = "schematron";

    public static void main(String[] args) {

        SchematronHelper xml = new SchematronHelper();
        try {
            xml.transformChain();
        } catch(Exception e) {
            System.out.println(e);
        }
     }


    public void transformChain() throws XMLStreamException, IOException, TransformerException {
        SAXTransformerFactory stf = (SAXTransformerFactory)TransformerFactory.newInstance();

        Templates iso_dsdl_include = stf.newTemplates(new StreamSource(
                new File("xslt/iso_dsdl_include.xsl")));
        Templates iso_abstract_expand = stf.newTemplates(new StreamSource(
                new File("xslt/iso_abstract_expand.xsl")));
        Templates iso_svrl_for_xslt2 = stf.newTemplates(new StreamSource(
                new File("xslt/iso_svrl_for_xslt2.xsl")));

        TransformerHandler th1 = stf.newTransformerHandler(iso_dsdl_include);
        TransformerHandler th2 = stf.newTransformerHandler(iso_abstract_expand);
        TransformerHandler th3 = stf.newTransformerHandler(iso_svrl_for_xslt2);

        String outFile = String.format("xslt/release-profiles/%s.xslt", PROFILE);
        th1.setResult(new SAXResult(th2));
        th2.setResult(new SAXResult(th3));
        th3.setResult(new StreamResult(new File(outFile)));

        String inputFile = String.format("{}/{}.xslt", SCHEMATRON_DIR, PROFILE);
        Transformer t = stf.newTransformer();
        t.transform(new StreamSource(inputFile), new SAXResult(th1));
    }

}
