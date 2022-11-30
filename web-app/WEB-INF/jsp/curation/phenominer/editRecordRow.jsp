

<input type="hidden" name="id<%=rid%>" value="<%=rec.getId()%>"/>

    <tr id="tr_<%=rec.getId()%>">

    <td class="headcol">
        <table>
            <tr>
                <td>
                    <input style="background-color:#24C780; margin-top:6px; height:50px; width:50px" type="button" value="Save" id="save<%=rid%>" onClick="saveRecord('<%=rec.getId()%>')"/>
                </td>
                <td>
                    <input style="background-color:#24C780; margin-top:6px; height:50px; width:50px" type="button" value="Clone" onClick="cloneRecord(this.form,'<%=rec.getId()%>')"/>
                </td>
            </tr>
        </table>
    </td>
    <td class="phenominerTableCell">
        <%=req.getParameter("studyId")%>
    </td>
    <td class="phenominerTableCell">
        <!-- experiment id -->
        <table><tr><td><input onChange="changed(this,'<%=rec.getId()%>')" type="text" id="expId<%=rid%>" size='6' name="expId<%=rid%>" value="<%=req.getParameter("expId")%>" style="background-color: #dddddd" readonly="true"/></td>
            <td><button type="button" onclick="editField('#expId'+rid)" class="butEdit"></button></td></tr></table>
    </td>
    <td class="phenominerTableCell">
        <a href="records.html?act=edit&expId=<%=req.getParameter("expId")%>&studyId=<%=req.getParameter("studyId")%>&id=<%=rec.getId()%>"><%=rec.getId()%></a>
    </td>

        <td class="phenominerTableCell">
        <!-- curation status -->
        <%=fu.buildSelectList("sStatus" + rid, dao.getEnumerableMap(6, 0, multiEdit), dm.out("sStatus"+rid, rec.getCurationStatus()),"changed(this)")%>
    </td>
    <td class="phenominerTableCell">
        <!-- Clinical Measurement -->
        <table>
            <tr>
                <td colspan="2">
                    <input  onChange="changed(this,'<%=rec.getId()%>')" type="text" id="cmAccId<%=rid%>" name="cmAccId<%=rid%>" size="40" value="<%=dm.out("cmAccId"+rid, rec.getClinicalMeasurement().getAccId())%>"/>
                </td>
            </tr>
            <tr>
                <td>
                    <a href="javascript:lookup_treeRender('cmAccId<%=rid%>', 'CMO', 'CMO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
                </td>
                <td>
                    <span id="cmTerm<%=rid%>%>" class="highlight"><%=cmTerm%></span>
                </td>
            </tr>
        </table>


    </td>
    <td class="phenominerTableCell">
        <!-- Site -->
        <table>
            <tr>
                <td>
                    <input  onChange="changed(this,'<%=rec.getId()%>')" id="cmSite<%=rid%>" size="40" type="text" name="cmSite<%=rid%>" value="<%=dm.out("cmSite"+rid, rec.getClinicalMeasurement().getSite())%>" style="background-color: #dddddd" readonly="true">
                </td>
                <td>
                    <button type="button" onclick="editField('#cmSite<%=rid%>')" class="butEdit"></button>
                </td>
            </tr>
        </table>
    </td>
    <td class="phenominerTableCell">
        <!-- Site ACC IDs -->
        <input  onChange="changed(this,'<%=rec.getId()%>')" id="cmSiteAccID<%=rid%>" size="40" type="text" name="cmSiteAccID<%=rid%>" value="<%=dm.out("cmSiteAccID"+rid, rec.getClinicalMeasurement().getSiteOntIds())%>"/>
    </td>

    <td class="phenominerTableCell">
        <!-- Value -->
        <input onChange="changed(this,'<%=rec.getId()%>')" style="height:50px; border:0px solid black;" type="text" name="cmValue<%=rid%>" size="10" value="<%=dm.out("cmValue"+rid, rec.getMeasurementValue())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Unit -->
        <%=fu.buildSelectListLabelsNewValue("cmUnits"+rid, dao.getDistinct("PHENOMINER_ENUMERABLES where type=3 ", "concat(LABEL,concat('|', VALUE))", true), dm.out("cmUnits"+rid, rec.getMeasurementUnits()),"changed(this)")%>
    </td>
    <td class="phenominerTableCell">
        <!-- SD -->
        <input  onChange="changed(this,'<%=rec.getId()%>')" type="text" name="cmSD<%=rid%>" size="10" value="<%=dm.out("cmSD"+rid, rec.getMeasurementSD())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- SEM -->
        <input  onChange="changed(this,'<%=rec.getId()%>')" type="text" name="cmSEM<%=rid%>" size="10" value="<%=dm.out("cmSEM" + rid, rec.getMeasurementSem())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Error -->
        <input  onChange="changed(this,'<%=rec.getId()%>')" type="text" name="cmError<%=rid%>" value="<%=dm.out("cmError"+rid, rec.getMeasurementError())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Average Type -->
        <%=fu.buildSelectListNewValue("cmAveType"+rid, dao.getDistinct("PHENOMINER_ENUMERABLES where type=4 ", "value", true), dm.out("cmAveType"+rid, rec.getClinicalMeasurement().getAverageType()),false,"changed(this)")%>
    </td>
    <td class="phenominerTableCell">
        <!-- Formula -->
        <input  onChange="changed(this,'<%=rec.getId()%>')" type="text" name="cmFormula<%=rid%>" value="<%=dm.out("cmFormula"+rid, rec.getClinicalMeasurement().getFormula())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Note -->
        <input  onChange="changed(this,'<%=rec.getId()%>')" type="text" size="30" name="cmNote<%=rid%>" value="<%=dm.out("cmNote"+rid, rec.getClinicalMeasurement().getNotes())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Measurement Method -->
        <table>
            <tr>
                <td>
                    <input  onChange="changed(this,'<%=rec.getId()%>')" type="text" id="mmAccId<%=rid%>" name="mmAccId<%=rid%>" size="40" value="<%=dm.out("mmAccId"+rid, rec.getMeasurementMethod().getAccId())%>"/>
                </td>
                <td>
                    <a href="javascript:lookup_treeRender('mmAccId<%=rid%>', 'MMO', 'MMO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
                </td>
                <td>
                    <span id="mmTerm<%=rid%>" class="highlight"><%=mmTerm%></span>
                </td>
            </tr>
        </table>

    </td>
    <td class="phenominerTableCell">
        <!-- Duration -->
        <table>
            <tr>
                <td>
                    <input  onChange="changed(this,'<%=rec.getId()%>')" type="text" size="7" name="mmDuration<%=rid%>" value="<%=dm.out("mmDuration"+rid, (mmDuration == -1111L ? rec.getMeasurementMethod().getDuration() :(mmDuration > 0 ? mmDuration.toString() : "")))%>" onchange="document.getElementsByName('mmDurationUnits<%=rid%>')[0].style.color='red'"/>
                </td>
                <td>
                    <%=fu.buildSelectList("mmDurationUnits"+rid, timeUnits, (mmDuration == -1111L || mmDuration > 0) ? "" : Condition.convertDurationBoundToString(mmDuration),"changed(this)")%>
                </td>
            </tr>
        </table>

    </td>
    <td class="phenominerTableCell">
        <!-- MM Site -->
        <table>
            <tr>
                <td>
                    <input  onChange="changed(this)" id="mmSite<%=rid%>" size="40" type="text" name="mmSite<%=rid%>" value="<%=dm.out("mmSite"+rid, rec.getMeasurementMethod().getSite())%>" style="background-color: #dddddd" readonly="true">
                </td>
                <td>
                    <button type="button" onclick="editField('#mmSite<%=rid%>')" class="butEdit"></button>
                </td>
            </tr>
        </table>

    </td>
    <td class="phenominerTableCell">
        <!-- MM Site ACC IDs-->
        <input  onChange="changed(this)" id="mmSiteAccID<%=rid%>" size="40" type="text" name="mmSiteAccID<%=rid%>" value="<%=dm.out("mmSiteAccID"+rid, rec.getMeasurementMethod().getSiteOntIds())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- PI Type -->
        <input  onChange="changed(this)" type="text" name="mmPostInsultType<%=rid%>" value="<%=dm.out("mmPostInsultType"+rid, rec.getMeasurementMethod().getPiType())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- PI Time -->
        <input type="text" size="7" name="mmPostInsultTime<%=rid%>" value="<%=dm.out("mmPostInsultTime"+rid, rec.getMeasurementMethod().getPiTimeValue())%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- PI Time Unit -->
        <%=fu.buildSelectList("mmInsultTimeUnit"+rid, dao.getDistinct("PHENOMINER_ENUMERABLES where type=5 ", "value", true), dm.out("mmInsultTimeUnit"+rid, rec.getMeasurementMethod().getPiTypeUnit()),"changed(this)")%>
    </td>
    <td class="phenominerTableCell">
        <!-- Notes -->
        <input  onChange="changed(this)" type="text" size="30" name="mmNotes<%=rid%>" value="<%=dm.out("mmNotes"+rid, rec.getMeasurementMethod().getNotes())%>"/>
    </td>

    <td class="phenominerTableCell">
        <!-- Strain -->
        <table>
            <tr>
                <td>
                    <input  onChange="changed(this)" type="text" id="sAccId<%=rid%>" name="sAccId<%=rid%>" size="40" value="<%=dm.out("sAccId"+rid, rec.getSample().getStrainAccId())%>"/>
                </td>
                <td>
                    <a href="javascript:lookup_treeRender('sAccId<%=rid%>', 'RS', 'RS:0000457' )"><img src="/rgdweb/common/images/tree.png" border="0"/></a><span id="sTerm" class="highlight"><%=sTerm%></span>
                </td>
            </tr>
        </table>

    </td>
    <td class="phenominerTableCell">
        <!-- Animal Count -->
        <input  onChange="changed(this)" type="text" size="11" name="sAnimalCount<%=rid%>" value="<%=dm.outForce("sAnimalCount"+rid, (rec.getSample().getNumberOfAnimals() == 0 ? null : rec.getSample().getNumberOfAnimals()), multiEdit || (isNew && !isCloning) ?"" : "N/A")%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Min Age -->
        <input  onChange="changed(this)" type="text" size="7" name="sMinAge<%=rid%>" value="<%=dm.outForce("sMinAge"+rid, rec.getSample().getAgeDaysFromLowBound(), multiEdit || (isNew && !isCloning) ?"" : "N/A")%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Max Age -->
        <input  onChange="changed(this)" type="text" size="7" name="sMaxAge<%=rid%>" value="<%=dm.outForce("sMaxAge"+rid, rec.getSample().getAgeDaysFromHighBound(), multiEdit || (isNew && !isCloning) ?"" : "N/A")%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Sex -->
        <%=fu.buildSelectListNewValue("sSex"+rid, dao.getDistinct("PHENOMINER_ENUMERABLES where type=1 ", "value", true), dm.out("sSex"+rid, rec.getSample().getSex()),false,"changed(this)")%>
    </td>
    <td><!-- biosample id--></td>
    <%
        try {
            if (cond != null) {
    %>
    <td class="phenominerTableCell">
        <!-- Condition 1 -->
        <table>
            <tr>
                <td>
                    <input  onChange="changed(this)" type="text" id="cAccId<%=conditionCount%><%=rid%>" name="cAccId<%=rid%>" size="40" value="<%=dm.out("cAccId"+rid, cond.getOntologyId(),conditionCount)%>"/>
                </td>
                <td>
                    <a href="javascript:lookup_treeRender('cAccId<%=conditionCount%><%=rid%>', 'XCO', 'XCO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
                </td>
                <td>
                    <span id="cTerm<%=conditionCount%><%=rid%>" class="highlight"><%=cTerm%></span>
                </td>

                <% if (!multiEdit || enabledConditionInsDel) {%>
                &nbsp;<td>&nbsp;Delete?</td>
                <td><input  onChange="changed(this)" name="cDelete<%=rid%>" value="<%=cond.getId()>0?cond.getId():-conditionCount-1%>" type="checkbox"/></td>
                <% } %>

            </tr>
        </table>

    </td>
    <td class="phenominerTableCell">
        <!-- Min Value -->
        <input  onChange="changed(this)" type="hidden" name="cId<%=rid%>" value="<%=dm.out("cValue"+rid, cond.getId(), conditionCount)%>"/>
        <input  onChange="changed(this)" type="text" size="7" name="cValueMin<%=rid%>" value="<%=dm.out("cValueMin"+rid, cond.getValueMin(), conditionCount)%>"/>
    </td>
    <td class="phenominerTableCell">
        <!--Max Value -->
        <input  onChange="changed(this)" type="text" size="7" name="cValueMax<%=rid%>" value="<%=dm.out("cValueMax"+rid, cond.getValueMax(), conditionCount)%>"/>
    </td>
    <td class="phenominerTableCell">
        <%=fu.buildSelectListNewValue("cUnits"+rid, unitList, dm.out("cUnits"+rid, cond.getUnits(), conditionCount),false,"changed(this)")%><!--conditionCount added for RGD1797-->
    </td>
    <td class="phenominerTableCell">
        <!-- Min Dur -->
        <table>
            <tr>
                <td>
                    <input  onChange="changed(this)" type="text" size="12" name="cMinDuration<%=rid%>" value="<%=dm.out("cMinDuration"+rid, (cond.getDurationLowerBound() > 0 ? d_f.format(cond.getDurationLowerBound()) : ""), conditionCount)%>" onchange="document.getElementsByName('cMinDurationUnits<%=rid%>')[<%=(conditionCount)%>].style.color='red'"/>
                </td>
                <td>
                    <%=fu.buildSelectList("cMinDurationUnits"+rid, timeUnits, (cond.getDurationLowerBound() > 0 ? "" : Condition.convertDurationBoundToString(cond.getDurationLowerBound())),"changed(this)")%>
                </td>
            </tr>
        </table>

    </td>
    <td class="phenominerTableCell">
        <!-- Max Dur -->
        <table>
            <tr>
                <td>
                    <input  onChange="changed(this)" type="text" size="12" name="cMaxDuration<%=rid%>" value="<%=dm.out("cMaxDuration"+rid, (cond.getDurationUpperBound() > 0 ? d_f.format(cond.getDurationUpperBound()) : ""), conditionCount)%>" onchange="document.getElementsByName('cMaxDurationUnits<%=rid%>')[<%=(conditionCount)%>].style.color='red'"/>
                </td>
                <td>
                    <%=fu.buildSelectList("cMaxDurationUnits"+rid, timeUnits, (cond.getDurationUpperBound() > 0 ? "" : Condition.convertDurationBoundToString(cond.getDurationUpperBound())),"changed(this)")%>
                </td>
            </tr>
        </table>

    </td>
    <td class="phenominerTableCell">
        <!-- Application Method -->
        <input  onChange="changed(this)" type="text" size="30" name="cApplicationMethod<%=rid%>" value="<%=dm.out("cApplicationMethod"+rid, cond.getApplicationMethod(), conditionCount)%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Ordinality -->
        <input  onChange="changed(this)" type="text" size="7" name="cOrdinality<%=rid%>"
               value="<%=dm.out("cOrdinality"+rid, cond.getOrdinality(), conditionCount)%>"/>
    </td>
    <td class="phenominerTableCell">
        <!-- Notes -->
        <input  onChange="changed(this)" type="text" size="30" name="cNotes<%=rid%>"
               value="<%=dm.out("cNotes"+rid, cond.getNotes(), conditionCount + 1)%>"/>
    </td>
    <%
            conditionCount++;
        }
    } catch (Exception e) {
    %>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <%
        }
    %>

</tr>
