<%
    String speciesType = request.getParameter("species");
    if (speciesType == null) {
        speciesType="3";
    }
    int speciesTypeKey = Integer.parseInt(speciesType);
%>
<td><label id="lbl_species" for="sel_species" accesskey="S">Species:</label></td>
<td><select name="species" id="sel_species">
    <option value="0" <%=fu.optionParams(speciesType, "0")%>>ALL</option>
    <option value="1" <%=fu.optionParams(speciesType, "1")%>>Human</option>
    <option value="2" <%=fu.optionParams(speciesType, "2")%>>Mouse</option>
    <option value="3" <%=fu.optionParams(speciesType, "3")%>>Rat</option>
    <option value="4" <%=fu.optionParams(speciesType, "4")%>>Chinchilla</option>
    <option value="5" <%=fu.optionParams(speciesType, "5")%>>Bonobo</option>
    <option value="6" <%=fu.optionParams(speciesType, "6")%>>Dog</option>
    <option value="7" <%=fu.optionParams(speciesType, "7")%>>Squirrel</option>
    <option value="9" <%=fu.optionParams(speciesType, "9")%>>Pig</option>
  </select>
</td>