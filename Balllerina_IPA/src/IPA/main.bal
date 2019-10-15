import ballerina/http;
import ballerina/log;

http:ClientConfiguration ipaConfig = {
    followRedirects: {enabled: true, maxCount: 5},
    secureSocket: {
        disable: true
    }
};

http:Client clientEndpoint = new ("https://ipa.ipa.lab/ipa", ipaConfig);

listener http:Listener httpListener = new (9090);

@http:ServiceConfig {
    basePath: "/api/v1"
}

service Kloc on httpListener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/user"
    }
    resource function CreateUser(http:Caller caller, http:Request req) {
        string sessionCookie = GetSessionCookie(caller);

        var result = caller->respond(<@untained>sessionCookie);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/user/{symbol}"
    }
    resource function DeleteUser(http:Caller caller, http:Request req, string symbol) {

        var result = caller->respond(<@untained> ("Kloc, World!" + symbol));

        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}

function sendErrorMsg(http:Caller caller, error err) {
    http:Response res = new;
    res.statusCode = 500;
    res.setPayload(<@untainted><string>err.detail()?.message);
    var result = caller->respond(res);
    handleError(result);
}

function handleError(error? result) {
    if (result is error) {
        log:printError(result.reason(), err = result);
    }
}


function GetSessionCookie(http:Caller caller) returns @tainted string {
    http:Request reqtaz = new;

    reqtaz.setTextPayload("user=admin&password=Passw0rd");

    reqtaz.setHeader("referer", "https://ipa.ipa.lab/ipa");
    reqtaz.setHeader("Content-Type", "application/x-www-form-urlencoded");
    reqtaz.setHeader("Accept", "text/plain");

    var response = clientEndpoint->post("/session/login_password", reqtaz);

    string sessionCookie = "";

    if (response is http:Response) {
        sessionCookie = response.getHeader("Set-Cookie");     
    }

    if (response is error) {
        sendErrorMsg(caller, response);
    }

    return sessionCookie;
}
