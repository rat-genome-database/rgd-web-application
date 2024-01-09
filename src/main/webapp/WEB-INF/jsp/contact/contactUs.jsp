<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Contact Us";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.12/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<style>
    #emailMessage{
        height: 250px;
    }
    input[type="text"], input[type="number"] {
        width: 300px;
    }
    #submitMsg {
        font-size: large;
        color: blue;
    }
    /* Chrome, Safari, Edge, Opera
     hiding the arrows */
    input::-webkit-outer-spin-button,
    input::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    /* Firefox */
    input[type=number] {
        -moz-appearance: textfield;
    }
    #userEmail{
        width: 300px;
    }
    #contactH {
        position: absolute;
        left: 150px;
    }
    #formH {
        position: absolute;
        left: 150px
    }
    #submitBtn {
        font-size: x-large;
    }
    #resetBtn{
        font-size: x-large;
    }
    select{
        font-size: medium;
    }
    .contactTable td{
        font-size: medium;
    }
</style>
<body id="contactBody">
    <h1 id="contactH">Contact Us</h1>
    <br><br><br>
    <table width="70%" align="center" class="contactTable">
        <tbody>
        <tr>
            <td><dd id="submitMsg" value=""></dd></td>
        </tr>
        <tr>
            <td><dd>Your comments are very important to RGD. Please write to us or fill out the request form below (preferred),
                we will reply to you as soon as possible.</dd></td>
        </tr>
        <tr>
            <td><dd align="left"><b>Postal Address:</b></dd></td>
        </tr>
        <tr>
            <td>
                <dd>Rat Genome Database
                    <br>Medical College of Wisconsin
                    <br>8701 Watertown Plank Rd.
                    <br>Milwaukee, WI 53226</dd>
            </td>
        </tr>
    </table>
    <hr width="90%">
    <h2 id="formH">Request Form</h2>
    <br><br><br>
    <form id="contactVue">
        <table width="70%" align="center" class="contactTable">
            <tbody>
            <tr><td style="color: red">( * indicates a required field)</td></tr>
            <tr>
                <td>*First Name: </td><td><input type="text" v-model="firstName"></td>
            </tr>
            <tr>
                <td>*Last Name:</td><td><input type="text" v-model="lastName"></td>
            </tr>
            <tr>
                <td>*Email Address:</td><td><input type="text" id="userEmail" v-model="email"></td>
            </tr>
            <tr>
                <td>Phone Number:</td><td><input type="number" placeholder="1231231234" v-model="phone"></td>
            </tr>
            <tr>
                <td>Institute/Company:</td><td><input type="text" v-model="institute"></td>
            </tr>
            <tr>
                <td>Address:</td><td><input type="text" v-model="address"></td>
            </tr>
            <tr>
                <td>City:</td><td><input type="text" v-model="city"></td>
            </tr>
            <tr>
                <td>State:</td><td><select id="state" size="1" onchange="changeCountry()">
                <option value="N/A" selected>N/A - Not Applicable</option>
                <option value="AL - Alabama" >AL - Alabama</option>
                <option value="AK - Alaska" >AK - Alaska</option>
                <option value="AZ - Arizona" >AZ - Arizona</option>
                <option value="AR - Arkansas" >AR - Arkansas</option>
                <option value="CA - California" >CA - California</option>
                <option value="CO - Colorado" >CO - Colorado</option>
                <option value="CT - Connecticut" >CT - Connecticut</option>
                <option value="DE - Delaware" >DE - Delaware</option>
                <option value="DC - District of Columbia" >DC - District of Columbia</option>
                <option value="FL - Florida" >FL - Florida</option>
                <option value="GA - Georgia" >GA - Georgia</option>
                <option value="HI - Hawaii" >HI - Hawaii</option>
                <option value="ID - Idaho" >ID - Idaho</option>
                <option value="IL - Illinois" >IL - Illinois</option>
                <option value="IN - Indiana" >IN - Indiana</option>
                <option value="IA - Iowa" >IA - Iowa</option>
                <option value="KS - Kansas" >KS - Kansas</option>
                <option value="KY - Kentucky" >KY - Kentucky</option>
                <option value="LA - Louisiana" >LA - Louisiana</option>
                <option value="ME - Maine" >ME - Maine</option>
                <option value="MD - Maryland" >MD - Maryland</option>
                <option value="MA - Massachusetts" >MA - Massachusetts</option>
                <option value="MI - Michigan" >MI - Michigan</option>
                <option value="MN - Minnesota" >MN - Minnesota</option>
                <option value="MS - Mississippi" >MS - Mississippi</option>
                <option value="MO - Missouri" >MO - Missouri</option>
                <option value="MT - Montana" >MT - Montana</option>
                <option value="NE - Nebraska" >NE - Nebraska</option>
                <option value="NV - Nevada" >NV - Nevada</option>
                <option value="NH - New Hampshire" >NH - New Hampshire</option>
                <option value="NJ - New Jersey" >NJ - New Jersey</option>
                <option value="NM - New Mexico" >NM - New Mexico</option>
                <option value="NY - New York" >NY - New York</option>
                <option value="NC - North Carolina" >NC - North Carolina</option>
                <option value="ND - North Dakota" >ND - North Dakota</option>
                <option value="OH - Ohio" >OH - Ohio</option>
                <option value="OK - Oklahoma" >OK - Oklahoma</option>
                <option value="OR - Oregon" >OR - Oregon</option>
                <option value="PA - Pennsylvania" >PA - Pennsylvania</option>
                <option value="RI - Rhode Island" >RI - Rhode Island</option>
                <option value="SC - South Carolina" >SC - South Carolina</option>
                <option value="SD - South Dakota" >SD - South Dakota</option>
                <option value="TN - Tennessee" >TN - Tennessee</option>
                <option value="TX - Texas" >TX - Texas</option>
                <option value="UT - Utah" >UT - Utah</option>
                <option value="VT - Vermont" >VT - Vermont</option>
                <option value="VA - Virginia" >VA - Virginia</option>
                <option value="WA - Washington" >WA - Washington</option>
                <option value="WV - West Virginia" >WV - West Virginia</option>
                <option value="WI - Wisconsin" >WI - Wisconsin</option>
                <option value="WY - Wyoming" >WY - Wyoming</option>
            </select></td>
            </tr>
            <tr>
                <td>Zip Code:</td><td><input type="number" maxlength="10" v-model="zipCode"></td>
            </tr>
            <tr>
                <td>Country:</td><td><select id="country" name="country">
                <option value="Afganistan">Afghanistan</option>
                <option value="Albania">Albania</option>
                <option value="Algeria">Algeria</option>
                <option value="American Samoa">American Samoa</option>
                <option value="Andorra">Andorra</option>
                <option value="Angola">Angola</option>
                <option value="Anguilla">Anguilla</option>
                <option value="Antigua & Barbuda">Antigua & Barbuda</option>
                <option value="Argentina">Argentina</option>
                <option value="Armenia">Armenia</option>
                <option value="Aruba">Aruba</option>
                <option value="Australia">Australia</option>
                <option value="Austria">Austria</option>
                <option value="Azerbaijan">Azerbaijan</option>
                <option value="Bahamas">Bahamas</option>
                <option value="Bahrain">Bahrain</option>
                <option value="Bangladesh">Bangladesh</option>
                <option value="Barbados">Barbados</option>
                <option value="Belarus">Belarus</option>
                <option value="Belgium">Belgium</option>
                <option value="Belize">Belize</option>
                <option value="Benin">Benin</option>
                <option value="Bermuda">Bermuda</option>
                <option value="Bhutan">Bhutan</option>
                <option value="Bolivia">Bolivia</option>
                <option value="Bonaire">Bonaire</option>
                <option value="Bosnia & Herzegovina">Bosnia & Herzegovina</option>
                <option value="Botswana">Botswana</option>
                <option value="Brazil">Brazil</option>
                <option value="British Indian Ocean Ter">British Indian Ocean Ter</option>
                <option value="Brunei">Brunei</option>
                <option value="Bulgaria">Bulgaria</option>
                <option value="Burkina Faso">Burkina Faso</option>
                <option value="Burundi">Burundi</option>
                <option value="Cambodia">Cambodia</option>
                <option value="Cameroon">Cameroon</option>
                <option value="Canada">Canada</option>
                <option value="Canary Islands">Canary Islands</option>
                <option value="Cape Verde">Cape Verde</option>
                <option value="Cayman Islands">Cayman Islands</option>
                <option value="Central African Republic">Central African Republic</option>
                <option value="Chad">Chad</option>
                <option value="Channel Islands">Channel Islands</option>
                <option value="Chile">Chile</option>
                <option value="China">China</option>
                <option value="Christmas Island">Christmas Island</option>
                <option value="Cocos Island">Cocos Island</option>
                <option value="Colombia">Colombia</option>
                <option value="Comoros">Comoros</option>
                <option value="Congo">Congo</option>
                <option value="Cook Islands">Cook Islands</option>
                <option value="Costa Rica">Costa Rica</option>
                <option value="Cote DIvoire">Cote DIvoire</option>
                <option value="Croatia">Croatia</option>
                <option value="Cuba">Cuba</option>
                <option value="Curaco">Curacao</option>
                <option value="Cyprus">Cyprus</option>
                <option value="Czech Republic">Czech Republic</option>
                <option value="Denmark">Denmark</option>
                <option value="Djibouti">Djibouti</option>
                <option value="Dominica">Dominica</option>
                <option value="Dominican Republic">Dominican Republic</option>
                <option value="East Timor">East Timor</option>
                <option value="Ecuador">Ecuador</option>
                <option value="Egypt">Egypt</option>
                <option value="El Salvador">El Salvador</option>
                <option value="Equatorial Guinea">Equatorial Guinea</option>
                <option value="Eritrea">Eritrea</option>
                <option value="Estonia">Estonia</option>
                <option value="Ethiopia">Ethiopia</option>
                <option value="Falkland Islands">Falkland Islands</option>
                <option value="Faroe Islands">Faroe Islands</option>
                <option value="Fiji">Fiji</option>
                <option value="Finland">Finland</option>
                <option value="France">France</option>
                <option value="French Guiana">French Guiana</option>
                <option value="French Polynesia">French Polynesia</option>
                <option value="French Southern Ter">French Southern Ter</option>
                <option value="Gabon">Gabon</option>
                <option value="Gambia">Gambia</option>
                <option value="Georgia">Georgia</option>
                <option value="Germany">Germany</option>
                <option value="Ghana">Ghana</option>
                <option value="Gibraltar">Gibraltar</option>
                <option value="Great Britain">Great Britain</option>
                <option value="Greece">Greece</option>
                <option value="Greenland">Greenland</option>
                <option value="Grenada">Grenada</option>
                <option value="Guadeloupe">Guadeloupe</option>
                <option value="Guam">Guam</option>
                <option value="Guatemala">Guatemala</option>
                <option value="Guinea">Guinea</option>
                <option value="Guyana">Guyana</option>
                <option value="Haiti">Haiti</option>
                <option value="Hawaii">Hawaii</option>
                <option value="Honduras">Honduras</option>
                <option value="Hong Kong">Hong Kong</option>
                <option value="Hungary">Hungary</option>
                <option value="Iceland">Iceland</option>
                <option value="Indonesia">Indonesia</option>
                <option value="India">India</option>
                <option value="Iran">Iran</option>
                <option value="Iraq">Iraq</option>
                <option value="Ireland">Ireland</option>
                <option value="Isle of Man">Isle of Man</option>
                <option value="Israel">Israel</option>
                <option value="Italy">Italy</option>
                <option value="Jamaica">Jamaica</option>
                <option value="Japan">Japan</option>
                <option value="Jordan">Jordan</option>
                <option value="Kazakhstan">Kazakhstan</option>
                <option value="Kenya">Kenya</option>
                <option value="Kiribati">Kiribati</option>
                <option value="Korea North">Korea North</option>
                <option value="Korea Sout">Korea South</option>
                <option value="Kuwait">Kuwait</option>
                <option value="Kyrgyzstan">Kyrgyzstan</option>
                <option value="Laos">Laos</option>
                <option value="Latvia">Latvia</option>
                <option value="Lebanon">Lebanon</option>
                <option value="Lesotho">Lesotho</option>
                <option value="Liberia">Liberia</option>
                <option value="Libya">Libya</option>
                <option value="Liechtenstein">Liechtenstein</option>
                <option value="Lithuania">Lithuania</option>
                <option value="Luxembourg">Luxembourg</option>
                <option value="Macau">Macau</option>
                <option value="Macedonia">Macedonia</option>
                <option value="Madagascar">Madagascar</option>
                <option value="Malaysia">Malaysia</option>
                <option value="Malawi">Malawi</option>
                <option value="Maldives">Maldives</option>
                <option value="Mali">Mali</option>
                <option value="Malta">Malta</option>
                <option value="Marshall Islands">Marshall Islands</option>
                <option value="Martinique">Martinique</option>
                <option value="Mauritania">Mauritania</option>
                <option value="Mauritius">Mauritius</option>
                <option value="Mayotte">Mayotte</option>
                <option value="Mexico">Mexico</option>
                <option value="Midway Islands">Midway Islands</option>
                <option value="Moldova">Moldova</option>
                <option value="Monaco">Monaco</option>
                <option value="Mongolia">Mongolia</option>
                <option value="Montserrat">Montserrat</option>
                <option value="Morocco">Morocco</option>
                <option value="Mozambique">Mozambique</option>
                <option value="Myanmar">Myanmar</option>
                <option value="Nambia">Nambia</option>
                <option value="Nauru">Nauru</option>
                <option value="Nepal">Nepal</option>
                <option value="Netherland Antilles">Netherland Antilles</option>
                <option value="Netherlands">Netherlands (Holland, Europe)</option>
                <option value="Nevis">Nevis</option>
                <option value="New Caledonia">New Caledonia</option>
                <option value="New Zealand">New Zealand</option>
                <option value="Nicaragua">Nicaragua</option>
                <option value="Niger">Niger</option>
                <option value="Nigeria">Nigeria</option>
                <option value="Niue">Niue</option>
                <option value="Norfolk Island">Norfolk Island</option>
                <option value="Norway">Norway</option>
                <option value="Oman">Oman</option>
                <option value="Pakistan">Pakistan</option>
                <option value="Palau Island">Palau Island</option>
                <option value="Palestine">Palestine</option>
                <option value="Panama">Panama</option>
                <option value="Papua New Guinea">Papua New Guinea</option>
                <option value="Paraguay">Paraguay</option>
                <option value="Peru">Peru</option>
                <option value="Phillipines">Philippines</option>
                <option value="Pitcairn Island">Pitcairn Island</option>
                <option value="Poland">Poland</option>
                <option value="Portugal">Portugal</option>
                <option value="Puerto Rico">Puerto Rico</option>
                <option value="Qatar">Qatar</option>
                <option value="Republic of Montenegro">Republic of Montenegro</option>
                <option value="Republic of Serbia">Republic of Serbia</option>
                <option value="Reunion">Reunion</option>
                <option value="Romania">Romania</option>
                <option value="Russia">Russia</option>
                <option value="Rwanda">Rwanda</option>
                <option value="St Barthelemy">St Barthelemy</option>
                <option value="St Eustatius">St Eustatius</option>
                <option value="St Helena">St Helena</option>
                <option value="St Kitts-Nevis">St Kitts-Nevis</option>
                <option value="St Lucia">St Lucia</option>
                <option value="St Maarten">St Maarten</option>
                <option value="St Pierre & Miquelon">St Pierre & Miquelon</option>
                <option value="St Vincent & Grenadines">St Vincent & Grenadines</option>
                <option value="Saipan">Saipan</option>
                <option value="Samoa">Samoa</option>
                <option value="Samoa American">Samoa American</option>
                <option value="San Marino">San Marino</option>
                <option value="Sao Tome & Principe">Sao Tome & Principe</option>
                <option value="Saudi Arabia">Saudi Arabia</option>
                <option value="Senegal">Senegal</option>
                <option value="Seychelles">Seychelles</option>
                <option value="Sierra Leone">Sierra Leone</option>
                <option value="Singapore">Singapore</option>
                <option value="Slovakia">Slovakia</option>
                <option value="Slovenia">Slovenia</option>
                <option value="Solomon Islands">Solomon Islands</option>
                <option value="Somalia">Somalia</option>
                <option value="South Africa">South Africa</option>
                <option value="Spain">Spain</option>
                <option value="Sri Lanka">Sri Lanka</option>
                <option value="Sudan">Sudan</option>
                <option value="Suriname">Suriname</option>
                <option value="Swaziland">Swaziland</option>
                <option value="Sweden">Sweden</option>
                <option value="Switzerland">Switzerland</option>
                <option value="Syria">Syria</option>
                <option value="Tahiti">Tahiti</option>
                <option value="Taiwan">Taiwan</option>
                <option value="Tajikistan">Tajikistan</option>
                <option value="Tanzania">Tanzania</option>
                <option value="Thailand">Thailand</option>
                <option value="Togo">Togo</option>
                <option value="Tokelau">Tokelau</option>
                <option value="Tonga">Tonga</option>
                <option value="Trinidad & Tobago">Trinidad & Tobago</option>
                <option value="Tunisia">Tunisia</option>
                <option value="Turkey">Turkey</option>
                <option value="Turkmenistan">Turkmenistan</option>
                <option value="Turks & Caicos Is">Turks & Caicos Is</option>
                <option value="Tuvalu">Tuvalu</option>
                <option value="Uganda">Uganda</option>
                <option value="United Kingdom">United Kingdom</option>
                <option value="Ukraine">Ukraine</option>
                <option value="United Arab Erimates">United Arab Emirates</option>
                <option value="United States of America" selected>United States of America</option>
                <option value="Uraguay">Uruguay</option>
                <option value="Uzbekistan">Uzbekistan</option>
                <option value="Vanuatu">Vanuatu</option>
                <option value="Vatican City State">Vatican City State</option>
                <option value="Venezuela">Venezuela</option>
                <option value="Vietnam">Vietnam</option>
                <option value="Virgin Islands (Brit)">Virgin Islands (Brit)</option>
                <option value="Virgin Islands (USA)">Virgin Islands (USA)</option>
                <option value="Wake Island">Wake Island</option>
                <option value="Wallis & Futana Is">Wallis & Futana Is</option>
                <option value="Yemen">Yemen</option>
                <option value="Zaire">Zaire</option>
                <option value="Zambia">Zambia</option>
                <option value="Zimbabwe">Zimbabwe</option>
            </select></td>
            </tr>
            <tr>
                <td>*Message:</td>
            </tr>
            <tr>
                <td colspan="2"><textarea rows="20" cols="160" id="emailMessage" v-model="message" ></textarea></td>
            </tr>
            <tr><td><div class="g-recaptcha" data-sitekey="6LfhLo0aAAAAAImgKJ2NesbBS0Vx1PB4KrFh9ygY" data-callback="enableBtn" data-expired-callback="expired"></div></td></tr>
            <tr>
                <td>
                    <button type="button" id="submitBtn" v-on:click="sendEmail" disabled="disabled">Submit</button></td>
                <td><button type="button" id="resetBtn" v-on:click="resetForm">Reset</button></td>
            </tr>
            <tr>

            </tr>
        </table>

    </form>
</body>

<%@ include file="/common/footerarea.jsp"%>

<script>
    var contactVue = new Vue({
        el: '#contactVue',
        data: {
            message: '',
            subject: 'User Request From RGD',
            firstName: '',
            lastName: '',
            email: '',
            phone: '',
            address: '',
            institute: '',
            city: '',
            zipCode: ''
        },
        methods: {
            sendEmail: function () {
                if(this.firstName === '' || !this.firstName || this.lastName === '' || !this.lastName){
                    alert("Please provide a First Name and Last Name.")
                    return;
                }
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
                // alert(this.message + "\n" +this.subject+ "\n"+ this.firstName +"\n"+this.lastName+"\n"+this.email
                //     +"\n"+this.phone+"\n"+this.address+"\n"+this.institute+"\n"+this.city+"\n"+this.zipCode);
                axios
                    .post('/rgdweb/contact/contactus.html',
                        {
                            message: contactVue.message,
                            subject: contactVue.subject,
                            firstName: contactVue.firstName,
                            lastName: contactVue.lastName,
                            email: contactVue.email,
                            phone: contactVue.phone,
                            address: contactVue.address,
                            institute: contactVue.institute,
                            city: contactVue.city,
                            zipCode: contactVue.zipCode,
                            country: document.getElementById("country").value,
                            state: document.getElementById("state").value
                        })
                    .then(function (response) {
                        submitted()
                        // alert("Thank you for the message! We will try and get back to you as soon as possible.");
                    }).catch(function (error) {
                    console.log(error)
                })
            },
            resetForm: function (){
                this.firstName = '';
                this.lastName = '';
                this.email = '';
                this.phone= '';
                this.institute = '';
                this.address = '';
                this.city = '';
                document.getElementById("state").value = "N/A";
                this.zipCode = '';
                document.getElementById("country").value = "United States of America";
                document.getElementById("country").disabled = false;
                this.subject = '';
                this.message = '';
                grecaptcha.reset();
                expired();
            }
        }
    })
    function emailValidate(message) {
        var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(message);
    }
    function enableBtn(){
        document.getElementById("submitBtn").disabled = false;
    }
    function expired(){
        document.getElementById("submitBtn").disabled = true;
    }
    function submitted() {
        contactVue.resetForm();
        window.scrollTo(0,0);
        document.getElementById("submitMsg").innerText = "Thank you for the message! We will respond to you as soon as possible.";
    }
    function changeCountry() {
        if(document.getElementById("state").value !== "N/A")
        {
            document.getElementById("country").value = "United States of America";
            document.getElementById("country").disabled = true;
        }
        else {
            document.getElementById("country").disabled = false;
        }
    }
</script>
