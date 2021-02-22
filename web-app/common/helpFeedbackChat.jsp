<!DOCTYPE html>
<html>
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.12/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        input[type="text"], textarea {
            width: 100%;
            height: 30px;
            font-size: Large;
            background-color : #f1f1f1;

        }
        input[type="email"], textarea {
            width: 100%;
            height: 30px;
            font-size: large;
            background-color : #f1f1f1;

        }

        body {font-family: Arial, Helvetica, sans-serif;}
        * {box-sizing: border-box;}

        .thumbsUp {
            bottom: 28px;
            right: 10px;
            position: fixed;
        }
        /* Button used to open the chat form - fixed at the bottom of the page */
        .open-button {
            background-color: #555;
            color: white;
            padding: 16px 20px;
            border: none;
            cursor: pointer;
            opacity: 0.8;
            position: fixed;
            bottom: 23px;
            right: 78px;
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

<%--<button class="thumbsUp"><img src="/rgdweb/common/images/thumbsUpS.png" ></button>--%>
<button class="open-button" onclick="openForm()">Send Message</button>

<%--<button id="ajaxVue" type="button" v-on:click="fcn">Button</button>--%>

<div class="chat-popup" id="ajaxVue">
    <form action="https://rgd.mcw.edu/tools/contact/contact.cgi" class="form-container">
<%--        <img src="/rgdweb/common/images/del.jpg" id="img1" onclick="closeForm()">--%>
        <button type="button" id="close" onclick="closeForm()" class="closeForm">x</button>
        <h1>Send us a Message</h1>
        <input type="hidden" name="subject" value="Help and Feedback Form">
        <input type="hidden" name="found" value="0">
<%--        <label><b>First Name</b></label>--%>
<%--        <br><input type="text" name="firstname">--%>
<%--        <br><label><b>Last Name</b></label>--%>
<%--        <br><input type="text" name="lastname">--%>
        <label><b>Email</b></label>
        <br><input type="email" name="email" v-model="email"></input>
        <br><label><b>Message</b></label>
        <textarea placeholder="Type message.." name="comment" v-model="message"></textarea>

        <button type="button" class="btn" v-on:click="fcn">Send</button>
<%--        <button type="button" class="btn cancel" onclick="closeForm()">Close</button>--%>

    </form>
</div>

<script>
    function openForm() {
        document.getElementById("ajaxVue").style.display = "block";
    }

    function closeForm() {
        document.getElementById("ajaxVue").style.display = "none";
    }
</script>

</body>
</html>
<script>
    var ajaxVue = new Vue({
        el: '#ajaxVue',
        data: {
            email: '',
            message: ''
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
                            message: ajaxVue.message,
                            bypass: true
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
</script>
