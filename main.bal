import ballerina/http;
import ballerina/time;

type User record {|

    int id;
    string name;
    time:Date birthday;
    string mobileNumber;
    
|};

service /social\-media on new http:Listener(9090) {
    resource function get users() returns User[] | error {
        User joe = {id: 1, name: "Joe", birthday: {year: 1990, month: 2, day: 3}, mobileNumber: "0771234567"};
        User vipun = {id: 2, name: "vipun", birthday: {year: 2000, month: 7, day: 10}, mobileNumber: "0771234567"};

        User[] users = [joe, vipun];
        return users;
    }
}
