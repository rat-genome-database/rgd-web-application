

<!-- heat map styles -->
<style>

    * html .iewrap      {
        float: left;
        /*width*/
        argin-left: <%=horizontalWidth%>px;
        display: inline;
        position: relative;
    }

    * html .container {
		float: left;
        /*width*/
		argin-left: -<%=horizontalWidth%>px;
		position: relative;
		}

    .container {

        position: relative;
         /* this will give container dimension, because floated child nodes don't give any */
         /* if your child nodes are inline-blocked, then you don't have to set it */
         /*overflow: auto;*/

        /*width*/
        in-width: <%=horizontalWidth%>px;

     }

     .container .head{

           /* float your elements or inline-block them to display side by side */
           float: left;
           /* these are height and width dimensions of your header */

            height: <%=yMenuHeight%>px;
            width: <%=cellWidth%>px;
            overflow: hidden;

            /* these are not relevant and are here to better see the elements */
            background: #eee;
            argin-right: 1px;
        }

    .container a {
        color: #3F3F3F;
        font-family: Arial;
        font-size: 11px;
    }

            .container .head .vert

            {



                *position: absolute;
                 *bottom: 0;
                 *left: 0;

                /* line height should be equal to header width so text will be middle aligned */
                line-height: <%=cellWidth%>px;

                font-size:12px;

                /* setting background may yield better results in IE text clear type rendering */
                background: #eee;
                display: block;

                /* this will prevent it from wrapping too much text */
                white-space: nowrap;

                /* so it stays off the edge */
                --padding-left: 3px;

                <% String ua = request.getHeader( "User-Agent" ); %>

            <% if( ua != null && (ua.indexOf( "MSIE 9" ) != -1 || ua.indexOf( "MSIE 8" ) != -1 || ua.indexOf( "MSIE 7" ) != -1 ) ){ %>
                /* IE specific rotation code */
                writing-mode: tb-rl;
                filter: flipv fliph;
            <% } %>

                /* CSS3 specific totation code */
                /* translate should have the same negative dimension as head height */
                transform: rotate(270deg) translate(-<%=yMenuHeight%>px,0);
                transform-origin: 0 0;
                -moz-transform: rotate(270deg) translate(-<%=yMenuHeight%>px,0);
                -moz-transform-origin: 0 0;
                -webkit-transform: rotate(270deg) translate(-<%=yMenuHeight%>px,0);
                -webkit-transform-origin: 0 0;



            }

        .heatCell {
            position:relative;
            min-width: <%=cellWidth%>px;
            min-height: <%=(cellWidth-1)%>px;
            width:<%=cellWidth%>px;
            height:<%=(cellWidth-1)%>px;
            border-top: 1px solid white;
            border-left: 1px solid white;
            font-size: 9px;
            text-align:center;
            overflow: hidden;

        }

    .conCell {
        position:relative;

        min-width: <%=cellWidth%>px;
        min-height: <%=cellWidth%>px;
        width:<%=cellWidth%>px;
        height:<%=cellWidth%>px;
        *width: <%=cellWidth + 1%>px;
        *height: <%=cellWidth + 1%>px;
        border-top: 1px solid white;
        border-right: 1px solid white;
        font-size: 9px;
        text-align:center;
        overflow: hidden;
        ertical-align: middle;


    }


</style>