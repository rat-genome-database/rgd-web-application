package edu.mcw.rgd.phenominer.frontend;

import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author mtutaj
 * @since 5/11/2017
 * <p>
 * generates XML tree for the data
 */
public class TreeXmlController implements Controller {


	public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String ontId = "RS"; // default ontology
		int speciesTypeKey = 3;

		String spParam = Utils.defaultString(request.getParameter("species"));
		if( spParam.equals("4") ) {
			speciesTypeKey = 4;
		}

		String ontParam = Utils.defaultString(request.getParameter("ont"));
		if (!ontParam.isEmpty()) {
			ontId = ontParam.toUpperCase();
		}

		String sex = null;
		if (ontId.equals("RS")) {
			String sexParam = Utils.defaultString(request.getParameter("sex"));
			if (sexParam.equals("male") || sexParam.equals("female")) {
				sex = sexParam;
			}
		}

		// filtering terms: split them by ontologies
		String filterTerms = Utils.defaultString(request.getParameter("terms"));

		// ontology tree object
		OTrees trees = OTrees.getInstance();

		String xml;
		if (filterTerms.isEmpty()) {
			// generate xml tree if no filters are specified
			System.out.println("here 1");
			xml = trees.generateXml(ontId, sex, speciesTypeKey);
		} else {
			System.out.println("here 2");
			xml = trees.generateXml(ontId, sex, speciesTypeKey, filterTerms);
		}

		Utils.writeStringToFile(xml, "/tmp/new.xml");

		response.setContentType("text/xml");
		response.setContentLength(xml.length());
		response.getOutputStream().print(xml);
		return null;
	}
}
