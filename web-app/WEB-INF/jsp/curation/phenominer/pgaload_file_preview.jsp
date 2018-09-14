<%-- PREVIEW of FIRST FEW LINES FROM THE DATA FILE --%>
<div style="float:left;">
    <h3>First 10 lines from the file</h3>
    <%  // one data line from file could be shown in several lines in the preview winodw
        final int maxCharsPerLine = 135;
        StringBuffer preview = new StringBuffer();
        for( int lineNr=0; lineNr<10 && lineNr<bean.getData().size(); lineNr++ ) {
            String[] cols = bean.getData().get(lineNr);
            StringBuffer line = new StringBuffer();
            for( String col: cols ) {
                line.append(col).append(',');
            }

            int lineParts = (line.length()+maxCharsPerLine-1)/maxCharsPerLine - 1;
            for( int pos; (pos=lineParts*maxCharsPerLine)>0; lineParts-- ) {
                line.insert(pos, "\n  ");
            }
            line.append('\n');
            preview.append(line);
        }
    %>
    <pre style="border-width:1px;border-color:black;background-color:#b2d1ff;"><%=preview%></pre>
</div>
