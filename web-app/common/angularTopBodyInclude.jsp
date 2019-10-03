

<div ng-controller="RGDPageController as rgd" id="RGDPageController">


<div class="container-fluid">
    <!-- Modal -->
    <div class="modal fade" id="my-modal" role="dialog">
        <div class="modal-dialog modal-lg">
           <div class="modal-content" id="rgd-modal" >

                <!-- twitter boot strap model -->
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <table align="center">
                        <tr>
                            <td style="padding:20px;"><img src="/rgdweb/common/images/rgd_LOGO_blue_rgd.gif" border="0"/></td>
                        </tr>
                    </table>

                </div>
                <div class="modal-body">

                    <div style="padding-bottom:20px;">
                    <div style="float:left; margin-right:10px; min-width: 600px;">Welcome <span style="font-weight:700; font-size:16px;">{{ username}}</span></div>
                    <input  value="Update Account" type="button"  style="margin-right:10px;border:0px solid black; background-color:#4584ED; color:white; font-weight:700;padding:8px;" onClick="location.href='/rgdweb/my/account.html'"/>
                    <input  value="Sign Out" type="button"  ng-click="rgd.logout()"  data-dismiss="modal" style="margin-right:10px;border:0px solid black; background-color:#4584ED; color:white; font-weight:700;padding:8px;"/>
                    </div>

                    <div style="text-decoration:underline;font-weight:700; background-color:#e0e2e1;min-width:690px;">Message Center</div>
                    <div style="display:table-row;">
                    <div style="display: table-cell; float:left; margin-right:10px; min-width: 600px;font-size:13px;padding-bottom: 10px;">{{ messageCount }} Messages</div>
                    <div style="display: table-cell; float:left; margin-right:10px;min-width: 90px"><a href="/rgdweb/my/account.html">Go to Message Center</a></div>
                    </div>

                    <div style="text-decoration:underline;font-weight:700; background-color:#e0e2e1;">Watched Genes</div>
                    <div ng-repeat="watchedObject in watchedObjects" style="display:table-row;">

                        <div style="display: table-cell; float:left; margin-right:10px; min-width: 600px;">{{$index + 1}}. <span style="font-weight:700;">{{ watchedObject.symbol }} (RGD ID:{{watchedObject.rgdId}})</span></div>
                        <div style="display: table-cell; float:left;  margin-right:10px; min-width: 40px;"><a href="javascript:return false;" ng-click="rgd.addWatch(watchedObject.rgdId)">Update Watcher</a></div>
                        <div style="display: table-cell; float:left;  margin-right:10px; min-width: 50px;" ><a href="javascript:return false;" ng-click="rgd.removeWatch(watchedObject.rgdId)">Remove Watcher</a></div>
                    </div>
                    <div style="margin-top:20px;text-decoration:underline;font-weight:700;background-color:#e0e2e1;">Watched Ontology Terms</div>
                    <div ng-repeat="watchedTerm in watchedTerms" style="display:table-row;">

                        <div style="display: table-cell; float:left; margin-right:10px; min-width: 600px;">{{$index + 1}}. <span style="font-weight:700;">{{ watchedTerm.term }} ({{watchedTerm.accId}})</span></div>
                        <div style="display: table-cell; float:left;  margin-right:10px; min-width: 40px;"><a href="javascript:return false;" ng-click="rgd.addWatch(watchedTerm.accId)">Update Watcher</a></div>
                        <div style="display: table-cell; float:left;  margin-right:10px; min-width: 50px;" ><a href="javascript:return false;" ng-click="rgd.removeWatch(watchedTerm.accId)">Remove Watcher</a></div>
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
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <table align="center">
            <tr>
                <td style="padding:20px;"><img src="/rgdweb/common/images/rgd_LOGO_blue_rgd.gif" border="0"/></td>
            </tr>
        </table>

    </div>
    <div class="modal-body">

        <table align="center" style="padding-bottom:20px;">
            <tr>
                <td align="center" style="font-size:30px;color:#55556D;">Save what matters to you</td>
            </tr>
            <tr>
                <td style="color:red;font-weight:700; font-size:18px;">{{ loginError }}</td>
            </tr>
        </table>



        <table align="center">
            <tr>
                <td style="font-size:20px;">Sign in with your RGD account</td>
            </tr>
        </table>


        <form>
            <table align="center" border=0 style="border:2px outset lightgrey;background-color:#F7F7F7;padding:40px;">
                <tr>
                    <td>Email Address:</td>
                    <td><input type='text' size='30' id="j_username" name='j_username' value="" value=''</td></tr>
                <tr><td>Password:</td><td><input  size='30' type='password' id="j_password" name='j_password' value=""></td></tr>

                <tr>
                    <td align="center" colspan="2">
                        <table cellpadding="5">
                            <tr>
                                <td><input name="submit"  data-dismiss="modal" type="button" value="Cancel" style="font-size:16px; margin-top:20px;"></td>
                                <td><input name="submit" type="submit" value="Log In" style="font-size:16px; margin-top:20px;" ng-click="rgd.login()"  nClick="doLogin()" ></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                </tr>
            </table>

        </form>


        <table align="center" border="0">
            <tr>
                <td>
                    <a href="/rgdweb/my/account.html?submit=Create" style="font-size:16px; margin-right:10px;">Create New Account</a>
                </td>
                <td>
                    <a href="/rgdweb/my/lookup.html" style="font-size:16px;">Recover Password</a>
                </td>
            </tr>
        </table>


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
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">{{ watchLinkText }}</h4>
                </div>
                <div class="modal-body">

                    <div style="padding-bottom:10px;">Select categories you would like to watch.  Updates to this gene will be send to {{ username }}</div>

                     <label ng-repeat="geneWatchAttr in geneWatchAttributes">
                        <input
                                type="checkbox"
                                name="geneWatchSelection[]"
                                value="{{geneWatchAttr}}"
                                ng-checked="geneWatchSelection.indexOf(geneWatchAttr) > -1"
                                ng-click="toggleGeneWatchSelection(geneWatchAttr)"
                        > {{geneWatchAttr}}
                        <br>
                    </label>


                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>

                    <span ng-if="watchLinkText == 'Update Watcher'">
                        <button type="button" ng-click="rgd.removeWatch(activeObject)" class="btn btn-default" data-dismiss="modal">Stop Watching</button>
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
                                    <td align="center"><div ng-if="oKey==1"><img src="/rgdweb/common/images/functionalAnnotation.png" border="0"  style="cursor:pointer;padding:5px; margin-right:0px;margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('ga')"/></div><div ng-if="oKey!=1">Functional Annotation<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/common/images/gaTool.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('distribution')"/></div><div ng-if="oKey!=1">Annotation Distribution<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3" ><img src="/rgdweb/common/images/variantVisualizer.png" border="0"  style="cursor:pointer;padding:5px; margin-right:0px;margin-bottom:5px; border:1px solid black;"  ng-click="rgd.toolSubmit('vv')"/></div><div ng-if="speciesTypeKey!=1 && speciesTypeKey!=3">Genomic Variants<br> unavailble for Mouse</div></div><div ng-if="oKey!=1">Genomic Variants<br>unavailable</div></td>
                                </tr>
                                <tr>
                                    <td align="center"  style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('ga')"><div ng-if="oKey==1">Functional Annotation</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('distribution')"><div ng-if="oKey==1">Annotation Distribution</div></td>

                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('vv')"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3" ><div ng-if="oKey==1">Genomic Variants</div></div></td>

                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                    <td align="center"><div ng-if="oKey==1"><img src="/rgdweb/common/images/interviewer.png" border="0" style="cursor:pointer;padding:5px; margin-right:0px; border:1px solid black;" ng-click="rgd.toolSubmit('interviewer')"/></div><div ng-if="oKey!=1">Protein-Protein Interactions<br>unavailable</div></td>
                                    <td align="center"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3 || speciesTypeKey==2" ><div ng-if="oKey==1"> <img src="/rgdweb/common/images/gviewer.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('gviewer')"/></div></div><div ng-if="oKey!=1 || speciesTypeKey > 3">Genome Viewer<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3" > <img src="/rgdweb/common/images/damaging.png" border="0" style="cursor:pointer;padding:5px; margin-right:0px; border:1px solid black;" ng-click="rgd.toolSubmit('damage')"/></div><div ng-if="speciesTypeKey!=1 && speciesTypeKey!=3">Damaging Variants unavailble for Mouse</div></div><div ng-if="oKey!=1">Damaging Variants<br>unavailable</div></td>
                                </tr>
                                <tr>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('interviewer')"><div ng-if="oKey==1">Protein-Protein Interactions</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('gviewer')"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3 || speciesTypeKey==2" ><div ng-if="oKey==1">Genome Viewer</div></div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('excel')"><div ng-if="speciesTypeKey==1 || speciesTypeKey==3" ><div ng-if="oKey==1">Damaging Variants</div></div></td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                    <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/common/images/annotCompare.png" border="0" style="cursor:pointer;padding:5px; margin-right:0px; border:1px solid black;" ng-click="rgd.toolSubmit('annotCompare')"/></div><div ng-if="oKey!=1">Annotation Comparison<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/common/images/olga.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('olga')"/></div><div ng-if="oKey!=1">OLGA<br>unavailable</div></td>
                                    <td align="center"> <img src="/rgdweb/common/images/excel.png" border="0" style="cursor:pointer;padding:5px; margin-right:0px; border:1px solid black;" ng-click="rgd.toolSubmit('excel')"/></td>
                                </tr>
                                <tr>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('annotCompare')"><div ng-if="oKey==1">Annotation Comparison</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('olga')"><div ng-if="oKey==1">OLGA</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('excel')">Excel (Download)</td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                   <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/images/MOET.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('enrichment')"/></div><div ng-if="oKey!=1">Gene Enrichment<br>unavailable</div></td>
                                    <td align="center"><div ng-if="oKey==1"> <img src="/rgdweb/images/GOLF.png" border="0" style="cursor:pointer;padding:5px; margin-bottom:5px; border:1px solid black;" ng-click="rgd.toolSubmit('golf')"/></div><div ng-if="oKey!=1">Ortholog Finder<br>unavailable</div></td>
                                </tr>
                                <tr>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('enrichment')"><div ng-if="oKey==1">Gene Enrichment</div></td>
                                    <td align="center" style="cursor:pointer;font-size:16px;font-weight:400;" ng-click="rgd.toolSubmit('golf')"><div ng-if="oKey==1">Ortholog Finder</div></td>

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