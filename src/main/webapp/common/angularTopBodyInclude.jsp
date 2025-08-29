

<div ng-controller="RGDPageController as rgd" id="RGDPageController">


<div class="container-fluid">
    <!-- Modal -->
    <div class="modal fade" id="my-modal" role="dialog">
        <div class="modal-dialog modal-lg">
           <div class="modal-content" id="rgd-modal" >

                <!-- twitter boot strap model -->
                <div class="modal-header">
                    <table align="center">
                        <tr>
                            <td style="padding:20px;"><img src="/rgdweb/common/images/rgd_LOGO_blue_rgd.gif" border="0"/></td>
                        </tr>
                    </table>

                </div>
                <div class="modal-body">

                    <div style="padding-bottom:20px;">
                    <div style="float:left; margin-right:10px; min-width: 600px;">Welcome <span style="font-weight:700; font-size:16px;">{{ username}}</span></div>
                    </div>
                    <input  type="button" class="btn btn-info btn-sm"  value="Log out" ng-click="rgd.logout($event)" style="background-color:#2B84C8;padding:1px 10px;font-size:12px;line-height:1.5;border-radius:3px"/>

                    <br><br>

                    <div style="text-decoration:underline;font-weight:700; background-color:#e0e2e1;min-width:690px;">Message Center</div>
                    <div style="display:table-row;">
                    <div style="display: table-cell; float:left; margin-right:10px; min-width: 600px;font-size:13px;padding-bottom: 10px;">{{ messageCount }} Messages</div>
                    <div style="display: table-cell; float:left; margin-right:10px;min-width: 90px"><a href="/rgdweb/my/account.html">Go to Message Center</a></div>
                    </div>

                    <div style="text-decoration:underline;font-weight:700; background-color:#e0e2e1;">Watched Genes</div>
                    <div ng-repeat="watchedObject in watchedObjects" style="display:table-row;">

                        <div style="display: table-cell; float:left; margin-right:10px; min-width: 600px;">{{$index + 1}}. <span style="font-weight:700;">{{ watchedObject.symbol }} (RGD ID:{{watchedObject.rgdId}})</span></div>
                        <div style="display: table-cell; float:left;  margin-right:10px; min-width: 40px;"><a href="javascript:return false;" ng-click="rgd.addWatch(watchedObject.rgdId)">Modify Subscription</a></div>
                        <div style="display: table-cell; float:left;  margin-right:10px; min-width: 50px;" ><a href="javascript:return false;" ng-click="rgd.removeWatch(watchedObject.rgdId)">Unsubscribe</a></div>
                    </div>
                    <div style="margin-top:20px;text-decoration:underline;font-weight:700;background-color:#e0e2e1;">Watched Ontology Terms</div>
                    <div ng-repeat="watchedTerm in watchedTerms" style="display:table-row;">

                        <div style="display: table-cell; float:left; margin-right:10px; min-width: 600px;">{{$index + 1}}. <span style="font-weight:700;">{{ watchedTerm.term }} ({{watchedTerm.accId}})</span></div>
                        <div style="display: table-cell; float:left;  margin-right:10px; min-width: 40px;"><a href="javascript:return false;" ng-click="rgd.addWatch(watchedTerm.accId)">Modify Subscription</a></div>
                        <div style="display: table-cell; float:left;  margin-right:10px; min-width: 50px;" ><a href="javascript:return false;" ng-click="rgd.removeWatch(watchedTerm.accId)">Unsubscribe</a></div>
                    </div>


                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close Window</button>
                </div>


               <%-- <span style="font-weight:700;">{{ geneList.length }}</span>--%>

                <div ng-repeat="gene in geneList" style="padding-left:10px;">
                    <span style="font-weight:700; ">{{gene.symbol}}:</span> {{ gene.description }}
                </div>
            </div>
        </div>
    </div>
</div>


    <!-- twitter bootstrap modal Save List to RGD-->

    <div class="container-fluid" >

        <!-- Modal -->
        <div class="modal fade" id="name-desc-modal" role="dialog">
            <div class="modal-dialog modal-small">
                <div class="modal-content" >
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Save List to My RGD</h4>
                    </div>
                    <div class="modal-body">
                        <table align="center">
                            <tr>
                                <td>Create Name:&nbsp;&nbsp;</td>
                                <td><input id="myRgdListName" size="40" type="text" value="{{listName}}" ng-model="listName"/></td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>Description:&nbsp;&nbsp;</td>
                                <td><input id="myRgdListDesc" size="40" type="text" value="{{listDescription}}" ng-model="listDescription"/></td>
                            </tr>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" ng-click="rgd.saveList($event)" class="btn btn-default" data-dismiss="modal">Save List</button>
                    </div>
                </div>
            </div>
        </div>
    </div>



<!--  Login box -------------->
    <div class="ontainer-fluid" >

        <!-- Modal -->
        <div class="modal fade" id="login-modal" role="dialog">
            <div class="modal-dialog modal-small">
                <div class="modal-content" >
    <div class="modal-header">
        <table align="center">
            <tr>
                <td style="padding:20px;"><img src="/rgdweb/common/images/rgd_LOGO_blue_rgd.gif" border="0"/></td>
            </tr>
        </table>

    </div>
    <div class="modal-body">

        <table align="center" style="padding-bottom:20px;">
            <tr>
                <td align="center" style="font-size:30px;color:#55556D;">You must be logged in to use this feature</td>
            </tr>
            <tr>
                <td style="color:red;font-weight:700; font-size:18px;">{{ loginError }}</td>
            </tr>
        </table>

<!--
        <div style="display:none;" id="g_id_onload"
             data-client_id="833037398765-po85dgcbuttu1b1lco2tivl6eaid3471.apps.googleusercontent.com"
             data-login_uri="http://localhost:8080/rgdweb/my/account.html?page=<%=request.getRequestURI()%>"
             data-auto_prompt="false"
             data-auto_select="true"
        >
        </div>
-->
        <br><br><br>
        <table align="center">
            <tr>
                <td>
                    <div class="g_id_signin"
                         data-type="standard"
                         data-shape="rectangular"
                         data-theme="outline"
                         data-text="signin"
                         data-size="large"
                         data-logo_alignment="left">
                    </div>

                </td>
            </tr>
        </table>
        <br><br><br>



        </div>
      </div>
    </div>
</div>

<!-- watch object select window-->

<div class="container-fluid" >

    <!-- Modal -->
    <div class="modal fade" id="watch-modal" role="dialog">
        <div class="modal-dialog modal-small">
            <div class="modal-content" >
                <div class="modal-header">
 <!--                   <button type="button" class="close" data-dismiss="modal">&times;</button>-->
                    <h4 class="modal-title">{{ watchLinkText }}</h4>
                </div>
                <div class="modal-body">

                    <div style="padding-bottom:10px;">Select categories you would like to watch.  Updates to this gene will be sent to {{ username }}</div>



                         <table>
                        <tr ng-repeat="geneWatchAttr in geneWatchAttributes">
                            <td><input
                                    type="checkbox"
                                    name="geneWatchSelection[]"
                                    value="{{geneWatchAttr}}"
                                    ng-checked="geneWatchSelection.indexOf(geneWatchAttr) > -1"
                                    ng-click="toggleGeneWatchSelection(geneWatchAttr)"
                            > </td>
                            <td>{{geneWatchAttr}}</td>
                        </tr>
                         </table>




                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>

                    <span ng-if="watchLinkText == 'Modify Subscription'">
                        <button type="button" ng-click="rgd.removeWatch(activeObject)" class="btn btn-default" data-dismiss="modal">Unsubscribe from this Object</button>
                    </span>
                    <button type="button" ng-click="rgd.saveWatch(activeObject)" class="btn btn-default" data-dismiss="modal">Save</button>
                </div>
            </div>
        </div>
    </div>
</div>


<!--  tool navigation -->
        <!-- twitter bootstrap modal Save List to RGD-->

        <div class="container-fluid" >

            <!-- Modal -->
            <div class="modal fade" id="tools-modal" role="dialog">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content" >
                        <div class="modal-header">
                            <table width="100%">
                                <tr>
                                    <td>&nbsp;&nbsp;&nbsp;</td>
                                    <td><h4 style="font-size:16px;" class="modal-title">Analyze <span ng-if="oKey==1">Gene</span><span ng-if="oKey==5">Strain</span><span ng-if="oKey==6">QTL</span>  List</h4></td>
                                    <td align="right"><button type="button" class="close" data-dismiss="modal">&times;</button></td>
                                    <td>&nbsp;&nbsp;&nbsp;</td>
                                </tr>
                            </table>



                        </div>
                        <div class="modal-body">

                            <table width="90%" align="center" border="0">
                                <tr>
                                    <td align="center"><div ng-if="oKey==1"><img src="/rgdweb/common/images/functionalAnnotation.png" border="0"  style="cursor:pointer;padding:5px; margin-right:0px;margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('ga')"/></div><div ng-if="oKey!=1">Gene Annotator (Functional Annotation)<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/common/images/annotDist.PNG" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('distribution')"/></div><div ng-if="oKey!=1">Gene Annotator (Annotation Distribution)<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"><div ng-if="speciesTypeKey==1 || speciesTypeKey==2 || speciesTypeKey==3 || speciesTypeKey==6 || speciesTypeKey==9 || speciesTypeKey==13" ><img src="/rgdweb/common/images/variantVisualizer.png" border="0"  style="cursor:pointer;padding:5px; margin-right:0px;margin-bottom:5px; border:1px solid black;"  ng-click="rgd.toolSubmit('vv')"/></div><div ng-if="speciesTypeKey!=1 && speciesTypeKey!=2 && speciesTypeKey!=3 && speciesTypeKey!=6 && speciesTypeKey!=9 && speciesTypeKey!=13">Variant Visualizer (Genomic Variants)<br> unavailble</div></div><div ng-if="oKey!=1">Variant Visualizer (Genomic Variants)<br>unavailable</div></td>
                                </tr>
                                <tr>
                                    <td align="center"  style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('ga')"><div ng-if="oKey==1">Gene Annotator (Functional Annotation)</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('distribution')"><div ng-if="oKey==1">Gene Annotator (Annotation Distribution)</div></td>

                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('vv')"><div ng-if="speciesTypeKey==1 || speciesTypeKey==2 || speciesTypeKey==3 || speciesTypeKey==6 || speciesTypeKey==9 || speciesTypeKey==13" ><div ng-if="oKey==1">Variant Visualizer (Genomic Variants)</div></div></td>

                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                    <td align="center"><div ng-if="oKey==1"><img src="/rgdweb/common/images/interviewer.png" border="0" style="cursor:pointer;padding:5px; margin-right:0px; border:1px solid black;" ng-click="rgd.toolSubmit('interviewer')"/></div><div ng-if="oKey!=1">InterViewer (Protein-Protein Interactions)<br>unavailable</div></td>
                                    <td align="center"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3 || speciesTypeKey==2 || speciesTypeKey==5 || speciesTypeKey==6 || speciesTypeKey==9" ><div ng-if="oKey==1"> <img src="/rgdweb/common/images/gviewer.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('gviewer')"/></div></div><div ng-if="oKey!=1 || speciesTypeKey == 4 || speciesTypeKey==7 || speciesTypeKey==8">Gviewer (Genome Viewer)<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3 || speciesTypeKey==6" > <img src="/rgdweb/common/images/damaging.png" border="0" style="cursor:pointer;padding:5px; margin-right:0px; border:1px solid black;" ng-click="rgd.toolSubmit('damage')"/></div><div ng-if="speciesTypeKey!=1 && speciesTypeKey!=3 && speciesTypeKey!=6">Variant Visualizer (Damaging Variants) unavailble</div></div><div ng-if="oKey!=1">Variant Visualizer (Damaging Variants)<br>unavailable</div></td>
                                </tr>
                                <tr>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('interviewer')"><div ng-if="oKey==1">InterViewer (Protein-Protein Interactions)</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('gviewer')"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3 || speciesTypeKey==2 || speciesTypeKey==5 || speciesTypeKey==6 || speciesTypeKey==9" ><div ng-if="oKey==1">GViewer (Genome Viewer)</div></div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('excel')"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3 || speciesTypeKey==6" ><div ng-if="oKey==1">Variant Visualizer (Damaging Variants)</div></div></td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                    <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/common/images/annotCompare.png" border="0" style="cursor:pointer;padding:5px; margin-right:0px; border:1px solid black;" ng-click="rgd.toolSubmit('annotCompare')"/></div><div ng-if="oKey!=1">Gene Annotator (Annotation Comparison)<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/common/images/olga.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('olga')"/></div><div ng-if="oKey!=1">OLGA (Gene List Generator)<br>unavailable</div></td>
                                    <td align="center"> <img src="/rgdweb/common/images/excel.png" border="0" style="cursor:pointer;padding:5px; margin-right:0px; border:1px solid black;" ng-click="rgd.toolSubmit('excel')"/></td>
                                </tr>
                                <tr>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('annotCompare')"><div ng-if="oKey==1">Gene Annotator (Annotation Comparison)</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('olga')"><div ng-if="oKey==1">OLGA (Gene List Generator)</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('excel')">Excel (Download)</td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                   <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/images/MOET.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('enrichment')"/></div><div ng-if="oKey!=1">MOET (Multi-Ontology Enrichement)<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/images/GOLF.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('golf')"/></div><div ng-if="oKey!=1">GOLF (Gene-Ortholog Location Finder)<br>unavailable</div></td>
                                </tr>
                                <tr>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('enrichment')"><div ng-if="oKey==1">MOET (Multi-Ontology Enrichement)</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('golf')"><div ng-if="oKey==1">GOLF (Gene-Ortholog Location Finder)</div></td>

                                </tr>
                            </table>

                        </div>
                        <br>
                    </div>
                </div>
            </div>
        </div>


        <!-- end tool navigation -->









        <!--
                            <div style="font-weight:700;text-decoration: underline;">Saved Lists</div>

                                            <div ng-repeat="list in myLists" style="display:table-row;">

                                             <div style="display: table-cell; float:left; margin-right:10px; min-width: 50px; font-weight:700;">{{ list.name }}:</div> <div style="width:100%;"> {{ list.desc }}</div>
                                             <div style="display: table-cell; float:left; margin-right:10px; min-width: 50px;"><a href="javascript:void(0)" ng-click="rgd.loadGeneList(list.id)">Preview</a></div>
                                             <div style="display: table-cell; float:left;  margin-right:10px; min-width: 40px;"><a href="{{ list.link }}&lid={{list.id}}">Edit</a></div>
                                             <div style="display: table-cell; float:left;  margin-right:10px; min-width: 50px;" ><a href="javascript:void(0)" ng-click="rgd.removeList(list.id)">Remove</a></div>
                                             <div style="display: table-cell; float:left;  margin-right:10px; min-width: 50px; padding-bottom:10px;" ><input type="button" value="Import" ng-click="rgd.import(list.id)" data-dismiss="modal"/></div>



                                            </div>
                            </div>
                            -->