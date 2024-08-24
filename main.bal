import ballerina/http;
import ballerina/time;
import ballerinax/mysql;

type User record {|

    readonly int id;
    string name;
    time:Date birthday;
    string mobileNumber;
    
|};

table<User> key(id) users = table[
    {id: 1, name: "Joe", birthday: {year: 1990, month: 2, day: 3}, mobileNumber: "0771234567"},
    {id: 2, name: "vipun", birthday: {year: 2000, month: 7, day: 10}, mobileNumber: "0771234567"}
];

type ErrorDetails record {
    string message;
    string details;
    time:Utc timestamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

type NewUser record {|
    string name;
    time:Date birthday;
    string mobileNumber;  
|};


mysql:Client dbClient = check new mysql:Client("localhost", "ballerina", "root", "", 3306);




service /social\-media on new http:Listener(9090) {
    resource function get users() returns User[] | error {

        return users.toArray();
    }

    resource function get user/[int id]() returns User | UserNotFound | error {
        User? user = users[id];
        if user is () {
            UserNotFound notFound = {
                body: {message: string `id: ${id}`, details:string `user/${id}` , timestamp: time:utcNow()}
            };
            return notFound;
        }
        return user;
       
    }

    resource function post user(NewUser newUser) returns http:Created | error {
        users.add({id: users.length() + 1, ...newUser});
        return http:CREATED;
    }
}
