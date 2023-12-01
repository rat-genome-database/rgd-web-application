package edu.mcw.rgd.models;

import com.sun.mail.smtp.SMTPTransport;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainAvailablityDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.models.SubmittedStrain;
import edu.mcw.rgd.datamodel.models.SubmittedStrainAvailabiltiy;
import edu.mcw.rgd.edit.submittedStrains.EditHomePageController;
import edu.mcw.rgd.my.MyRGDLookupController;
import edu.mcw.rgd.web.VerifyRecaptcha;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.mail.Message;
import jakarta.mail.Session;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Properties;

/**
 * Created by jthota on 7/27/2016.
 */

public class StrainSubmissionFormController implements Controller {
    SubmittedStrainDao dao=new SubmittedStrainDao();
    SubmittedStrainAvailablityDAO sadao= new SubmittedStrainAvailablityDAO();
    GeneDAO geneDAO= new GeneDAO();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String error= new String();

        if(request.getParameter("new")!=null){
            if(request.getParameter("new").equals("true")){
                return new ModelAndView("/WEB-INF/jsp/models/strainSubmissionForm1.jsp");
            }
        }
        String action=request.getParameter("action");
        String fileLocation=request.getParameter("fileLocation");
          if(action!=null){
            if("submit".equals(action)){
                    //need to verify recaptcha response
           //     try{
                String capcha = request.getParameter("g-recaptcha-response");
                    boolean recaptchaSuccess=VerifyRecaptcha.verify(capcha);
                  
                    if (!recaptchaSuccess) {
                        throw new Exception("Validation Failed.  Please try again.");
                    }

                SubmittedStrain s= new SubmittedStrain();
                List<SubmittedStrainAvailabiltiy> availList= new ArrayList<>();
                String symbolName= request.getParameter("symbol");
                String type=request.getParameter("strainTypeName");
                String geneticStatus = request.getParameter("status");
                String bgStrain = request.getParameter("backgroundstrain");
                String strainOrigin=request.getParameter("origin");
                String refeId=request.getParameter("reference");
                String resUse=request.getParameter("researchUse");
                String ilarCode = request.getParameter("ilarcode");
                String geneRgdId = request.getParameter("geneRgdid");
                String alleleRgdId = request.getParameter("alleleRgdid");
                String[] availTypes= request.getParameterValues("availType");
                String contactEmail= request.getParameter("availablecontactemail");
                String contactUrl= request.getParameter("availablecontacturl");
                String gene=request.getParameter("rs_term");
                String allele=request.getParameter("allele");
                String submitterEmail= request.getParameter("email");
                String lastName=request.getParameter("lastname");
                String firstName=request.getParameter("firstname");
                String piName=request.getParameter("pi");
                String org=request.getParameter("org");
                String source=request.getParameter("source");
                String status=request.getParameter("public");

               List<Gene> genes=geneDAO.getAllGenesBySymbol(gene, 3);
                s.setStrainSymbol(symbolName);
                s.setStrainSymbolLc((symbolName.toLowerCase()));
                s.setStrainType(request.getParameter("strainTypeName"));
                s.setGeneticStatus(request.getParameter("status"));
                s.setBackgroundStrain(request.getParameter("backgroundstrain"));

                String method= new String();
                if(request.getParameter("method")!=null && !request.getParameter("method").equals("") ){
                 method=request.getParameter("method");
                if(method.equalsIgnoreCase("other")){
                    method= request.getParameter("methodOther");
                }}
                s.setMethod(method);
                s.setOrigin(request.getParameter("origin"));
                s.setSource(request.getParameter("source"));
                s.setReference(request.getParameter("reference"));
                s.setResearchUse(request.getParameter("researchUse"));
                s.setNotes(request.getParameter("notes"));
                s.setGeneSymbol(request.getParameter("rs_term"));
                s.setAlleleSymbol(request.getParameter("allele"));
                s.setLastName(request.getParameter("lastname"));
                s.setFirstName(request.getParameter("firstname"));
                s.setEmail(request.getParameter("email"));
                s.setPiName(request.getParameter("pi"));
                s.setPiEmail(request.getParameter("piemail"));
                s.setOrganization(request.getParameter("org"));
                s.setDisplayStatus(request.getParameter("public"));
                s.setApprovalStatus("submitted");
                //  s.setModifiedBy("Jyothi");
                s.setIlarCode(request.getParameter("ilarcode"));
                s.setAvailabilityContactEmail(request.getParameter("availablecontactemail"));
                s.setAvailabilityContactUrl(request.getParameter("availablecontacturl"));
                s.setImageUrl(fileLocation);


                if(request.getParameter("geneRgdid")!=null && !request.getParameter("geneRgdid").equals(""))
                {   s.setGeneRgdId(Integer.parseInt(request.getParameter("geneRgdid")));}else{
                    s.setGeneRgdId(this.getGeneOrAlleleRgdId(gene));
                }
                if(request.getParameter("alleleRgdid")!=null && !request.getParameter("alleleRgdid").equals(""))
                {   s.setAlleleRgdId(Integer.parseInt(request.getParameter("alleleRgdid")));}else{
                    s.setAlleleRgdId(this.getGeneOrAlleleRgdId(allele));
                }

                if(availTypes!=null){
                    for(int i=0; i<availTypes.length; i++){
                        SubmittedStrainAvailabiltiy sa= new SubmittedStrainAvailabiltiy();
                        sa.setAvailabilityType(availTypes[i]);
                        availList.add(sa);
                    }}

                s.setAvailList(availList);
                String msg=new String();
                SubmittedStrain submittedStrain= new SubmittedStrain();
                List<SubmittedStrain> submittedStrains= new ArrayList<>();
                    try {
                        submittedStrains = dao.getSubmittedStrainByStrainSymbolLC(symbolName.toLowerCase());
                    }catch (Exception e){
                        System.out.println("SUBMITTED STRAINS DB CONNECTION ERROR WHILE GETTING STRAIN INFO FROM REED");
                        throw new Exception("SUBMITTED STRAINS DB CONNECTION ERROR WHILE GETTING STRAIN INFO FROM REED\n"+e);
                    }
                if(submittedStrains.size()>0){
                    submittedStrain=submittedStrains.get(0);

                    if(symbolName.toLowerCase().equals(submittedStrain.getStrainSymbol().toLowerCase())){
                        msg= "The Strain Symbol you tried to submit is already in the RGD. So please enter a different symbol.";
                        response.getWriter().write(msg);
                        return null;

                    }}
                int insertedCount=0;
                    try {
                        insertedCount = this.insert(s);
                    }catch (Exception e){
                        throw new Exception("SUBNITTED STRAIN INSERTION TO REED ERROR\n"+e);
                    }
                if(insertedCount>0)  {
                    if(genes!=null) {
                        if(genes.size()==0) {
                           msg="<span style=\"color:red\">Gene Symbol  \"" + gene + "\" is not found in RGD.</span><br><span style='color:grey'> Successfully submitted your Strain to RGD.</span><br> <span style=color:grey>You will be sent an email confirmation of your submission with SUBMISSION KEY as reference.</span>";

                        }else{
                            msg= "<span style='color:grey'>Successfully submitted your Strain to RGD.</span><br><span style='color:grey'> You will be sent an email confirmation of your submission with SUBMISSION KEY as reference.</span>";

                        }
                    }
                    String link="http://pipelines.rgd.mcw.edu/rgdweb/curation/edit/submittedStrains/editStrains.html";
                    String userMsg="Dear " + firstName.toUpperCase() + " "+ lastName.toUpperCase() + ", \n\nThank you for submitting your strain. You can use Submission Key as reference for further discussion.\n\nYour Submission Key: " + insertedCount +"\n\nSubmitted Strain Information" +
                            "\nStrain Symbol: "+symbolName+"\nType: "+type+"\nGenetic Status: "+geneticStatus+"\nMethod: "+method
                            +"\nBackground Strain: "+bgStrain+"\nDescription of strain's origin: "+strainOrigin
                            +"\nReference/Pubmed ID: "+refeId+"\nResearch Use: "+resUse+"\nILAR Code: "+ilarCode+"\n\nGene/Allele Information"
                            +"\nGene Symbol: "+gene+"\nGene RGD ID: "+geneRgdId+"\nAllele Symbol: "+allele+"\nAllele RGD ID: "+alleleRgdId+"\n\nAvailability";
                    if (availTypes != null) {
                        userMsg += "\nCurrent Status:";
                        for (String availType : availTypes) {
                            userMsg += "\n - " + availType;
                        }
                    }
                    userMsg+="\nAvailability Contact Email: "+contactEmail+"\nAvailability Contact URL: "+contactUrl;
                    userMsg+= "\n\nSubmitter Information"
                            +"\nSubmitter Name:  "+ firstName + " "+ lastName+"\nSubmitter Email Address:  " + submitterEmail + "\nOrganization:  " + org+"\nPI Name:  "+piName+"\nSource:  "+source+"\nStatus:  "+status
                            +"\n\nRegards,\nRGD Team.\n";

                   String curatorMsg="Dear RGD Curators, \n\nA new strain registration information has been generated." +"\n\nSubmitted Strain Information" +
                           "\nStrain Symbol: "+symbolName+"\nType: "+type+"\nGenetic Status: "+geneticStatus+"\nMethod: "+method
                           +"\nBackground Strain: "+bgStrain+"\nDescription of strain's origin: "+strainOrigin
                           +"\nReference/Pubmed ID: "+refeId+"\nResearch Use: "+resUse+"\nILAR Code: "+ilarCode+"\n\nGene/Allele Information"
                           +"\nGene Symbol: "+gene+"\nGene RGD ID: "+geneRgdId+"\nAllele Symbol: "+allele+"\nAllele RGD ID: "+alleleRgdId+"\n\nAvailability";
                    if (availTypes != null) {
                        curatorMsg += "\nCurrent Status:";
                        for (String availType : availTypes) {
                            curatorMsg += "\n - " + availType;
                        }
                    }
                    curatorMsg+="\nAvailability Contact Email: "+contactEmail+"\nAvailability Contact URL: "+contactUrl;
                    curatorMsg+="\n\nSubmitter Information"+"\nSubmitter Name:  "+ firstName + " "+ lastName+"\nSubmitter Email Address:  " + submitterEmail + "\nOrganization:  " + org+"\nPI Name:  "+piName+"\nSource:  "+source+"\nStatus:  "+status+"\nSubmission Key:  "+insertedCount +"\nLink to Submitted Strains Interface: " +link;
                    MyRGDLookupController.send(submitterEmail, "Strain Submission", userMsg);
//                    MyRGDLookupController.send("rgd.data@mcw.edu", "New Strain Submission", curatorMsg);
                    MyRGDLookupController.send("akundurthi@mcw.edu", "New Strain Submission", curatorMsg);
//                    MyRGDLookupController.send("jthota@mcw.edu", "New Strain Submission", curatorMsg);
                    response.getWriter().write(msg);
                    return null;
                }
                  msg="Strain Submission is failed";
                    response.getWriter().write(msg);
                    return null;
             /*   }catch (Exception e){
                    error=e.getMessage();
                    response.getWriter().write(error);
                 //   return null;

                }*/
            }

        }
       return null;
    }
    public int insert(SubmittedStrain s) throws Exception {
        int key= dao.getNextKey("submitted_strain_seq");
        System.out.println("SUBMITTED STRAIN SEQUENCY KEY: " + key);
        List<SubmittedStrainAvailabiltiy> saList= s.getAvailList();
        s.setSubmittedStrainKey(key);
        int inserted=dao.insert(s);
        for(SubmittedStrainAvailabiltiy sa: saList){
            sa.setSubmittedStrainKey(key);
            sadao.insert(sa);
        }
        if(inserted>0){
            return key;
        }else
            return 0;
    }

    public int getGeneOrAlleleRgdId(String symbol) throws Exception {
        List<Gene> geneOrAlleleList=geneDAO.getAllGenesBySymbol(symbol, 3);
        int rgdId=0;
        if(geneOrAlleleList!=null){
            if(geneOrAlleleList.size()>0) {
                rgdId = geneOrAlleleList.get(0).getRgdId();
            }else {
                List<Gene> aliasList=geneDAO.getGenesByAlias(symbol,3);
                if(aliasList!=null){
                    if(aliasList.size()>0){
                        rgdId= aliasList.get(0).getRgdId();
                    }
                }
            }

        }
        return rgdId;
    }
}

