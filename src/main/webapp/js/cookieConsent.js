// Cookie Consent Management using localStorage
(function() {
    // Check if localStorage is available
    function hasLocalStorage() {
        try {
            var test = '__localStorage_test__';
            localStorage.setItem(test, test);
            localStorage.removeItem(test);
            return true;
        } catch(e) {
            return false;
        }
    }

    // Get consent preference from localStorage
    function getConsentPreference() {
        if (hasLocalStorage()) {
            return localStorage.getItem('rgd_cookie_consent');
        }
        // Fallback to cookies if localStorage is not available
        var value = "; " + document.cookie;
        var parts = value.split("; rgd_cookie_consent=");
        if (parts.length === 2) return parts.pop().split(";").shift();
        return null;
    }

    // Set consent preference with optional expiration
    function setConsentPreference(value, daysToExpire) {
        if (hasLocalStorage()) {
            var data = {
                value: value,
                timestamp: new Date().getTime()
            };
            if (daysToExpire) {
                data.expiry = new Date().getTime() + (daysToExpire * 24 * 60 * 60 * 1000);
            }
            localStorage.setItem('rgd_cookie_consent', JSON.stringify(data));
        } else {
            // Fallback to cookies if localStorage is not available
            var expires = "";
            if (daysToExpire) {
                var date = new Date();
                date.setTime(date.getTime() + (daysToExpire * 24 * 60 * 60 * 1000));
                expires = "; expires=" + date.toUTCString();
            }
            document.cookie = "rgd_cookie_consent=" + (value || "") + expires + "; path=/";
        }
    }

    // Check if consent has expired
    function isConsentValid() {
        if (hasLocalStorage()) {
            var storedData = localStorage.getItem('rgd_cookie_consent');
            if (!storedData) return false;

            try {
                var data = JSON.parse(storedData);
                if (data.expiry && new Date().getTime() > data.expiry) {
                    localStorage.removeItem('rgd_cookie_consent');
                    return false;
                }
                return data.value;
            } catch(e) {
                return false;
            }
        }
        // Fallback to checking cookies
        return getConsentPreference();
    }

    // Initialize cookie consent
    function initCookieConsent() {
        // Check if consent was already given and is still valid
        var consent = isConsentValid();
        if (consent === 'accepted') {
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
                    <a href="/rgdweb/common/privacy-policy.jsp" target="_blank">Privacy Policy</a>.</p>
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
            setConsentPreference('accepted', 365); // Store for 1 year
            hideCookieNotice();
        });

        // Handle decline button
        document.getElementById('declineCookies').addEventListener('click', function() {
            setConsentPreference('declined', 30); // Store for 30 days
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