import ballerina/http;
import ballerina/log;
import ballerina/io;

http:ClientConfiguration ipaConfig = {
    followRedirects: { enabled: true, maxCount: 5 },
    secureSocket: {
        disable: true
    }
};

http:Client clientEndpoint = new("https://ipa.ipa.lab/ipa", ipaConfig);

@http:ServiceConfig {
    basePath: "/api/v1"
}

service Kloc on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/user"
    }
    resource function CreateUser(http:Caller caller, http:Request req) {
        
        http:Request reqtaz = new;

        reqtaz.setHeader("referer", "https://ipa.ipa.lab/ipa");
        reqtaz.setHeader("Content-Type", "application/x-www-form-urlencoded");
        reqtaz.setHeader("Accept", "text/plain");                  

        req.setTextPayload("user=admin&password=Passw0rd");   

        var response = clientEndpoint->post("/session/login_password", reqtaz);  

        if (response is http:Response) {
            io:println(response);           
            string sessionCookie = response.getHeader("Set-Cookie");
            io:println("Set-Cookie: " + sessionCookie);           

            var result = caller->respond(<@untained> response);
        }        

        if (response is error) {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<@untainted> <string> response.reason());
            var result = caller->respond(res);
        }
    }    

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/user/{symbol}"
    }
    resource function DeleteUser(http:Caller caller, http:Request req, string symbol) {

        var result = caller->respond("Kloc, World!"+ symbol);

        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}
