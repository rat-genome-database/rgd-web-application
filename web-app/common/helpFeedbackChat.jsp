<html>

<body>
    <div id="divButtons" class="btnDiv">
        <button type="button" class="hide" id="hideDiv" onclick="hideButtons()">Hide</button>
        <button class="thumbsDown"><img src="/rgdweb/common/images/thumbsDownS.png" v-on:click="dislikedPage"></button>
        <button class="open-button" onclick="openForm()">Send Message</button>
        <button class="thumbsUp"><img src="/rgdweb/common/images/thumbsUpS.png" v-on:click="likedPage"></button>
    </div>

<div class="chat-popup" id="ajaxVue">
    <form action="https://rgd.mcw.edu/tools/contact/contact.cgi" class="form-container">
        <button type="button" id="close" onclick="closeForm()" class="closeForm">x</button>
        <h1>Send us a Message</h1>
        <input type="hidden" name="subject" value="Help and Feedback Form">
        <input type="hidden" name="found" value="0">

        <label><b>Email</b></label>
        <br><input type="email" name="email" v-model="email"></input>
        <br><label><b>Message</b></label>
        <textarea placeholder="Type message.." name="comment" v-model="message"></textarea>

        <button type="button" class="btn" v-on:click="fcn">Send</button>

    </form>
</div>
</body>
</html>
<script>
    checkCookie();
</script>
