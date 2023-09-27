<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>

<%@ include file="sectionHeader.jsp"%>
<%
    AnnotationFormatter af = new AnnotationFormatter();
    final List<Annotation> annots = annotationDAO.getAnnotationsByReferenceForProject(obj.getRgdId());
    final Set<Integer> annotRgdIds = new HashSet<Integer>(annots.size());

    List<Annotation> objTypeListGenesRat = new ArrayList<Annotation>();
    List<Annotation> objTypeListGenesMouse = new ArrayList<Annotation>();
    List<Annotation> objTypeListGenesHuman = new ArrayList<Annotation>();
    List<Annotation> objTypeListGenesChinchilla = new ArrayList<Annotation>();
    List<Annotation> objTypeListGenesPig = new ArrayList<>();
    List<Annotation> objTypeListGenesDog = new ArrayList<>();
    List<Annotation> objTypeListGenesVervet = new ArrayList<>();
    List<Annotation> objTypeListQtls = new ArrayList<Annotation>();
    List<Annotation> objTypeListStrains = new ArrayList<Annotation>();
    List<Annotation> objTypeListSslps = new ArrayList<Annotation>();

    if (annots.size() > 0 ) {
        Collections.sort(annots, new Comparator<Annotation>() {
            public int compare(Annotation o1, Annotation o2) {
                int result = (o1.getRgdObjectKey().compareTo(o2.getRgdObjectKey()));
                if( result!=0 )
                    return result;

                int result1 = Utils.stringsCompareToIgnoreCase(o1.getObjectSymbol(), o2.getObjectSymbol());
                if(result1!=0)
                    return result1;

                int result2 = Utils.stringsCompareToIgnoreCase(o1.getObjectName(), o2.getObjectName());
                if(result2!=0)
                    return result2;

                return o1.getTerm().compareToIgnoreCase(o2.getTerm());
            }
        });
%>


<%--<%=ui.dynOpen("objAssociation", "Objects Annotated")%>--%>
<div class="light-table-border" id="objectsAnnotatedTableWrapper">
<div class="sectionHeading" id="objectsAnnotated">Objects Annotated</div>

<%
    for (Annotation annot : annots) {
        annotRgdIds.add(annot.getAnnotatedObjectRgdId());

        if (RgdContext.isChinchilla(request)) {
            if (annot.getRgdObjectKey() == RgdId.OBJECT_KEY_GENES) {
                if (annot.getSpeciesTypeKey() == SpeciesType.CHINCHILLA) {
                    if (checkAnnotInList(annot, objTypeListGenesChinchilla) == 0) {
                        objTypeListGenesChinchilla.add(annot);
                    }
                } else if (annot.getSpeciesTypeKey() == SpeciesType.HUMAN) {
                    if (checkAnnotInList(annot, objTypeListGenesHuman) == 0) {
                        objTypeListGenesHuman.add(annot);
                    }
                }
            }

        }else {
            if (annot.getRgdObjectKey() == RgdId.OBJECT_KEY_GENES) {
                if (annot.getSpeciesTypeKey() == SpeciesType.RAT) {
                    if (checkAnnotInList(annot, objTypeListGenesRat) == 0) {
                        objTypeListGenesRat.add(annot);
                    }
                } else if (annot.getSpeciesTypeKey() == SpeciesType.MOUSE) {
                    if (checkAnnotInList(annot, objTypeListGenesMouse) == 0) {
                        objTypeListGenesMouse.add(annot);
                    }
                } else if (annot.getSpeciesTypeKey() == SpeciesType.CHINCHILLA) {
                    if (checkAnnotInList(annot, objTypeListGenesChinchilla) == 0) {
                        objTypeListGenesChinchilla.add(annot);
                    }
                } else if (annot.getSpeciesTypeKey() == SpeciesType.HUMAN) {
                    if (checkAnnotInList(annot, objTypeListGenesHuman) == 0) {
                        objTypeListGenesHuman.add(annot);
                    }
                } else if (annot.getSpeciesTypeKey() == SpeciesType.PIG) {
                    if (checkAnnotInList(annot, objTypeListGenesPig) == 0) {
                        objTypeListGenesPig.add(annot);
                    }
                } else if (annot.getSpeciesTypeKey() == SpeciesType.DOG) {
                    if (checkAnnotInList(annot, objTypeListGenesDog) == 0) {
                        objTypeListGenesDog.add(annot);
                    }
                } else if (annot.getSpeciesTypeKey() == SpeciesType.VERVET) {
                    if (checkAnnotInList(annot, objTypeListGenesVervet) == 0) {
                        objTypeListGenesVervet.add(annot);
                    }
                }
            } else if (annot.getRgdObjectKey() == RgdId.OBJECT_KEY_QTLS) {
                if (checkAnnotInList(annot, objTypeListQtls) == 0) {
                    objTypeListQtls.add(annot);
                }
            } else if (annot.getRgdObjectKey() == RgdId.OBJECT_KEY_STRAINS) {
                if (checkAnnotInList(annot, objTypeListStrains) == 0) {
                    objTypeListStrains.add(annot);
                }
            } else if (annot.getRgdObjectKey() == RgdId.OBJECT_KEY_SSLPS) {
                if (checkAnnotInList(annot, objTypeListSslps) == 0) {
                    objTypeListSslps.add(annot);
                }
            }
        }
    }
%>

    <% if (objTypeListGenesRat.size() > 0) { %>
    <div id="objectsAnnotatedRatTable">
        <br><table>
            <tr>
                <td ><span class="highlight">Genes (<%=SpeciesType.getTaxonomicName(SpeciesType.RAT)%>)</span></td>
                <td><img src="/rgdweb/common/images/tools-white-30.png" style="margin-left:20px; float:right; cursor:hand; border: 1px solid black;" border="0" ng-click="rgd.showTools('geneList3',3,<%=MapManager.getInstance().getReferenceAssembly(3).getKey()%>)"/></td>
            </tr>
        </table>
    <%=af.createGridFormatAnnotatedObjects(objTypeListGenesRat, 3)%>
    </div>
    <% } %>

    <% if (objTypeListGenesMouse.size() > 0) { %>
    <div id="objectsAnnotatedMouseTable">
<br><table>
    <tr>
        <td ><span class="highlight">Genes (<%=SpeciesType.getTaxonomicName(SpeciesType.MOUSE)%>)</span></td>
        <td><img src="/rgdweb/common/images/tools-white-30.png" style="margin-left:20px; float:right; cursor:hand; border: 1px solid black;" border="0" ng-click="rgd.showTools('geneList2',2,<%=MapManager.getInstance().getReferenceAssembly(2).getKey()%>)"/></td>
    </tr>
</table>
           <%=af.createGridFormatAnnotatedObjects(objTypeListGenesMouse, 3)%>
    </div>
    <% } %>
    <% if (objTypeListGenesHuman.size() > 0) { %>
    <div id="objectsAnnotatedHumanTable">

    <br><table>
    <tr>
        <td ><span class="highlight">Genes (<%=SpeciesType.getTaxonomicName(SpeciesType.HUMAN)%>)</span></td>
        <td><img src="/rgdweb/common/images/tools-white-30.png" style="margin-left:20px; float:right; cursor:hand; border: 1px solid black;" border="0" ng-click="rgd.showTools('geneList1',1,<%=MapManager.getInstance().getReferenceAssembly(1).getKey()%>)"/></td>
    </tr>
</table>
           <%=af.createGridFormatAnnotatedObjects(objTypeListGenesHuman, 3)%>
    </div>
    <% } %>
    <% if (objTypeListGenesChinchilla.size() > 0) { %>
    <div id="objectsAnnotatedChinchillaTable">

    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Genes (<%=SpeciesType.getTaxonomicName(SpeciesType.CHINCHILLA)%>)</u></span><br></span>
        <%=af.createGridFormatAnnotatedObjects(objTypeListGenesChinchilla, 3)%>
    </div>
    <% } %>
    <% if (objTypeListGenesPig.size() > 0) { %>
    <div id="objectsAnnotatedPigTable">

        <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Genes (<%=SpeciesType.getTaxonomicName(SpeciesType.PIG)%>)</u></span><br></span>
        <%=af.createGridFormatAnnotatedObjects(objTypeListGenesPig, 3)%>
    </div>
    <% } %>
    <% if (objTypeListGenesVervet.size() > 0) { %>
    <div id="objectsAnnotatedVervetTable">

        <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Genes (<%=SpeciesType.getTaxonomicName(SpeciesType.VERVET)%>)</u></span><br></span>
        <%=af.createGridFormatAnnotatedObjects(objTypeListGenesVervet, 3)%>
    </div>
    <% } %>
    <% if (objTypeListGenesDog.size() > 0) { %>
    <div id="objectsAnnotatedDogTable">

        <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Genes (<%=SpeciesType.getTaxonomicName(SpeciesType.DOG)%>)</u></span><br></span>
        <%=af.createGridFormatAnnotatedObjects(objTypeListGenesDog, 3)%>
    </div>
    <% } %>
    <% if (objTypeListQtls.size() > 0) { %>
    <div id="objectsAnnotatedQtlTable">

    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>QTLs</u></span><br></span>
           <%=af.createGridFormatAnnotatedObjects(objTypeListQtls, 2)%>
    </div>
    <% } %>
    <% if (objTypeListSslps.size() > 0) { %>
    <div id="objectsAnnotatedSslpTable">

    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>SSLPs</u></span><br></span>
           <%=af.createGridFormatAnnotatedObjects(objTypeListSslps, 3)%>
    </div>
    <% } %>
    <% if (objTypeListStrains.size() > 0) { %>
    <div id="objectsAnnotatedStrainTable">

    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Strains</u></span><br></span>
           <%=af.createGridFormatAnnotatedObjects(objTypeListStrains, 2)%>
    </div>
    <% } %>

<br>
<%--<%=ui.dynClose("objAssociation")%>--%>
</div>
<% } %>


<%
    // objects associated with this reference
    final List<GenomicElement> refObjs = associationDAO.getElementsAssociatedWithReference(obj.getRgdId());
    // remove from this list objects that are already on annotated objects list
    Iterator<GenomicElement> it = refObjs.iterator();
    while( it.hasNext() ) {
        GenomicElement ge = it.next();
        if( annotRgdIds.contains(ge.getRgdId()) )
            it.remove();
    }
    if( !refObjs.isEmpty() ) {

        Collections.sort(refObjs, new Comparator<GenomicElement>() {
            public int compare(GenomicElement o1, GenomicElement o2) {

                int result = Utils.intsCompareTo(o1.getSpeciesTypeKey(), o2.getSpeciesTypeKey());
                if(result!=0)
                    return result;

                int result1 = Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
                if( result1!=0 )
                    return result1;

                int result2 = Utils.stringsCompareToIgnoreCase(RgdId.getObjectTypeName(o1.getObjectKey()), RgdId.getObjectTypeName(o2.getObjectKey()));
                if(result2!=0)
                    return result2;

                return edu.mcw.rgd.process.Utils.intsCompareTo(o1.getRgdId(), o2.getRgdId());
            }
        });
%>

<%--<%=ui.dynOpen("objAssociation2", "Objects referenced in this article")%>--%>
<div class="light-table-border" id="objectsReferencedInThisArticleTableWrapper">

<div class="sectionHeading" id="objectsReferencedInThisArticle">Objects referenced in this article</div>

<table id="objectsReferencedInThisArticleTable" class="tablesorter">
<thead></thead>
    <tbody>
<%
    for( GenomicElement ge: refObjs ) {
        String symbolOrName = ge.getSymbol()!=null ? ge.getSymbol() : ge.getName();
        %>
      <tr>
          <td><%=RgdId.getObjectTypeName(ge.getObjectKey())%></td>
          <td style="white-space: nowrap"><a href="<%=Link.it(ge.getRgdId(), ge.getObjectKey())%>"><%=symbolOrName%></a></td>
          <td><%=ge.getName()%></td>
          <td><%=SpeciesType.getTaxonomicName(ge.getSpeciesTypeKey())%></td>
      </tr>
<%  }  %>
    </tbody>
</table>
<%--<%=ui.dynClose("objAssociation2")%>--%>
</div>
<% } %>

<%@ include file="sectionFooter.jsp"%>

<%!
    private int checkAnnotInList(Annotation annotation, List<Annotation> objListAnnot) {

        for(Annotation a : objListAnnot){
            if(a.getAnnotatedObjectRgdId().equals(annotation.getAnnotatedObjectRgdId())){
                return 1;
            }
        }
        return 0;
    }
%>