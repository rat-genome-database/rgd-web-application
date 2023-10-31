<tr>
    <td class="headcol">
        <table>
            <tr>
                <td><input style="color:white;font-weight:700;background-color:#1e392a; width:76px; border-radius: 10px; height:49px;"  type="button" value="Save All" onClick="saveAll()"/></td>
                <td><input style="font-weight:700;background-color:#25C780; width:76px; border-radius: 10px; height:49px;"  type="button" value="New" onClick="newRecord()"/></td>
            </tr>
        </table>
    </td>
    <td class="phenominerTableHeader" >
        SID
    </td>
    <td class="phenominerTableHeader">
        EID
    </td>
    <td class="phenominerTableHeader">
        RID
    </td>
    <td class="phenominerTableHeader">
        Curation Status
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'cmAccId')">
        Clinical Measurement <%=requiredFieldIndicator%>
    </td>
    <td class="phenominerTableHeader">
        Site
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'cmSiteAccID')">
        Site Acc IDs ("|" separated)
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'cmValue')">
        Value
    </td>
    <td class="phenominerTableHeader">
        Unit <%=requiredFieldIndicator%>
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'cmSD')">
        SD
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'cmSEM')">
        SEM
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'cmError')">
        Error
    </td>
    <td class="phenominerTableHeader">
        Average Type
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'cmFormula')">
        Formula
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'cmNote')">
        Note
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'mmAccId')">
        Measurement Method <%=requiredFieldIndicator%>
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'mmDuration')">
        Duration
    </td>
    <td class="phenominerTableHeader">
        Site
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'mmSiteAccID')">
        Site Acc IDs ("|" separated)
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'mmPostInsultType')">
        PI Type
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'mmPostInsultTime')">
        PI Time
    </td>
    <td class="phenominerTableHeader">
        PI Time Unit
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'mmNotes')">
        Notes
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'sAccId')">
        Strain <%=requiredFieldIndicator%>
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'sAnimalCount')">
        Animal Count <%=requiredFieldIndicator%>
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'sMinAge')">
        Min Age <%=requiredFieldIndicator%>
    </td>
    <td class="phenominerTableHeader" onClick="showUploadWindow(event, 'sMaxAge')">
        Max Age <%=requiredFieldIndicator%>
    </td>
    <td class="phenominerTableHeader">
        Sex <%=requiredFieldIndicator%>
    </td>
    <td class="phenominerTableHeader">BioSample ID</td>
    <%
     for (conditionCount=1;conditionCount<15;conditionCount++) {
         %>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Experimental Condition <%=requiredFieldIndicator%>
        </td>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Min Value
        </td>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Max Value
        </td>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Unit
        </td>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Minimum Duration
        </td>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Maximum Duration
        </td>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Application Method
        </td>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Ordinality <%=requiredFieldIndicator%>
        </td>
        <td class="phenominerTableHeader">
            <span style="background-color:white;border:3px solid black; border-radius:20px; font-size:22px; font-weight:700;padding-left:6px; padding-right:6px;margin-left:2px;margin-right:5px;"><%=conditionCount%></span>&nbsp;Notes
        </td>
    <% } %>
</tr>