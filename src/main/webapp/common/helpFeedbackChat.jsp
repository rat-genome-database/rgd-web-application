<html>
<script src="/rgdweb/js/webFeedback.js"></script>

<body>
    <div id="divButtons" class="btnDiv" style="display: none">
        <button type="button" class="hideMe" id="hideDiv" onclick="hideButtons()">x</button>
        <button class="thumbsDown" v-on:click="dislikedPage"></button>
        <button class="open-button" onclick="openForm()">Send Message</button>
        <button class="thumbsUp" v-on:click="likedPage"></button>
    </div>
    <div id="hiddenBtns" class="hiddenBtns">
        <button type="button" class="openLikeBtn" onclick="hideButtons()"></button>
    </div>

<div class="chat-popup" id="messageVue">
    <form class="form-container">
        <button type="button" id="close" onclick="closeForm()" class="closeForm">x</button>
        <h2 id="headMsg">Send us a Message</h2>
        <input type="hidden" name="subject" value="Help and Feedback Form">
        <input type="hidden" name="found" value="0">

        <label><b>Your email</b></label>
        <br><input type="email" name="email" v-model="email">
        <br><label><b>Message</b></label>
        <textarea placeholder="Type message.." name="comment" v-model="message"></textarea>

        <button type="button" id="sendEmail" class="btn" v-on:click="sendMail">Send</button>

    </form>
</div>
</body>
</html>
