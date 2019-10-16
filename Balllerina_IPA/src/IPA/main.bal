import ballerina/http;
import ballerina/log;
import ballerina/io;

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
        boolean status = GroupAdd(caller, sessionCookie);
        var result = caller->respond(<@untained>status);
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

function GroupAdd(http:Caller caller, string cookie) returns @tainted boolean {   

    boolean resoult = false;
    http:Request reqtaz = new;

    json jsonData = {
        "id": 0,
        "method": "group_add",
        "params": [
        [
        "Klocna"
        ],
        {
            "all": true,
            "description": "Gajo je gospodin",
            "external": false, 
            "no_members": false, 
            "nonposix": false, 
            "raw": false, 
            "version": "2.114"
        }
        ]
    };    

    reqtaz.setJsonPayload(jsonData);

    reqtaz.setHeader("referer", "https://ipa.ipa.lab/ipa");
    reqtaz.setHeader("Content-Type", "application/json");
    reqtaz.setHeader("Accept", "application/json");
    reqtaz.setHeader("Cookie", cookie);    

    var response = clientEndpoint->post("/json", reqtaz);

    if (response is error) {        
        io:println(response);
        sendErrorMsg(caller, response);
        return false;
    }

    if (response is http:Response) {
        io:println(response.statusCode);     
        resoult = true;
    }

    return resoult;
}
