
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 5, 2008
  Time: 9:18:22 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String pageTitle = "General Search - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
    
%>
  <%@ include file="/common/headerarea.jsp"%>

  <br><br>

  <!--#cd2e29-->


  <script type="text/javascript">
  //addEvent(window, "load", initPoll);


  function toggleSearchBox(divFrom, divTo) {
          divFrom.style.display ='none';
          divTo.style.display = 'block';
          document.getElementById(divTo.id + "Link").style.color = "black";
          document.getElementById(divTo.id + "Link").style.fontWeight = "700";
          document.getElementById(divFrom.id + "Link").style.color = "";
          document.getElementById(divFrom.id + "Link").style.fontWeight = "";
          document.getElementById(divFrom.id + "Link").style.backgroundColor = "";
          document.getElementById(divTo.id + "Link").style.backgroundColor = "#ffcf3e"; //ffcf3e

  }
  </script>

  <table align="center" cellpadding="0" cellspacing="0" border="0">
  <tr>
   <td align="left">

   </td>
  </tr>

  <tr><td valign="top">

  <div class="searchBox" id="keywordBox">
  <table border="0"><tr><td><img src="/common/images/SearchByKeyword_icon.gif" /></td>
  <td>
  <table border="0" cellpadding="0" cellspacing="0" width="100%">
          <form method="post" action="/rgdweb/search/search.html" onsubmit="return verify(this);" name="search2">
            <tbody>
            <tr>
  <td><div class="searchHeader">Search RGD By Keyword</div></td></tr>
         <tr>
          <td colspan="2" align="left" ><div class="searchExamples">
  <b>Examples:</b> <a href="javascript:document.search2.term.value='A2m';document.search2.submit();">A2m</a>, <a href="javascript:document.search2.term.value='&quot;blood pressure&quot;';document.search2.submit();">&quot;blood pressure&quot;</a>, <a href="javascript:document.search.term.value='SS BN Mcwi';document.search2.submit();">SS BN Mcwi</a>, <a href="javascript:document.search2.term.value='obesity and blood pressure';document.search2.submit();" >obesity and blood pressure</a>, <a href="javascript:document.search2.term.value='*mgh*';document.search2.submit();">*mgh*</a>, <a href="javascript:document.search2.term.value='pmid:15232614';document.search2.submit();">pmid:15232614</a><br>
          </div>
      </td>
           </tr>
           <tr>
          <td colspan="2">&nbsp;</td>
           </tr>
       <tr>
              <td align="left" colspan="2">
          <table cellpadding="0" cellspacing="0" border="0">
  <tr>
  <td>

  <input name="term" size="60" class="searchKeyword" value="" onfocus="JavaScript:document.search2.term.value=''" type="text" />
          </td>
              <td >
  <input type="submit" value="Search" alt="Search RGD" class="searchButton" />
              </td>
            </tr>
  </table>
  </td>
  </tr>


          </tbody>
      </form>
        </table>
  </td></tr></table>
  </div>

  </td></tr>
  <tr><td>

  <div class="searchBox" id="positionBox">
  <table border="0"><tr><td><img src="/common/images/SBP_icon.gif" /></td>
  <td>
  <table  border="0" cellpadding="0" cellspacing="0">
          <form  name="form"  id="form" method="POST" action="/plf/plfRGD/?module=searchByPosition&func=form" >
            <tbody>
            <tr><td><div class="searchHeader">Search RGD By Position</div></td></tr>
         <tr>
          <td colspan="2" align="left" ><div class="searchExamples">
  <b>Examples:</b> <a href="/plf/plfRGD/?chromosome=2&start_pos=12000000&stop_pos=130000000&submitBtn=Search+by+Position&hiddenXYZ123=&module=searchByPosition&func=form">Chr 2: 12000000 - 130000000</a><br>
          </div>
      </td>
           </tr>
           <tr>
          <td colspan="2">&nbsp;</td>
           </tr>
       <tr>
              <td align="left" colspan="2">
          <table cellpadding="0" cellspacing="0" border="0">
  <tr>
  <td>

  <table class="searchByPositionForm" align="center" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td valign="top">Chr:</td>

        <td valign="top"> <select  tabindex="1001" name="chromosome" id="chromosome" class="searchChr" ><option value="1" selected>1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="X">X</option><option value="Y">Y</option><option value="MT">MT</option></option></select></td>

        <td valign="top">From:</td>
        <td align="right" valign="top"> <input type="text" tabindex="1003" name="start_pos" id="start_pos" size="11" maxlength="31" class="searchStart" />(bp)&nbsp;&nbsp;</td>
        <td valign="top">To:</td>

        <td valign="top"> <input type="text" tabindex="1005" name="stop_pos" id="stop_pos" size="11" maxlength="31"  class="searchStop"/>(bp)&nbsp;</td>
        <td valign="top"><input type="submit" tabindex="1006" name="submitBtn" value="Search by Position" class="searchButton" /><br/><input type="hidden" name="hiddenXYZ123"/><input type="hidden" name="module" value="searchByPosition"/><input type="hidden" name="func" value ="form"/></form></td>

      </tr>
    </table>

              </td>
            </tr>

  </table>
  </td>
  </tr>
          </tbody>
        </form></table>
  </td></tr></table>
  </div>
  </td>
  </tr>
  <tr>
  <td>
  <br>
  <table cellpadding="0" cellspacing="0" class="searchLinks" border="0">
            <tr>
              <td align="left" colspan="2" valign="center"><img src="/common/images/circleBullet.gif" border="0" style="margin: 2px;"><a href="ftp://ftp.rgd.mcw.edu/pub" class="atitle">Download Data via FTP</a>
              </td>
            </tr>
  </table>
  </td>
  </tr>


  </table>

  <script>
  //toggleSearchBox(document.getElementById("positionBox"), document.getElementById("keywordBox"));
  </script>

  <%@ include file="/common/footerarea.jsp"%>

