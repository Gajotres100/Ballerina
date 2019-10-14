import ballerina/http;
import ballerina/log;

@http:ServiceConfig {
    basePath: "/api/v1"
}

service Kloc on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/user"
    }
    resource function CreateUser(http:Caller caller, http:Request req) {

        var result = caller->respond("Hello, World!");

        if (result is error) {
            log:printError("Error sending response", result);
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
