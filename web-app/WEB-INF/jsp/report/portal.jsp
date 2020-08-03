<%@ include file="sectionHeader.jsp"%>

<%
    // use uf getPortalsForObject is recommended because it computes dynamically
    // to which portals given rgd belongs to
    List<Portal> portals = RgdContext.isChinchilla(request)
            ? Collections.<Portal>emptyList() // no portals for chinchilla
//            : dao.getPortalsForObject(obj.getRgdId());
            : dao.getPortalsForObjectCached(obj.getRgdId());

    // sort portals by portal full name (they have same master portal key), then by portal page name
    Collections.sort(portals, new Comparator<Portal>() {

        public int compare(Portal o1, Portal o2) {
            int r = Utils.stringsCompareToIgnoreCase(o1.getFullName(), o2.getFullName());
            if( r!=0 )
                return r;
            return Utils.stringsCompareToIgnoreCase(o1.getPageName(), o2.getPageName());
        }
    });

    // display only 'Standard' portals
    int nonStandardPortalCount =0;
    for (Portal port: portals) {
        if (!port.getPortalType().equals("Standard")) {
              nonStandardPortalCount++;
        }
    }

    if (portals.size() > nonStandardPortalCount) {
%>

<%=ui.dynOpen("portalAsscociation", "RGD Disease Portals")%>    <br>
<table border="0">

<tr>
    <td colspan="2" style="font-weight:700; font-size: 14px;"><%=obj.getSymbol()%> has been annotated in the following RGD Disease Portals.<br><br></td>
</tr>
<%

    int lastMaster=0;

    for (Portal portal : portals) {

        if (!portal.getPortalType().equals("Standard")) {
            continue;
        }

        if (lastMaster != portal.getMasterPortalKey()) {
            if (lastMaster != 0) {
%>
    </td></tr>
    <%
        }

        lastMaster = portal.getMasterPortalKey();
    %>

    <tr>
        <td><a href="/rgdCuration/?module=portal&func=show&name=<%=portal.getUrlName()%>"><img
                src="<%=portal.getImageUrl()%>"/></a></td>
        <td>
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td><img src='/rgdweb/common/images/bullet_green.png'/></td>
                    <td>
                        <a href="/rgdCuration/?module=portal&func=show&name=<%=portal.getUrlName()%>"><%=portal.getPageName()%></a>
                    </td>
                </tr>
            </table>
            <% } else { %>

            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td><img src='/rgdweb/common/images/bullet_green.png'/></td>
                    <td>
                        <a href="/rgdCuration/?module=portal&func=show&name=<%=portal.getUrlName()%>"><%=portal.getPageName()%></a>
                    </td>
                </tr>
            </table>

        <%  }
        } %>
       </td></tr>

    </table>
<br>
<%=ui.dynClose("portalAsscociation")%>  

<%
    }
%>

<%@ include file="sectionFooter.jsp"%>

