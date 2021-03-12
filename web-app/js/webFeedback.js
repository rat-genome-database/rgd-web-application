
function openForm() {
    document.getElementById("ajaxVue").style.display = "block";
}

function closeForm() {
    document.getElementById("ajaxVue").style.display = "none";
}
function hideButtons() {
    var div = document.getElementById('divButtons');
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
window.onload = function () {
    var ajaxVue = new Vue({
        el: '#ajaxVue',
        data: {
            email: '',
            message: '',
        },
        methods: {
            fcn: function () {
                if (this.message === '' || !this.message) {
                    alert("There is no message entered.")
                    return;
                }
                if (!emailValidate(this.email)) {
                    alert("not an email")
                    return;
                }
                if (this.email === '' || !this.email) {
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
                    .then(function (response) {
                        alert('success');
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
                    .post('/rgdweb/report/weblikes.html',
                        {
                            liked: true,
                            disliked: false,
                            webPage: window.location.href
                        },
                        {headers: headers}
                    )
                    .then(function (response) {
                        alert("Liked")
                    }).catch(function (error) {
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
                    .post('/rgdweb/report/weblikes.html',
                        {
                            liked: false,
                            disliked: true,
                            webPage: window.location.href
                        },
                        {headers: headers}
                    )
                    .then(function (response) {
                        alert("Disliked")
                    }).catch(function (error) {
                    console.log(error)
                })
                hideButtons();
                openForm();

            }
        }
    })
}