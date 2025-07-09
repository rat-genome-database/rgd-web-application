<div style="border:1px solid #25619d; padding-top: 5px;">
    <span style="font-weight:700; font-style:italic; color: #25619d;">&nbsp;<%=boardRowTitle%></span>
    <table style="border: 0px solid black;">
        <tr id="<%=boardRowId%>">
            <td valign="top">Loading ...</td>
        </tr>
    </table>
</div>

<script>
    $(document).ready(function(){
        $.get("https://<%=RgdContext.getHostname()%><%=boardRowUri%>", function(responseText, status, xhr){

            var html = '';
            if( status=='error') {
                html = '<div style="color:red;font-weight:bold">ERROR: '+xhr.status+' '+xhr.statusText+'</div>';
            } else {
                for (var k in responseText) {
                    html += '<td valign="top">\n';
                    html += '<table style="border-right:1px dashed black; height:100%;" height="100%">';
                    html += '<tr><td style="font-weight:700;">' + k + '</td></tr>';
                    html += '<tr><td>' + responseText[k] + '</td></tr>';
                    html += '</table>\n';
                    html += '</td>\n';
                }
            }
            $("#<%=boardRowId%>").html(html);
        });
    });
</script>

