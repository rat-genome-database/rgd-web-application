// Cookie Consent Management
(function() {
    // Check if user has already accepted cookies
    function getCookie(name) {
        var value = "; " + document.cookie;
        var parts = value.split("; " + name + "=");
        if (parts.length === 2) return parts.pop().split(";").shift();
    }

    // Set cookie with expiration
    function setCookie(name, value, days) {
        var expires = "";
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "") + expires + "; path=/";
    }

    // Initialize cookie consent
    function initCookieConsent() {
        // Check if consent was already given
        if (getCookie('rgd_cookie_consent') === 'accepted') {
            return;
        }

        // Create cookie notice element
        var cookieNotice = document.createElement('div');
        cookieNotice.id = 'cookieNotice';
        cookieNotice.className = 'cookie-notice';
        cookieNotice.innerHTML = `
            <div class="cookie-notice-content">
                <div class="cookie-notice-text">
                    <p>This website uses cookies to enhance your browsing experience, analyze site traffic, and personalize content.
                    By continuing to use this site, you consent to our use of cookies in accordance with our
                    <a href="/wg/home/disclaimer" target="_blank">Privacy Policy</a>.</p>
                </div>
                <div class="cookie-notice-buttons">
                    <button id="acceptCookies" class="cookie-button cookie-button-accept">Accept</button>
                    <button id="declineCookies" class="cookie-button cookie-button-decline">Decline</button>
                </div>
            </div>
        `;

        // Add cookie notice to page
        document.body.appendChild(cookieNotice);

        // Show the notice with animation
        setTimeout(function() {
            cookieNotice.classList.add('show');
        }, 100);

        // Handle accept button
        document.getElementById('acceptCookies').addEventListener('click', function() {
            setCookie('rgd_cookie_consent', 'accepted', 365); // Store for 1 year
            hideCookieNotice();
        });

        // Handle decline button
        document.getElementById('declineCookies').addEventListener('click', function() {
            setCookie('rgd_cookie_consent', 'declined', 30); // Store for 30 days
            hideCookieNotice();
            // Optionally disable certain features that require cookies
            disableOptionalCookies();
        });
    }

    // Hide cookie notice with animation
    function hideCookieNotice() {
        var notice = document.getElementById('cookieNotice');
        if (notice) {
            notice.classList.remove('show');
            setTimeout(function() {
                notice.remove();
            }, 500);
        }
    }

    // Disable optional cookies if user declines
    function disableOptionalCookies() {
        // Add any logic here to disable analytics or other optional cookie-based features
        console.log('User declined cookies - optional features disabled');
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initCookieConsent);
    } else {
        initCookieConsent();
    }
})();