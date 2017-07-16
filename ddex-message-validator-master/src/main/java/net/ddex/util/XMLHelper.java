package net.ddex.util;

import com.sun.javafx.binding.StringFormatter;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import javax.xml.XMLConstants;
import javax.xml.namespace.NamespaceContext;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMResult;
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
import javax.xml.xpath.*;
import java.io.*;
import java.net.MalformedURLException;
import java.util.Iterator;

/**
 * Created by rdewilde on 4/17/2017.
 */
public class XMLHelper {

    private static String XML_FILE = "schematron/NewReleaseMessage_ReleaseProfile_AudioAlbumMusicOnly_14.sch";
    private static String XSLT_FILE = "xslt/iso_dsdl_include.xsl";

    public static void main(String[] args) {

        XMLHelper xml = new XMLHelper();
        try {
            xml.xpath();
        } catch(Exception e) {
            System.out.println(e);
        }
     }

    public void validateXML() {
        try {

            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

            dbf.setNamespaceAware(true);
            DocumentBuilder parser = dbf.newDocumentBuilder();
            Document document = parser.parse(new File("schema/motherboard.pdf"));
            SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);

            Source[] schemaFiles = new Source[] {
                    new StreamSource(new File("schema/release-notification.xsd")),
                    new StreamSource(new File("schema/ddexC.xsd")),
                    new StreamSource(new File("schema/ddex.xsd")),
                    new StreamSource(new File("schema/iso3166a2.xsd")),
                    new StreamSource(new File("schema/iso4217a.xsd")),
                    new StreamSource(new File("schema/iso639a2.xsd"))
            };
            Schema schema = factory.newSchema(schemaFiles);

            Validator validator = schema.newValidator();
            validator.validate(new DOMSource(document));
        } catch (SAXParseException e) {
            e.printStackTrace();
        } catch (SAXException e) {
            e.printStackTrace();
        } catch (ParserConfigurationException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void transformDom() throws ParserConfigurationException, SAXException, IOException, TransformerException {
        // create the DOM Source
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document bbcDoc = builder.parse(new File(XML_FILE));
        DOMSource source = new DOMSource(bbcDoc);

        // Create an instance of the TransformerFactory
        TransformerFactory transfomerFactory = TransformerFactory.newInstance();
        System.out.println(transfomerFactory.getClass());
        // prints
        // com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl
        // obtain the XSLT transformer. The transformer has instructions for
        // converting the XML to HTML
        Transformer transformer = transfomerFactory.newTransformer(new StreamSource(XSLT_FILE));
        // An object to hold the results. It can be a file. In This example we
        // output to console.
        StreamResult result = new StreamResult(System.out);
        transformer.transform(source, result);
    }

    public void transfromSAX() throws ParserConfigurationException, SAXException, MalformedURLException, IOException, TransformerException {
        // Create a SAXSource from the xml
        SAXSource saxSource = new SAXSource(new InputSource(new FileReader(XML_FILE)));
        // Object to hold the result
        StreamResult result = new StreamResult(System.out);
        // the factory that provides the transformer
        TransformerFactory factory = SAXTransformerFactory.newInstance();
        // the transformer that does the transformation
        Transformer transformer = factory.newTransformer(new StreamSource(XSLT_FILE));
        // the actual transformation
        transformer.transform(saxSource, result);

    }

    public void transformStAX() throws XMLStreamException, IOException, TransformerException {
        // obtain the StAX Source
        XMLInputFactory factory = XMLInputFactory.newFactory();
        //URL url = new URL(xmlSource);
        XMLEventReader reader = factory.createXMLEventReader(new FileInputStream(XML_FILE));
        StAXSource staxSource = new StAXSource(reader);

        // The factory that produces the transformer
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Transformer transformer = transformerFactory.newTransformer(new StreamSource(XSLT_FILE));
        // An object to hold the results.
        StreamResult result = new StreamResult(System.out);
        // the transformation
        transformer.transform(staxSource, result);
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

        th1.setResult(new SAXResult(th2));
        th2.setResult(new SAXResult(th3));
        th3.setResult(new StreamResult(new File("xslt/release-profiles/NewReleaseMessage_ReleaseProfile_AudioAlbumMusicOnly_14.xslt")));

        Transformer t = stf.newTransformer();
        t.transform(new StreamSource(XML_FILE), new SAXResult(th1));
    }


    public void schematron() throws XMLStreamException, IOException, TransformerException {
        String ERN_FILE = "xml/Profile_AudioAlbumMusicOnly.xml";
        String XSLT_FILE = "xslt/release-profiles/NewReleaseMessage_ReleaseProfile_AudioAlbumMusicOnly_14.xslt";
        SAXSource saxSource = new SAXSource(new InputSource(new FileReader(XML_FILE)));
        // Object to hold the result
        StreamResult result = new StreamResult(System.out);
        SAXTransformerFactory stf = new net.sf.saxon.TransformerFactoryImpl();

        Transformer transformer = stf.newTransformer(new StreamSource(XSLT_FILE));
        // the actual transformation
        transformer.transform(saxSource, result);

    }

    public void xpath() throws FileNotFoundException, TransformerException, XPathExpressionException {
        String XSLT_FILE = "xslt/release-profiles/NewReleaseMessage_ReleaseProfile_AudioAlbumMusicOnly_14.xslt";
        String ERN_FILE = "xml/Profile_AudioAlbumMusicOnly.xml";
        SAXSource saxSource = new SAXSource(new InputSource(new FileReader(ERN_FILE)));
        DOMResult result = new DOMResult();
        SAXTransformerFactory stf = new net.sf.saxon.TransformerFactoryImpl();
        Transformer transformer = stf.newTransformer(new StreamSource(XSLT_FILE));
        transformer.transform(saxSource, result);
        XPathFactory xPathfactory = XPathFactory.newInstance();
        XPath xpath = xPathfactory.newXPath();

        xpath.setNamespaceContext(new NamespaceContext() {
            @Override
            public String getNamespaceURI(String prefix) {
                if(prefix.equals("svrl")) {
                    return "http://purl.oclc.org/dsdl/svrl";
                } else {
                    return null;
                }
            }
            @Override public String getPrefix(String namespaceURI) {
                return null; // not used
            }
            @Override
            public Iterator<?> getPrefixes(String namespaceURI) {
                return null; // not used
            }
        });

        XPathExpression expr = xpath.compile("/svrl:schematron-output/svrl:failed-assert");
        NodeList nl = (NodeList) expr.evaluate(result.getNode(),  XPathConstants.NODESET);

        StringWriter writer = new StringWriter();
        transformer = TransformerFactory.newInstance().newTransformer();


        for(int i=0; i < nl.getLength(); i++) {
            String role = String.format("/svrl:schematron-output/svrl:failed-assert[%d]/@role", i+1);
            String msg = String.format("/svrl:schematron-output/svrl:failed-assert[%d]/svrl:text", i+1);
            XPathExpression exprMsg = xpath.compile(msg);
            XPathExpression exprRole = xpath.compile(role);

            System.out.println(exprRole.evaluate(result.getNode()));
            System.out.println(exprMsg.evaluate(result.getNode()));
            System.out.println();

            //transformer.transform(new DOMSource(n), new StreamResult(writer));
            //System.out.println(writer.toString());
        }

        transformer.transform(new DOMSource(result.getNode()), new StreamResult(writer));
        String xml = writer.toString();


    }
}
