package edu.mcw.rgd.web;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import javax.net.ssl.HttpsURLConnection;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class VerifyRecaptcha {

    public static final String url = "https://www.google.com/recaptcha/api/siteverify";
    public static final String secret = "6LccGxITAAAAAJX2iBk8KRasYWU_gwsQNhvTcVNe";
    private final static String USER_AGENT = "Mozilla/5.0";

    public static boolean verify(String gRecaptchaResponse) throws IOException {
        if (gRecaptchaResponse == null || gRecaptchaResponse.isEmpty()) {
            System.err.println("[recaptcha] verify=false reason=empty-token");
            return false;
        }

        HttpsURLConnection con = null;
        try {
            URL obj = new URL(url);
            con = (HttpsURLConnection) obj.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("User-Agent", USER_AGENT);
            con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            con.setConnectTimeout(10_000);
            con.setReadTimeout(10_000);

            String postParams = "secret=" + URLEncoder.encode(secret, StandardCharsets.UTF_8)
                    + "&response=" + URLEncoder.encode(gRecaptchaResponse, StandardCharsets.UTF_8);

            con.setDoOutput(true);
            try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
                wr.writeBytes(postParams);
                wr.flush();
            }

            int responseCode = con.getResponseCode();
            InputStream is = (responseCode >= 200 && responseCode < 300)
                    ? con.getInputStream() : con.getErrorStream();
            StringBuilder body = new StringBuilder();
            if (is != null) {
                try (BufferedReader in = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = in.readLine()) != null) body.append(line);
                }
            }
            String bodyStr = body.toString();

            if (responseCode < 200 || responseCode >= 300) {
                System.err.println("[recaptcha] verify=false reason=http-" + responseCode
                        + " body=" + bodyStr + " tokenTail=" + tail(gRecaptchaResponse));
                return false;
            }

            JsonObject jobj = JsonParser.parseString(bodyStr).getAsJsonObject();
            JsonElement successEl = jobj.get("success");
            boolean success = successEl != null && !successEl.isJsonNull() && successEl.getAsBoolean();
            if (!success) {
                JsonElement errs = jobj.get("error-codes");
                System.err.println("[recaptcha] verify=false reason=google-rejected"
                        + " errorCodes=" + (errs == null ? "none" : errs.toString())
                        + " body=" + bodyStr
                        + " tokenTail=" + tail(gRecaptchaResponse));
            }
            return success;
        } catch (Exception e) {
            System.err.println("[recaptcha] verify=false reason=exception message=" + e.getMessage()
                    + " tokenTail=" + tail(gRecaptchaResponse));
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try { con.disconnect(); } catch (Exception ignored) {}
            }
        }
    }

    private static String tail(String token) {
        if (token == null) return "null";
        int n = token.length();
        return n <= 12 ? "***" : "***" + token.substring(n - 12);
    }
}
