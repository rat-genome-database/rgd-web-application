
<%
    String pageHeader="Search Samples";
    String pageTitle="Search Samples";
    String headContent="";
    String pageDescription = "Search Samples";
%>
<%@ include file="/common/headerarea.jsp"%>
<div>
    <form action="editSamples.html" method="POST">
        <table>
            <tr>
                <td>Search by sample ID(s)</td>
            </tr>
            <tr>
                <td>
                    <textarea id="sampleSearch" name="sampleSearch" style="width: 200px; height: 150px" required></textarea>
                </td>
                <td>
                    <button type="submit">Search</button>
                </td>
            </tr>
        </table>
    </form>
<hr>
    <form action="editSamples.html" method="post">
        <table>
            <tr>
                <td>Insert Study ID or Experiment ID</td>
            </tr>
            <tr>
                <td>
                    <input type="radio" name="studyExperBtn" id="Study" value="Study">&nbsp;<label>Study ID</label>
                </td>
                <td>
                    <input type="radio" name="studyExperBtn" id="Experiment" value="Experiment">&nbsp;<label>Experiment ID</label>
                </td>
            </tr>
            <tr>
                <td><input type="text" id="studyExperSearch" name="studyExperSearch" required></td>
                <td><button type="submit">Search</button></td>
            </tr>
        </table>
    </form>
<hr>
    <form action="editSamples.html" method="get">
        <table>
            <tr><td><label>Geo ID search</label></td></tr>
            <tr>
                <td>
                    <input type="text" id="gse" name="gse" required></input>
                </td>
                <td>
                    <label for="species" style="color: #24609c; font-weight: bold;">Select a Species:</label>
                    <select id="species" name="species" >
                        <option value="Rattus">Rat</option>
                        <option  value="Mus">Mouse</option>
                        <option  value="Homo">Human</option>
                        <option  value="Chinchilla">Chinchilla</option>
                        <option  value="Pan">Bonobo</option>
                        <option  value="Canis">Dog</option>
                        <option  value="Ictidomys">Squirrel</option>
                        <option value="Sus">Pig</option>
                        <option value="Glaber">Naked Mole-Rat</option>
                        <option value="Sabaeus">Green Monkey</option>
                    </select>
                </td>
                <td>
                    <button type="submit">Search</button>
                </td>
            </tr>
        </table>
    </form>
</div>
<%@ include file="/common/footerarea.jsp"%>