<%@ page import="javax.servlet.http.Cookie"%>
<!DOCTYPE html>
<html>
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.12/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>

        input[type="email"], textarea {
            width: 100%;
            height: 30px;
            font-size: large;
            background-color : #f1f1f1;

        }

        body {font-family: Arial, Helvetica, sans-serif;}
        * {box-sizing: border-box;}
        .hide {
            bottom: 82px;
            right: 9px;
            position: fixed;
            opacity: .5;
        }
        .thumbsUp {
            bottom: 26px;
            right: 182px;
            position: fixed;
            /*max-width: 50px;*/
            /*max-height: 50px;*/
            /*border-radius: 25px;*/
            /*display: block;*/
        }
        .thumbsDown {
            bottom: 26px;
            right: 9px;
            position: fixed;

            /*border-radius: 25px;*/
            /*display: block;*/
        }
        .btnDiv {
            bottom: 15px;
            right: 5px;
            height: 93px;
            width: 250px;
            position: fixed;
            background-color: #bcbcbc;

        }
        /* Button used to open the chat form - fixed at the bottom of the page */
        .open-button {
            background-color: #2865A3;
            color: white;
            padding: 16px 20px;
            border: none;
            cursor: pointer;
            opacity: 0.8;
            position: fixed;
            bottom: 23px;
            right: 80px;
            width: 100px;
        }

        /* The popup chat - hidden by default */
        .chat-popup {
            display: none;
            position: fixed;
            bottom: 0;
            right: 15px;
            border: 3px solid #f1f1f1;
            z-index: 9;
        }

        /* Add styles to the form container */
        .form-container {
            max-width: 300px;
            padding: 10px;
            background-color: white;
        }

        /* Full-width textarea */
        .form-container textarea {
            width: 100%;
            padding: 15px;
            margin: 5px 0 22px 0;
            border: none;
            background: #f1f1f1;
            resize: none;
            min-height: 200px;
        }

        /* When the textarea gets focus, do something */
        .form-container textarea:focus {
            background-color: #ddd;
            outline: none;
        }

        /* Set a style for the submit/send button */
        .form-container .btn {
            background-color: #2865A3;
            color: white;
            padding: 16px 20px;
            border: none;
            cursor: pointer;
            width: 100%;
            margin-bottom:10px;
            opacity: 0.8;
        }

        .closeForm {
            position: absolute;
            top: 0;
            right: 0;
            background-color: red;
            color: white;

        }
        /* Add a red background color to the cancel button */
        .form-container .cancel {
            background-color: red;
        }

        /* Add some hover effects to buttons */
        .form-container .btn:hover, .open-button:hover {
            opacity: 1;
        }
    </style>
</head>
<body>
    <div id="buttons" class="btnDiv">
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

<script>
    checkCookie();
    function openForm() {
        document.getElementById("ajaxVue").style.display = "block";
    }

    function closeForm() {
        document.getElementById("ajaxVue").style.display = "none";
    }
    function hideButtons() {
        var div = document.getElementById('buttons');
        document.cookie = "hideMe=true; path=/"
        //alert(document.cookie);
        if (div.style.display !== 'none') {
            div.style.display = 'none';
        }
        else {
            div.style.display = 'block';
        }
    };
    function checkCookie() {
        if(document.cookie.indexOf("hideMe") != -1)
            hideButtons();
    }
</script>

</body>
</html>
<script>
    var ajaxVue = new Vue({
        el: '#ajaxVue',
        data: {
            email: '',
            message: '',
        },
        methods: {
            fcn : function (){
                if (this.message === '' || !this.message) {
                    alert("There is no message entered.")
                    return;
                }
                if (!emailValidate(this.email)) {
                    alert("not an email")
                    return;
                }
                if (this.email === '' || !this.email){
                    alert("No email provided.")
                    return;
                }
                axios
                    .post('/tools/contact/contact.cgi',
                        {
                            email: ajaxVue.email,
                            comment: ajaxVue.message,
                            bypass: true,
                            subject: 'Send Message Form',
                            found: 0,
                            firstname: 'Generic',
                            lastname: 'Name',
                            reply: 'Help'
                        })
                    .then(function (response){
                        alert('success');
                    }).catch(function (error) {
                    console.log(error)
                })
            }
        } // end methods
    })
    function emailValidate(message){
        var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(message);
    }
    var buttons= new Vue({
        el: '#buttons',
        data: {
            liked: false,
            disliked: false
        },
        methods: {
            likedPage : function() {
                //alert(window.location.href);
                const headers = {
                    'Content-Type': 'application/json'
                }
                axios
                    .post('/rgdweb/report/weblikes.html',
                        {
                            liked: true,
                            disliked: false,
                            webPage: window.location.href
                        },
                        {   headers: headers    }
                    )
                    .then(function (response){
                        alert("Liked")
                    }).catch(function (error) {
                        console.log(error)
                    })
                hideButtons();
                openForm();
                //alert("After axios")
            },
            dislikedPage : function() {
                const headers = {
                    'Content-Type': 'application/json'
                }
                axios
                    .post('/rgdweb/report/weblikes.html',
                        {
                            liked: false,
                            disliked: true,
                            webPage: window.location.href
                        },
                        {   headers: headers    }
                    )
                    .then(function (response){
                        alert("Disliked")
                    }).catch(function (error) {
                    console.log(error)
                })
                hideButtons();
                openForm();

            }
        }
    })
</script>
