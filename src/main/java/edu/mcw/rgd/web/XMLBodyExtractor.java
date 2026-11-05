package edu.mcw.rgd.web;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.*;

public class XMLBodyExtractor {
    public static String extractBodyText(String xml) {
        try {
            //String xml = "<?xml version=\"1.0\"?><root><header>Info</header><body><section>Hello XML Body</section></body></root>";

            // Parse the XML string
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(new java.io.ByteArrayInputStream(xml.getBytes("UTF-8")));

            // Normalize and extract the <body> tag
            doc.getDocumentElement().normalize();
            NodeList bodyList = doc.getElementsByTagName("body");

            if (bodyList.getLength() > 0) {
                Element bodyElement = (Element) bodyList.item(0);
                String bodyContent = nodeToString(bodyElement);
                return bodyContent;
            } else {
                return "<body> tag not found.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            return e.getMessage();
        }
    }

    // Helper method to convert a Node to a String
    private static String nodeToString(Node node) throws Exception {
        javax.xml.transform.Transformer transformer =
                javax.xml.transform.TransformerFactory.newInstance().newTransformer();
        transformer.setOutputProperty(javax.xml.transform.OutputKeys.OMIT_XML_DECLARATION, "yes");
        transformer.setOutputProperty(javax.xml.transform.OutputKeys.INDENT, "yes");

        java.io.StringWriter writer = new java.io.StringWriter();
        transformer.transform(new javax.xml.transform.dom.DOMSource(node),
                new javax.xml.transform.stream.StreamResult(writer));
        return writer.toString();
    }
}
