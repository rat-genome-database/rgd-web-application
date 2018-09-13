<%@ page import="java.lang.reflect.Method" %>



<%
try {

if (false) {

            Class c = obj.getClass();
            Method m[] = c.getDeclaredMethods();
    out.print("<table>");
    for (int i = 0; i < m.length; i++)     {
            out.print("<tr>");
            if (m[i].toString().contains("get")) {
                out.println("<td><b>" + m[i].getName() + "</b></td>");
                Object result = m[i].invoke(obj, new Object[] {});
                out.println("<td>" + result + "</td>");
            }
        out.print("</tr>");
          }
    out.print("</table>");

}

 }catch (Throwable e) {
     System.err.println(e);
 }

%>
<br><br>

