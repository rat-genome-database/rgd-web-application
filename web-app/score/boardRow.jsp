
<div style="border:1px solid #25619d; padding-top: 5px;">
<span style="font-weight:700; font-style:italic; color: #25619d;">&nbsp;<%=boardRowTitle%></span>
<table style="border: 0px solid black;">
<tr>
<%
    {
    Iterator boardIt = boardMap.keySet().iterator();

    while (boardIt.hasNext()) {
        String val = (String) boardIt.next();
%>
        <td valign="top">
        <table style="border-right:1px dashed black; height:100%;" height="100%":>
            <tr>
                <td style="font-weight:700;"><%=val%></td>
            </tr>
            <tr>
                <td><%=boardMap.get(val)%></td>
            </tr>
        </table>
        </td>
<%
    }
    }
%>
</tr>
</table>
</div>