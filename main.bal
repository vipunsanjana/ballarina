import ballerina/http;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;


type User record {|

    readonly int id;
    string name;
    @sql:Column {name:"birth_day"}
    time:Date birthday;

     @sql:Column {name:"mobile_number"}
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



// mysql:Client dbClient = check new("localhost", "social_media_database", "social_media_user", "dummypassword", 3306);



mysql:Client dbClient = check new ("localhost", "social_media_user", "dummypassword", 
                              "social_media_database", 3306);



service /social\-media on new http:Listener(9090) {

    


    resource function get users() returns User[] | error {

        stream<User, sql:Error?> result = dbClient->query(`SELECT * FROM users`);
        return from var user  in result select user;
    }

    resource function get user/[int id]() returns User | UserNotFound | error {
        User|sql:Error user = dbClient->queryRow(`SELECT * FROM users WHERE id = ${id}`);
        if user is sql:NoRowsError {
            UserNotFound notFound = {
                body: {message: string `id: ${id}`, details:string `user/${id}` , timestamp: time:utcNow()}
            };
            return notFound;
        }
        return user;
       
    }

    resource function post user(NewUser newUser) returns http:Created | error {
        _= check dbClient->execute(`INSERT INTO users (name, birth_day, mobile_number) VALUES (${newUser.name}, ${newUser.birthday}, ${newUser.mobileNumber})`);
        return http:CREATED;
    }
}
