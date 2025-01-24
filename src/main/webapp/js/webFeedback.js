
function openForm() {
    document.getElementById("messageVue").style.display = "block";
    document.getElementById("headMsg").innerText = 'Send us a Message';
}

function closeForm() {
    document.getElementById("messageVue").style.display = "none";
    document.getElementById("sendEmail").disabled = false;
}
function hideButtons() {
    var div = document.getElementById('divButtons');
    var div2 = document.getElementById("hiddenBtns");
    document.cookie = 'hideMe=true;path=/';
    // alert(document.cookie);
    if (div.style.display !== 'none') {
        div.style.display = 'none';
        div2.style.display = 'block';
    }
    else {
        div.style.display = 'block';
        div2.style.display = 'none';
    }

};

// window.onload = function () {
    var messageVue = new Vue({
        el: '#messageVue',
        data: {
            email: '',
            message: '',
        },
        methods: {
            sendMail: function () {
                if (this.message === '' || !this.message) {
                    alert("There is no message entered.");
                    return;
                }
                if (this.email === '' || !this.email) {
                    alert("No email provided.");
                    return;
                }
                if (!emailValidate(this.email)) {
                    alert("Not a valid email address.");
                    return;
                }
                document.getElementById("sendEmail").disabled = true;
                axios
                    .post('/rgdweb/contact/weblikes.html',
                        {
                            email: messageVue.email,
                            message: messageVue.message,
                            bypass: true,
                            subject: 'Send Message Form',
                            firstname: 'Generic',
                            lastname: 'Name',
                            webPage: window.location.href
                        })
                    .then(function (response) {
                        closeForm();
                        messageVue.email="";
                        messageVue.message="";
                        alert("Thank you!  Your message has been sent to RGD.")

                    }).catch(function (error) {
                    console.log(error)
                })
            }
        } // end methods
    });

    function emailValidate(message) {
        var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(message);
    }

    var divButtons = new Vue({
        el: '#divButtons',
        data: {
            liked: false,
            disliked: false
        },
        methods: {
            likedPage: function () {
                //alert(window.location.href);
                const headers = {
                    'Content-Type': 'application/json'
                };
                axios
                    .post('/rgdweb/contact/weblikes.html',
                        {
                            liked: true,
                            disliked: false,
                            webPage: window.location.href,
                            bypass: false
                        },
                        {headers: headers}
                    )
                    .then(function (response) {
                        openForm();
                        document.getElementById("headMsg").innerText = 'Thanks for the feedback!\nTell us what you liked.';
                        hideButtons();
                    })
                    .catch(function (error) {
                    console.log(error)
                })

            },
            dislikedPage: function () {
                const headers = {
                    'Content-Type': 'application/json'
                };
                axios
                    .post('/rgdweb/contact/weblikes.html',
                        {
                            liked: false,
                            disliked: true,
                            webPage: window.location.href,
                            bypass: false
                        },
                        {headers: headers}
                    )
                    .then(function (response) {
                        openForm();
                        document.getElementById("headMsg").innerText = 'Thanks for the feedback!\nTell us what we can fix.';
                        hideButtons();
                    })
                    .catch(function (error) {
                    console.log(error)
                })

            }
        }
    });
// };
