
function openForm() {
    document.getElementById("messageVue").style.display = "block";
}

function closeForm() {
    document.getElementById("messageVue").style.display = "none";
}
function hideButtons() {
    var div = document.getElementById('divButtons');
    var div2 = document.getElementById("hiddenBtns");
    // var now = new Date();
    // var time = now.getTime();
    // var expireTime = time + (1000 * 60 * 60 * 24);
    // now.setTime(expireTime);
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
function checkCookie() {
    if(document.cookie.indexOf("hideMe") != -1){
        hideButtons();
    }

}
window.onload = function () {
    var messageVue = new Vue({
        el: '#messageVue',
        data: {
            email: '',
            message: '',
        },
        methods: {
            sendMail: function () {
                if (this.message === '' || !this.message) {
                    alert("There is no message entered.")
                    return;
                }
                if (this.email === '' || !this.email) {
                    alert("No email provided.")
                    return;
                }
                if (!emailValidate(this.email)) {
                    alert("Not a valid email address.")
                    return;
                }

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
                    }).catch(function (error) {
                    console.log(error)
                })
            }
        } // end methods
    })

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
                }
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
                    // .then(function (response) {
                    //     alert("Liked")
                    // })
                    .catch(function (error) {
                    console.log(error)
                })
                hideButtons();
                openForm();
                //alert("After axios")
            },
            dislikedPage: function () {
                const headers = {
                    'Content-Type': 'application/json'
                }
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
                    // .then(function (response) {
                    //     alert("Disliked")
                    // })
                    .catch(function (error) {
                    console.log(error)
                })
                hideButtons();
                openForm();

            }
        }
    })
}