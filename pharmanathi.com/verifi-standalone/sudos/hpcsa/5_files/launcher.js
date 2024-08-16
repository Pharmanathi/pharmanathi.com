
if (!window.LL_Deployment)
    var LL_Deployment = { };
LL_Deployment.rawURL = null;
LL_Deployment.version = "20200817";
LL_Deployment.release = "RELY";
LL_Deployment.getRelease = function () {
        return LL_Deployment.release.replace('.', '').toLowerCase();
};

    LL_Deployment.debugLevel = 100;
 
LL_Deployment.siteCode = "SC68723121:LLMS:1";
LL_Deployment.launchPoint = {
	    type: 1,
        
	        delayTimer: 0,
	        stealthMode: false,
	        stealthUrls: [],
        
        elementId: ""
};
LL_Deployment.containers = {
    global: "https://public.cobrowse.oraclecloud.com",
    private: "https://sc68723121llms1.cobrowse.oraclecloud.com"
};

/*Require https for QA 180524-000008*/
LL_Deployment.scriptServerPath = "https://www.livelook.com"; //for aspx files
LL_Deployment.dataServerPath = "https://public.cobrowse.oraclecloud.com" + "/" + LL_Deployment.getRelease(); //for storage interface

LL_Deployment.icbConfig = {
    
        icbMode: true,
        hostEngineURL: undefined
    
};
LL_Deployment.acbConfig = {
    
        restrictionGroup: "NONE",
        acbUrls: [],
        Mac_ACB_OS_Versions: "10.9+",
        
        acbMacMode: true,
        
        acbNetMode: true,
        
        acbWinMode: true,
        
        acbMode: true
    
};
LL_Deployment.UI = {
    type: undefined,
    defaultLanguage: "1033",
    language: undefined, 
    customizedUI: {}, //from the DB
    mapLangToLCID: function (lang) { 
        var mapping = {"1026":[2,"bg","bg-bg","bgr","bul"],"1028":[30724,3076,31748,4,4100,5124,"chs","cht","zh","zh-chs","zh-cht","zhh","zh-hans","zh-hant","zh-hk","zhi","zhm","zh-mo","zho","zh-sg","zh-tw"],"1029":[5,"ces","cs","cs-cz","csy"],"1030":[6,"da","da-dk","dan"],"1031":[2055,3079,4103,5127,7,"de","dea","de-at","dec","de-ch","de-de","del","de-li","de-lu","des","deu"],"1032":[8,"el","el-gr","ell"],"1033":[10249,11273,12297,13321,15369,16393,17417,18441,3081,4105,5129,6153,7177,8201,9,9225,"en","en-029","ena","en-au","enb","en-bz","enc","en-ca","ene","eng","enh","en-hk","eni","en-ie","en-in","enj","en-jm","enl","enm","en-my","enn","en-nz","enp","en-ph","ens","en-sg","ent","en-tt","enu","en-us","enw","enz","en-za","en-zw"],"1035":[11,"fi","fi-fi","fin"],"1036":[10252,11276,12,12300,13324,14348,15372,2060,4108,5132,6156,8204,9228,"fr","fra","frb","fr-be","fr-cd","fr-ch","fr-ci","fr-cm","frd","fre","frf","fr-fr","frh","fr-ht","fri","frl","fr-lu","frm","fr-ma","fr-mc","fr-ml","frn","fro","frr","fr-re","frs","fr-sn"],"1038":[14,"hu","hu-hu","hun"],"1040":[16,2064,"it","ita","it-ch","it-it","its"],"1041":[17,"ja","ja-jp","jpn"],"1042":[18,"ko","ko-kr","kor"],"1043":[19,2067,"nl","nlb","nl-be","nld","nl-nl"],"1044":[20,2068,31764,"nb","nb-no","nn","nn-no","nno","no","nob","non","nor"],"1045":[21,"pl","plk","pl-pl","pol"],"1046":[2070,22,"por","pt","ptb","pt-br","ptg","pt-pt"],"1048":[2072,24,"ro","rod","rom","ro-md","ron","ro-ro"],"1049":[25,"ru","ru-ru","rus"],"1050":[26,4122,"hr","hrb","hr-ba","hr-hr","hrv"],"1051":[27,"sk","sk-sk","sky","slk"],"1053":[2077,29,"sv","sve","svf","sv-fi","sv-se","swe"],"1054":[30,"th","tha","th-th"],"1055":[31,"tr","trk","tr-tr","tur"],"1058":[34,"uk","ukr","uk-ua"],"1060":[36,"sl","sl-si","slv"],"1061":[37,"est","et","et-ee","eti"],"1062":[38,"lav","lv","lvi","lv-lv"],"1063":[39,"lit","lt","lth","lt-lt"],"2052":[30724,3076,31748,4,4100,5124,"chs","cht","zh","zh-chs","zh-cht","zh-cn","zhh","zh-hans","zh-hant","zh-hk","zhi","zhm","zh-mo","zho","zh-sg"],"2057":[10249,11273,12297,13321,15369,16393,17417,18441,3081,4105,5129,6153,7177,8201,9,9225,"en","en-029","ena","en-au","enb","en-bz","enc","en-ca","ene","eng","en-gb","enh","en-hk","eni","en-ie","en-in","enj","en-jm","enl","enm","en-my","enn","en-nz","enp","en-ph","ens","en-sg","ent","en-tt","enu","enw","enz","en-za","en-zw"],"2074":[10266,11290,12314,28698,31770,6170,7194,9242,"sr","srb","sr-cyrl-ba","sr-cyrl-me","sr-cyrl-rs","srl","sr-latn","sr-latn-ba","sr-latn-cs","sr-latn-me","sr-latn-rs","srm","srn","sro","srp","srq","srs"],"3082":[10,10250,11274,12298,13322,14346,15370,16394,17418,18442,19466,20490,2058,21514,22538,4106,5130,6154,7178,8202,9226,"es","es-419","esa","es-ar","esb","es-bo","esc","es-cl","es-co","es-cr","esd","es-do","ese","es-ec","es-es","esf","esg","es-gt","esh","es-hn","esi","esj","esl","esm","es-mx","esn","es-ni","eso","esp","es-pa","es-pe","es-pr","es-py","esr","ess","es-sv","est","esu","es-us","es-uy","esv","es-ve","esy","esz","spa"],"3084":[10252,11276,12,12300,13324,14348,15372,2060,4108,5132,6156,8204,9228,"fr","fra","frb","fr-be","frc","fr-ca","fr-cd","fr-ch","fr-ci","fr-cm","frd","fre","frf","frh","fr-ht","fri","frl","fr-lu","frm","fr-ma","fr-mc","fr-ml","frn","fro","frr","fr-re","frs","fr-sn"],"3098":[10266,11290,12314,27674,31770,6170,7194,9242,"sr","srb","sr-cyrl","sr-cyrl-ba","sr-cyrl-cs","sr-cyrl-me","sr-cyrl-rs","sr-latn-ba","sr-latn-me","sr-latn-rs","srm","srn","sro","srp","srq","srs"]};
        if (lang && lang.toString().length < 256) {
            lang = lang.toString().toLowerCase().trim();
            for (var key in mapping) {
                if (!mapping.hasOwnProperty(key))
                    continue;
                else if (key === lang) 
                    return key;
                for (var i = 0; i< mapping[key].length; i++) {
                    var id = mapping[key][i].toString();
                    if (id === lang)
                        return key;
                }
            }
            if (lang.indexOf("-") !== -1) {
                var truncatedLang = lang.substr(0, lang.lastIndexOf("-"));
                return LL_Deployment.UI.mapLangToLCID(truncatedLang); //RFC 4647 section 3.4
            }
        }
        return LL_Deployment.UI.defaultLanguage;
    },
    getUIPath: function (LCID) {
        var lang = LCID ? LCID : LL_Deployment.UI.language,
            isCustom = typeof (LL_Deployment.UI.customizedUI[lang]) !== "undefined"
            path = isCustom ? LL_Deployment.containers.private : LL_Deployment.containers.global + "/";
            
        if(typeof(LCID) !== "undefined"){
            
                path += (isCustom) ? "/ui/" + LCID + ".js" : LL_Deployment.getRelease() + "/client/ui/default/" + LCID + ".js";
            
        }
        else
            path = path.replace("/webinterfaces/icb", "");
        return path;
    }
};

LL_Deployment.init = function () {
    if (window.Cobrowse && Cobrowse.API){ return; }

    LL_Session.currentState.change(LL_Session.states.INIT);
    
    LL_Deployment.UI.type = LL_Deployment.launchPoint.type;
    var requestedLang, requestedVersion,
        currentScript = document ? document.currentScript : null,
        launcherURL = currentScript ? currentScript.src : null,
        scriptTags = launcherURL ? [] : document.getElementsByTagName('script');

    if (launcherURL && launcherURL.indexOf("launcher") === -1) {
        launcherURL = null;
        scriptTags = document.getElementsByTagName('script');
    }

    if (!launcherURL) {
        for (var i = 0; i < scriptTags.length; i++) {
            if (scriptTags[i].src && scriptTags[i].src.toLowerCase().indexOf('/launcher.') != -1) {
                launcherURL = scriptTags[i].src;
                break;
            }
        }
    }
    LL_Deployment.rawURL = !launcherURL ? null : (launcherURL.indexOf("?") < 0) ? launcherURL : launcherURL.slice(0,  launcherURL.indexOf("?"));

    if (launcherURL) {
        var vars = {}, hash, hashes = launcherURL.slice(launcherURL.indexOf('?') + 1).split('&');
        for (var i = 0; i < hashes.length; i++) {
            hash = hashes[i].split('=');
            vars[hash[0].toLowerCase()] = hash[1];
        }

        if (vars.lang)
            requestedLang = LL_Deployment.UI.mapLangToLCID(vars.lang);

        if (vars.version)
            requestedVersion = vars.version;
    }

    if (!requestedLang)
        requestedLang = LL_Deployment.UI.defaultLanguage;

    if (LL_Deployment.UI.language !== requestedLang)
        LL_Deployment.UI.language = requestedLang;

    if (requestedVersion && requestedVersion.toUpperCase() === "EDGE")
        LL_Deployment.release = requestedVersion;

    var startCobrowseLauncher = function () {
        //start global launcher when launcher module is loaded
        var launcher_loaded = window.LL_Cobrowse_Launcher;
        if (launcher_loaded)
            LL_Cobrowse_Launcher.init(true);
    };

    var globalLauncherPath = "https://public.cobrowse.oraclecloud.com/%RELEASE%/global_launcher.js".replace("%RELEASE%", LL_Deployment.getRelease());

    LL_Utils.require("LL_Cobrowse_Launcher", globalLauncherPath, startCobrowseLauncher,
        function (message) { if (window.console && console.error) console.error("Cobrowse launcher failed to load: ", message); });

    if (!window.LL_CustomUI || LL_CustomUI.language != requestedLang) {
        window["LL_CustomUI_" + LL_Deployment.UI.defaultLanguage] = LL_CustomUI;
        LL_CustomUI = undefined;
        var UI_path = LL_Deployment.UI.getUIPath(requestedLang);
        LL_Utils.require("LL_CustomUI", UI_path, null,
            function (message) { if (window.console && console.error) console.error("Cobrowse launcher failed to load: ", message); });
    }
}

try {
    LL_customFunctions = null;
}
catch (ex) {}

if (window.LL_CustomUI && (LL_CustomUI.siteCode !== LL_Deployment.siteCode || LL_CustomUI.language !== "1033"))
    LL_CustomUI = undefined;
LL_CustomUI = window.LL_CustomUI || {"activateText":"Expert would like to activate Advanced Co Browsing","activateWindowOK":"OK","partialSupportedText":"You are using a browser that is not yet fully supported. Some features may not work well, but you are welcome to have a look around.","partialSupported_font_family":"Trebuchet MS","partialSupported_font_size":"14","partialSupported_background_color":"2f2f2f","partialSupported_width":"280","partialSupported_height":"177","partialSupported_text_color":"c8c5d1","syncIsLostText":"The customer closed the session, or navigated to a page which does not support co browse. When the customer returns, co browse will resume.","syncIsLostText_font_family":"Trebuchet MS","syncIsLostText_font_size":"14","syncIsLostText_background_color":"2f2f2f","syncIsLostText_width":"280","syncIsLostText_height":"177","syncIsLostText_color":"c8c5d1","takingOutsideText":"The page you are opening will not be visible to the agent.","clickHereText":"Click here to open it in a new browser window.","V4LLPanel_redirect_popup_font_family":"Trebuchet MS","V4LLPanel_redirect_popup_width":"280","V4LLPanel_redirect_popup_height":"120","V4LLPanel_redirect_popup_background":"2f2f2f","V4LLPanel_redirect_popup_text_color":"c8c5d1","V4LLPanel_redirect_popup_text_font_size":"12","greeting":"<p><strong>Need Help?</strong></p><p>You're just a few steps away from enjoying a new experience that lets our experts browse the site with you to better assist and guide you.</p>","altGreeting":"&nbsp;","startButton":"Start","privacyHeader":"Your privacy is important to us","privacyText":"Co-browse is a secure service governed by our <a target=\"_blank\" href=\"\">Privacy Policy.</a>","leaveFeedback":"Please leave feedback","getInstantHelp":"Get Instant Help!","v3PleaseWait":"Please wait...","v3ToolTip":"","v3toProceedClickButton":"<center>To proceed click the button below.</center>","v3PassCodeGenerated":"Passcode generated.","v3SessionIsOver":"Session ended","v3ServersBusy":"<span style='text-size:12px;font-weight:bold'>All servers are busy.</span>","v3TryLater":"<span style='text-size:12px;font-weight:normal;text-align:left;'>Service is temporarily unavailable. Please try again later. Thank you for your patience.</span>","v3SessionTimedOut":"Your session timed out.","v3CloseWindowNotice":"You can now close this window","v3CodeInstructions":"After you provide the code to company Expert click the button below.","v3ReturnToWebsiteButton":"Return to Website","v3ProceedButton":"Activate session","v3InstantHelp":"Instant Help","v3AgentsOffline":"Agents are not available to assist at this time. Please call during the office hours listed below.","v3Unavailable":"We apologize for the inconvenience, but this service is unavailable at the moment.","v3ClientProgressBar_hint_0":"Establishing secure connection...","v3ClientProgressBar_hint_1":"Do not close this window.","v3ClientProgressBar_hint_2":"Do not close this window. It will minimize automatically.","v3ClientProgressBar_hint_3":"Expert connected","v3ClientProgressBar_hint_4":"Please minimize this window but do not close it.","v3SessionCouldNotBeStarted":"Session could not be started.","v3SessionCouldNotBeActivated":"Session could not be activated.","v3SessionEndedOldJava":"<span style='font-size:18px;line-height:24px;font-weight:normal;'>This session is unable to connect. Co-browsing requires an up-to-date Java environment. Please consider updating your Java to <a href='https://www.java.com/' target='_blank'>the most recent version</a> in order to co-browse.</span>","v3CallExpert":"","v3ProvidePassCode":"","v3GeneratingPassCode":"Generating passcode","v3ClickRun":"Click <b>Run</b> or <b>Yes</b> if prompted.","v3AgentConnecting":"<b>Agent is connecting... please do not close this window.</b>","v3EstablishingConnection":"<b>Establishing secure connection.</b><br /> Please do not close this window.","v3CertAccepted":"Agent will see your page momentarily... please do not close this window. <br /><br />This window will automatically minimize when the agent is connected.","v3MinimizeNow":"Minimize now","v3CertRejected_1":"Important!\\n\\nPlease accept the Java certificate.\\n\\nIt verifies the identity of the service provider, and gives others permission to view your screen.\\n\\nNo software will be installed onto your computer.","v3CertRejected_2":"Since you rejected Java Certificates, Visual Sharing is now disabled.\\n\\nTo enable it please close all browser windows and start over.","V3FirefoxPluginIcon_text_part1":"If you see a","V3FirefoxPluginIcon_text_part2":"&nbsp;icon, click it to activate the Java plugin","v3ChromeTip":"If you see <strong>\"Run this time\"</strong> or <strong>\"Always run on this site\"</strong> button above, click it.","V3Activating_text":"Activating...","v3Chrome37TooltipTextFirstPart":"If you see <strong>\"Plug-in blocked\"</strong> ","v3Chrome37TooltipTextSecondPart":"icon, click it, select <strong>\"Always allow\"</strong> and press <strong>\"Done\"</strong>","CDelay_text":"To activate advanced Co Browsing, please accept the <em>security certificate</em> by clicking <span>\"Run\"</span>.","CDelay_redisplay_certificate":"Redisplay security certificate","CDelay_terminate_1":"To terminate this session&nbsp;","CDelay_terminate_2":"click here","reactive_headerBranding":"Browse the website with an Expert","reactive_buttonLabel":"Initiate","reactive_pageTitle":"Get Instant Help!","ht_waitingAgent":"Waiting for agent to connect","ht_agentCanSeeScreen":"Agent can now see your screen","ht_endSessionMessage":"Are you sure you want to end this session?","activateText_font_family":"Tahoma","activateText_font_size":"23","activateText_color":"000000","activateACBButton_width":"159","activateACBButton_font_family":"Tahoma","activateACBButton_font_size":"23","activateACBButton_color":"000000","activateACBButton_text_hover":"ffffff","V4LLPanel_CollapsedNarrowNoAgent_width":"157","V4LLPanel_CollapsedNarrowNoAgent_height":"36","V4LLPanel_CollapsedNarrowNoAgent_right":"16","V4LLPanel_CollapsedNarrowNoAgent_bottom":"0","ADA_compliance":"true","V4LLPanel_CollapsedNumContNarrow_font_family":"Tahoma","V4LLPanel_CollapsedNumContNarrow_font_size":"14","V4LLPanel_CollapsedNumContNarrow_color":"a2a2a2","V4LLPanel_HintBlock_width":"157","V4LLPanel_HintBlock_height":"78","V4LLPanel_HintBlock_right":"16","V4LLPanel_HintBlock_FirstLineText":"Browse together","V4LLPanel_HintBlock_FirstLineText_font_family":"Trebuchet MS","V4LLPanel_HintBlock_FirstLineText_font_size":"14","V4LLPanel_HintBlock_FirstLineText_font_weight":"bold","V4LLPanel_HintBlock_FirstLineText_font_style":"normal","V4LLPanel_HintBlock_FirstLineText_color":"343434","V4LLPanel_HintBlock_SecondLineText":"with our experts online","V4LLPanel_HintBlock_SecondLineText_font_family":"Trebuchet MS","V4LLPanel_HintBlock_SecondLineText_font_size":"10","V4LLPanel_HintBlock_SecondLineText_font_weight":"normal","V4LLPanel_HintBlock_SecondLineText_font_style":"normal","V4LLPanel_HintBlock_SecondLineText_color":"343434","V4LLPanel_InnerTitle_font_family":"Tahoma","V4LLPanel_InnerTitle_font_size":"14","V4LLPanel_InnerTitle_color":"ffffff","V4LLPanel_width":"284","V4LLPanel_PanelClose_right":"6","V4LLPanel_TogglerText_font_family":"Tahoma","V4LLPanel_TogglerText_font_size":"14","V4LLPanel_TogglerText_color":"ffffff","V4LLPanel_passToBeginText_color":"a2a2a2","V4LLPanel_passToBeginText_font_size":"14","V4LLPanel_PhoneNumber_font_family":"Trebuchet MS","V4LLPanel_PhoneNumber_digits_font_family":"Trebuchet MS","V4LLPanel_phoneNum_font_size":"16","V4LLPanel_provideCodeMessage_color":"a2a2a2","V4LLPanel_provideCodeMessage_font_size":"14","V4LLPanel_provideCodeMessage_font_family":"Trebuchet MS","V4LLPanel_NumberBox_background_color":"414141","V4LLPanel_NumberBox_color":"ffffff","V4LLPanel_NumberBox_font_size":"24","V4LLPanel_NumberBox_font_family":"Trebuchet MS","V4LLPanel_TermsAndConditions_font_size":"10","V4LLPanel_TermsAndConditions_color":"a2a2a2","V4LLPanel_TermsAndConditions_font_family":"Trebuchet MS","V4LLPanel_PoweredBy_color":"a2a2a2","V4LLPanel_PoweredBy_font_family":"Trebuchet MS","V4LLPanel_PoweredBy_font_size":"10","V4LLPanel_notconnected_header_text":"Co-browse","V4LLPanel_notconnected_provideNumber_text":"Secure Session ID Number","V4LLPanel_notconnected_callUsAt_text":"","V4LLPanel_notconnected_phoneNumber":"","V4LLPanel_notconnected_poweredBy_text":"powered by Oracle Co-browsing","V4LLPanel_notconnected_termsAndConditions_text":"","V4LLPanel_position":"bottom_right","V4LLPanel_position_offset":"16","V4LLPanel_header_height":"39","V4LLPanel_header_logo_right_gap":"7","V4LLPanel_header_text":"Co-browse","V4LLPanel_header_text_color":"ffffff","V4LLPanel_header_text_font_family":"Tahoma","V4LLPanel_header_text_font_size":"14","V4LLPanel_header_text_font_weight":"normal","V4LLPanel_header_text_font_style":"normal","V4LLPanel_header_number_color":"a2a2a2","V4LLPanel_header_number_font_family":"Tahoma","V4LLPanel_header_number_font_size":"14","V4LLPanel_Connected_content_height":"74","V4LLPanel_Connected_content_text":"Expert connected","V4LLPanel_Connected_content_text_color":"a6a6a6","V4LLPanel_Connected_content_text_font_family":"Trebuchet MS","V4LLPanel_Connected_content_text_font_size":"20","V4LLPanel_Connected_content_text_font_weight":"normal","V4LLPanel_Connected_content_text_font_style":"normal","V4LLPanel_Connected_disconnect_height":"57","V4LLPanel_Connected_disconnect_button_text":"Disconnect","V4LLPanel_Connected_disconnect_button_text_color":"fefefe","V4LLPanel_Connected_disconnect_button_text_hover_color":"ffffff","V4LLPanel_Connected_disconnect_button_text_font_family":"Trebuchet MS","V4LLPanel_Connected_disconnect_button_text_font_size":"14","V4LLPanel_Connected_disconnect_button_text_font_weight":"normal","V4LLPanel_Connected_disconnect_button_text_font_style":"normal","V4LLPanel_Connected_footer_height":"32","V4LLPanel_Connected_footer_text":"powered by Oracle Co-browsing","V4LLPanel_Connected_footer_text_color":"a2a2a2","V4LLPanel_Connected_footer_text_font_family":"Trebuchet MS","V4LLPanel_Connected_footer_text_font_size":"10","V4LLPanel_Connected_footer_text_font_weight":"normal","V4LLPanel_Connected_footer_text_font_style":"normal","V4LLPanel_Connected_collapsed_height":"33","V4LLPanel_notSupported_width":"285","V4LLPanel_notSupported_height":"47","V4LLPanel_notSupported_right":"16","V4LLPanel_notSupported_header_text":"Co-browse","V4LLPanel_Title_notSupported_font_family":"Tahoma","V4LLPanel_Title_notSupported_font_size":"14","V4LLPanel_Title_notSupported_color":"ffffff","V4LLPanel_HintBlock_notSupported_width":"157","V4LLPanel_HintBlock_notSupported_height":"78","V4LLPanel_HintBlock_notSupported_right":"16","V4LLPanel_GenericToggler_notSupported_width":"157","V4LLPanel_notSupported_text":"Your browser does not support Co-browsing option. Expert will be happy to assist you over the phone.","V4LLPanel_notSupportedEnvText_notSupported_font_family":"Trebuchet MS","V4LLPanel_notSupportedEnvText_notSupported_font_size":"10","V4LLPanel_notSupportedEnvText_notSupported_color":"a2a2a2","V4LLPanel_notSupported_moreInfoText":"More info","V4LLPanel_moreInfoLink_notSupported_font_family":"Trebuchet MS","V4LLPanel_moreInfoLink_notSupported_font_size":"10","V4LLPanel_moreInfoLink_notSupported_color":"68769d","V4LLPanel_termsAndConditionsWindow_font_family":"Tahoma","V4LLPanel_termsAndConditionsWindow_color":"a2a2a2","V4LLPanel_termsAndConditionsWindow_font_size":"12","V4LLPanel_termsAndConditionsWindow_startSessionButton_color":"fefefe","V4LLPanel_termsAndConditionsWindow_startSessionButton_font_size":"12","V4LLPanel_termsAndConditionsWindow_startSessionButton_font_family":"Verdana","V4LLPanel_termsAndConditionsWindow_startSessionButton_text":"Start Session Now","V4LLPanel_TermsAndConditionsWindowHeadline_font_family":"Tahoma","V4LLPanel_TermsAndConditionsWindowHeadline_color":"ffffff","V4LLPanel_TermsAndConditionsWindowHeadline_font_size":"14","V4LLPanel_TermsAndConditionsWindowScrollBar_TrackBG_color":"545454","V4LLPanel_TermsAndConditionsWindowScrollBar_DragBG_color":"6f6f6f","V4LLPanel_TermsAndConditionsWindowHeadline":"","V4LLPanel_TermsAndConditionsWindowText":"","V4LLPanel_WaitingWindowBackgroundColor":"2f2f2f","V4LLPanel_WaitingWindowHeadlineText":"Co-Browse","V4LLPanel_WaitingWindowHeadlineTextFontFamily":"Tahoma","V4LLPanel_WaitingWindowHeadlineTextFontSize":"12","V4LLPanel_WaitingWindowHeadlineTextFontColor":"ffffff","V4LLPanel_WaitingWindowBodyTextFontFamily":"Trebuchet MS","V4LLPanel_WaitingWindowBodyTextFontColor":"e9e9e9","V4LLPanel_WaitingWindowBodyTextFontSize":"14","V4LLPanel_WaitingWindowBodyText":"Client is navigating to a new page","V4LLPanel_DisconnectConfirmWindow_background_color":"2f2f2f","V4LLPanel_DisconnectConfirmWindow_border_color":"aeaeae","V4LLPanel_DisconnectConfirmWindow_text_font_size":"14","V4LLPanel_DisconnectConfirmWindow_text_color":"fffefe","V4LLPanel_DisconnectConfirmWindow_text_font_weight":"normal","V4LLPanel_DisconnectConfirmWindow_text_font_style":"normal","V4LLPanel_DisconnectConfirmWindow_text_font_family":"Trebuchet MS","V4LLPanel_DisconnectConfirmWindow_text":"Are you sure you want to terminate this session?","V4LLPanel_DisconnectConfirmWindow_text_no":"No","V4LLPanel_DisconnectConfirmWindow_text_yes":"Yes","V4LLPanel_CloseConfirmButton_text_color":"ffffff","V4LLPanel_CloseConfirmButton_hover_text_color":"ffffff","V4LLPanel_CloseConfirmButton_text_font_family":"Trebuchet MS","V4LLPanel_CloseConfirmButton_text_font_size":"18","V4LLPanel_CloseConfirmButton_text_font_weight":"normal","V4LLPanel_CloseConfirmButton_text_font_style":"normal","V4LLPanel_CloseConfirmButton_text":"Are you sure you want to terminate this session?","V4LLPanel_CloseConfirmButton_text_no":"No","V4LLPanel_CloseConfirmButton_text_yes":"Yes","closeSessionEndWindowLink_text":"Close","ADA_V4LLPanel_PanelClose":"Collapse Browse with Specialist widget","ADA_V4LLPanel_CollapsedNumContNarrow":"Expand Browse with Specialist widget","ADA_V4LLPanel_PanelMinimize":"Collapse Browse with Specialist widget","ADA_V4LLPanel_PanelClose_disconnect":"Disconnect session for browse with specialist","ADA_V4LLPanel_CloseDeclineButton":"Decline session end","ADA_V4LLPanel_CloseConfirmButton":"Confirm session end","ADA_V4LLPanel_DisconnectConfirmWindow_infoEnd":"End of informational layer","ADA_V4LLPanel_DisconnectTrigger":"Disconnect session for browse with specialist","ADA_V4LLPanel_notconnected_poweredBy_modalEnd":"End of Modal Layer","ADA_V4LLPanel_CollapsedNumContNarrow_connected":"Expert connected","ADA_V4LLPanel_PanelClose_close":"Close","ADA_V4LLPanel_CloseDeclineButtonTC":"Decline session end","ADA_V4LLPanel_CloseConfirmButtonTC":"Confirm session end","ADA_V4LLPanel_modalEnd":"End of modal dialog","ADA_V4LLPanel_closeSessionEndWindowLink":"Close Session Ended dialog","LL_sessionEnded_popup_font_family":"Trebuchet MS","LL_sessionEnded_popup_font_size":"12","LL_sessionEnded_title_font_family":"Trebuchet MS","LL_sessionEnded_title_font_size":"34","LL_sessionEnded_description_font_family":"Trebuchet MS","LL_sessionEnded_description_font_size":"22","LL_sessionEnded_Close_Modal_Window_button_font_family":"Trebuchet MS","LL_sessionEnded_Close_Modal_Window_button_font_size":"14","LL_sessionEnded_feedback_font_family":"Trebuchet MS","LL_sessionEnded_feedback_font_size":"14","LL_sessionEnded_window_title":"Session ended","LL_sessionEnded_window_text":"You can now close this window","LL_sessionEnded_window_leave_feedback_text":"Please leave feedback","TrueView_Button":"True View","TrueView_InfoTitle":"True View Mode","TrueView_InfoDes":"Adapt your view to actual client screen size","TrueView_State_on":"ON","TrueView_State_off":"OFF","FullScreen_Button":"Full Screen","FullScreen_InfoTitle":"Full Screen Mode","FullScreen_InfoDes":"Expand the view to see the page in full screen","RC_ViewOnly":"Secure page: view only mode","RC_ViewPointer":"Secure page: view pointer mode","v4_activated_text":"Activated","LL_sessionEnded_popup_background_color":"ffffff","LL_sessionEnded_title_font_color":"da0000","LL_sessionEnded_description_font_color":"464646","LL_sessionEnded_Close_Modal_Window_button_width":"61","LL_CloseModal_Link_buttom_color":"ffffff","LL_Feedback_Button_color":"838383","partialSupported_PanelClose_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelClose.png","partialSupported_separator":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelSepLine.png","syncIsLostText_PanelClose_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelClose.png","syncIsLostText_separator":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelSepLine.png","V4LLPanel_redirect_popup_cancel_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelClose.png","V4LLPanel_redirect_popup_separator":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelSepLine.png","activateACBButton_image":"/framework/RELY/resources/images/activateButton_gray.png","activateACBButton_image_hover":"/framework/RELY/resources/images/activateButton_red.png","V4LLPanel_CollapsedNarrowNoAgent_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelToggler.png","V4LLPanel_InnerLogo_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelLogo.png","V4LLPanel_HintBlock_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelhoverTooltipBg.png","V4LLPanel_notConnected_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelBG.png","V4LLPanel_PanelClose_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelMinimizeBottom.png","LLpassToBeginText_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelSepLine.png","V4LLPanel_PhoneNumber_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelphoneIcon.png","V4LLPanel_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelBG.png","V4LLPanel_separator":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelSepLine.png","V4LLPanel_header_logo":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelLogo.png","V4LLPanel_header_close_image":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelMinimizeBottom.png","V4LLPanel_Connected_disconnect_button":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelDisconnectButton.png","V4LLPanel_Connected_disconnect_button_hover":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelDisconnectButton_hover.png","V4LLPanel_Connected_disconnect_button_pressed":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelDisconnectButton_hover.png","V4LLPanel_Connected_collapsed_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelButtonCollapsedGlow.png","V4LLPanel_notSupported_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelBG.png","V4LLPanel_notSupported_logo":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelLogo.png","V4LLPanel_PanelClose_notSupported_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelMinimizeBottom.png","V4LLPanel_HintBlock_notSupported_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelhoverTooltipBg.png","V4LLPanel_GenericToggler_notSupported_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelToggler.png","V4LLPanel_termsAndConditionsWindow_textShadow":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelBackgroundGradient.png","V4LLPanel_termsAndConditionsWindow_startSessionButton":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelStartSessionNowGray.png","V4LLPanel_termsAndConditionsWindow_startSessionButtonHover":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelStartSessionNow.jpg","V4LLPanel_WaitingWindowSeparator":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelSepLine.png","V4LLPanel_WaitingWindowLogo":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelLogo.png","V4LLPanel_WaitingWindowClose":"/framework/RELY/resources/images/V4LLPanel/waiting_popup_close_button.png","V4LLPanel_WaitingWindowPreloader":"/framework/RELY/resources/images/V4LLPanel/wait.gif","V4LLPanel_PanelMinimizeButton_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelMinimize.png","V4LLPanel_PanelCloseButton_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelCloseButton.png","V4LLPanel_CloseConfirmButton_background":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelDisconnectButton.png","V4LLPanel_CloseConfirmButton_background_hover":"/framework/RELY/resources/images/V4LLPanel/V4LLPanelDisconnectButton_hover.png","LL_sessionEnded_popup_close_button":"/framework/RELY/resources/images/V4LLPanel/session_ended_close_button.png","LL_sessionEnded_popup_cancel_button":"/framework/RELY/resources/images/V4LLPanel/closeicon.png","LL_sessionEnded_popup_image":"/framework/RELY/resources/images/V4LLPanel/stopwatch.png","RemoteControlImage":"/RELY/client/ui/default/images/rcdialog.jpg","FAQURL":"/framework/faq/faq.aspx","PrivacyURL":"","V4LLPanel_FAQURL":"","V4LLPanel_PhoneNumberURL":"","V4LLPanel_MoreInfo":"","ToolbarParameters":"default","ui_numpopup_okButtonVisible":"no","T_ButNo":"No","T_ButYes":"Yes","T_Ok":"OK","T_exit_confirm_text":"Are you sure you want to end this session?","ht_cobrowseTitle":"Co Browse toolbar","T_ButDisconnect":"Disconnect","T_ButStayConnected":"Stay Connected","ht_giveNumberToAgent":"Give this number to Agent","ht_tt_text":"The toolbar will inform you when you're connected & give you the ability to disconnect at any time.","RemoteControlWindowText":"Agent requests remote control of your shared content. Allow?","RemoteControlWindowConfirmButtonText":"Yes","RemoteControlWindowDeclineButtonText":"No","RemoteControlButton_font_size":"13","RemoteControlWindowText_font_size":"12"};
if (LL_CustomUI) {
    LL_CustomUI.siteCode = LL_Deployment.siteCode;
    LL_CustomUI.isTermsAndConditionsEnabled = !!LL_CustomUI.V4LLPanel_TermsAndConditionsWindowText;
    LL_CustomUI.language = "1033";
}
//inline prototypes 
//moved to pageManipulation.js
//service functions
window.LL_Utils=window.LL_Utils||{$:function(e){return"string"==typeof e?document.getElementById(e):e},removeNodes:function(e){for(var t="string"==typeof e?e.split(","):[e],n=0;n<t.length;n++){var i="string"==typeof t[n]?t[n].replace(/\s/g,""):t[n];if(i){var o=LL_Utils.$(i);o&&o.parentNode&&o.parentNode.removeChild(o)}}},loadScript:function(e,t,n,i,o){LL_Utils.removeNodes(e);var s=document.getElementsByTagName("head")[0],r=document.createElement("script");r.setAttribute("type","text/javascript"),r.setAttribute("id",e),r.setAttribute("loaded","false"),r.src=t,r.onload=r.onreadystatechange=function(){"false"!==this.getAttribute("loaded")||this.readyState&&"loaded"!==this.readyState&&"complete"!==this.readyState||(this.setAttribute("loaded","true"),
// Handle memory leak in IE
this.onload=this.onreadystatechange=this.onerror=null,
//LL_Utils.removeNodes(this);
"undefined"!=typeof LL_Session&&"undefined"!=typeof LL_Session.browser&&LL_Session.browser.isIE()&&!LL_Session.browser.WebSocket?(LL_Session.removeNodesCounter||(LL_Session.removeNodesCounter=0),LL_Session.removeNodesCounter++,LL_Session.removeNodesCounter>50&&LL_Utils.removeNodes(this)):LL_Utils.removeNodes(this),n&&n.apply(this,[]))},r.onerror=function(e,t,n){i||"false"===this.getAttribute("loaded")&&(this.setAttribute("loaded","true"),
// Handle memory leak in IE
this.onload=this.onreadystatechange=this.onerror=null,"undefined"!=typeof LL_Session&&"undefined"!=typeof LL_Session.browser&&LL_Session.browser.isIE()&&!LL_Session.browser.WebSocket?(LL_Session.removeNodesCounter||(LL_Session.removeNodesCounter=0),LL_Session.removeNodesCounter++,LL_Session.removeNodesCounter>50&&LL_Utils.removeNodes(this)):LL_Utils.removeNodes(this),o&&o.apply(this,[]))},s.appendChild(r),i&&function(e,t,n,o,s){setTimeout(function(){if(LL_Utils.$(e)){/*still not loaded, retry*/
var i="&rnd=",r=t.indexOf(i);-1!==r&&(t=t.substring(0,r-1)),t+=i+Math.random(),LL_Utils.loadScript(e,t,n,o,s)}},i)}(e,t,n,i,o)},require:function(e,t,n,i){var o=e,s=e?e.split("."):e;if(s&&2===s.length&&(o=s[0]),o in window&&"undefined"!=typeof window[o]){var r=!0;if(s&&2===s.length&&(r=s[1]in window[o]&&"undefined"!=typeof window[o][s[1]]),r)return void(n&&n.apply(this,[!0]))}return t?(LL_Utils.loadScript("id_"+e,t,function(){
//script is loaded - our object should exist by now
o=e,s=e?e.split("."):e,2===s.length&&(o=s[0]),o in window&&"undefined"!=typeof window[o]&&(!s||2!==s.length||s[1]in window[o]&&"undefined"!=typeof window[o][s[1]])||(LL_Utils.intervals.clear(e),i&&i.apply(this,["ERR_INV_CONTENT: "+t+" did not resolve "+e]))},void 0,function(){LL_Utils.intervals.clear(e),i&&i.apply(this,["ERR_LOAD_ERROR: "+t])}),void function(e,t,n,i){LL_Utils.___internals.require_internal(e,t,n,i)}(e,t,n,i)):void(i&&i.apply(this,["ERR_NO_FILE"]))},timers:{get:function(e){return LL_Utils.___internals.timerCollection[e]},set:function(e,t,n){LL_Utils.timers.clear(e),LL_Utils.___internals.timerCollection[e]=setTimeout(t,n)},clear:function(e){LL_Utils.___internals.timerCollection[e]&&(clearTimeout(LL_Utils.___internals.timerCollection[e]),LL_Utils.___internals.timerCollection[e]=0,delete LL_Utils.___internals.timerCollection[e])}},intervals:{get:function(e){return LL_Utils.___internals.intervalCollection[e]},set:function(e,t,n){LL_Utils.intervals.clear(e),LL_Utils.___internals.intervalCollection[e]=setInterval(t,n)},clear:function(e){LL_Utils.___internals.intervalCollection[e]&&(clearInterval(LL_Utils.___internals.intervalCollection[e]),LL_Utils.___internals.intervalCollection[e]=0,delete LL_Utils.___internals.intervalCollection[e])}},___internals:{timerCollection:{},intervalCollection:{},require_internal:function(e,t,n,i){var o=0;LL_Utils.intervals.set(e,function(){var s=e,r=e?e.split("."):e;if(r&&2===r.length&&(s=r[0]),s in window&&"undefined"!=typeof window[s]){var l=!0;if(r&&2===r.length&&(l=r[1]in window[s]&&"undefined"!=typeof window[s][r[1]]),l)return LL_Utils.intervals.clear(e),void(n&&n.apply(this,[!1]))}o++,o>144&&(LL_Utils.intervals.clear(e),navigator.onLine===!1&&i&&i.apply(this,["ERR_OFFLINE: "+t]),
//try loading the file again
LL_Utils.require(e,t,function(){n&&n.apply(this,[!1])},i))},333)}}},window.LL_Session=window.LL_Session||{states:{INIT:1,READY:2,STARTING:3,ACTIVE:5,DISCONNECTING:6,ERROR:7},currentState:{get:function(){return LL_Session.currentState.___internals.stateID},change:function(e){if(LL_Session.currentState.___internals.stateID!==e){LL_Session.currentState.___internals.stateID=e;for(var t=LL_Session.currentState.___internals.listeners,n=0;n<t.length;n++)t[n]&&function(e,t){setTimeout(function(){e.apply(this,[t])},0)}(t[n],e)}},listen:function(e){var t=LL_Session.currentState.___internals.listeners;try{-1===t.indexOf(e)&&t.push(e)}catch(n){for(var i=-1,o=0;o<t.length;o++)if(t[o]===e){i=o;break}-1===i&&t.push(e)}},removeListener:function(e){for(var t=LL_Session.currentState.___internals.listeners,n=t.length-1;n>=0;n--)t[n]===e&&delete t[n]},___internals:{stateID:void 0,listeners:[]}},mode:null,presentationCode:null,presentationToken:null,SID:null,mode:null,___internals:{}},window.Cobrowse=window.Cobrowse||{__callbacks__:[],__rejects__:[],ready:function(e){if(void 0===e||"function"!=typeof e){if("Promise"in window){// browser supports Promise            
var t=function(e,t){void 0!==e&&Cobrowse.__callbacks__.push(e),void 0!==t&&Cobrowse.__rejects__.push(t)},n=new Promise(t);return n}throw"Please provide a callback"}// Callback is provided
void 0===Cobrowse.__callbacks__&&(Cobrowse.__callbacks__=[]),Cobrowse.__callbacks__.push(e)}};

LL_Deployment.init();

