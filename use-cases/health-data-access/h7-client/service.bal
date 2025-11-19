import ballerina/io;
import ballerina/log;
import ballerina/tcp;

// Define the ADT^A01 message (Patient Admission)
string message_a01 = string `MSH|^~\&|SIMHOSP|SFAC|RAPP|RFAC|2020-05-08T13:06:43||ADT^A01|5|T|2.3|||AL||44|ASCII
EVN|A01|2020-05-08T13:06:43|||2001^Wolf^Kathy^^^Dr^^^DRNBR
PID|1|2590157853^^^SIMULATOR MRN^MRN|2590157853^^^SIMULATOR MRN^MRN~2478684691^^^NHSNBR^NHSNMBR||Esterkin^AKI Scenario 6^^^Miss^^CURRENT||1989-01-18T00:00:00|F|||170 Juice Place^^London^^RW21 6KC^GBR^HOME||020 5368 1665^HOME|||||||||R
PD1|||FAMILY PRACTICE^^12345
PV1|1|I|RenalWard^MainRoom^Bed 1^Simulated Hospital^^BED^Main Building^5|28b|||2001^Wolf^Kathy^^Dr^^^DRNBR^PRSNL^^^ORGDR|||MED|||||||||6145914547062969032^^^^visitid||||||||||||||||||||||ARRIVED|||2020-05-08T13:06:43`;

    // Define the ADT^A06 message (Patient Update)
string message_a06 = string `MSH|^~\\&|SendingApp|SendingFac|ReceivingApp|ReceivingFac|20241013130000||ADT^A06|54321|P|2.3
EVN|A08|20241013130000
PID|1||5^^^Hospital^MR||Doe^John^A||1980-01-01|M|||789 Updated St^^Newtown^CA^54321|555-777-8888|||M
NK1|1|Doe^Jane|SPO|789 Secondary St^^Newtown^CA^54321|555-999-0000
PV1|1|I|W^389^1^UCLA|3|||1111^Jones^John^A^^Dr.||2222^Smith^Jane^B^^Dr.||SUR||||ADM|A0|`;

    // Define the ADT^A06 message (Patient Update)
string message_a39 = string `MSH|^~\\&|SendingApp|SendingFac|ReceivingApp|ReceivingFac|20241013130000||ADT^A06|54321|P|2.3
EVN|A08|20241013130000
PID|1||5^^^Hospital^MR||Doe^John^A||1980-01-01|M|||789 Updated St^^Newtown^CA^54321|555-777-8888|||M
NK1|1|Doe^Jane|SPO|789 Secondary St^^Newtown^CA^54321|555-999-0000
PV1|1|I|W^389^1^UCLA|3|||1111^Jones^John^A^^Dr.||2222^Smith^Jane^B^^Dr.||SUR||||ADM|A0|`;

configurable string serverAddress = "localhost"; 
configurable int serverPort = 9094;


public function main(string messageType) returns error? {

    log:printInfo(string`Starting HL7 message sender...+ ${messageType}. condition ${messageType == "ADT_A01"}`);

    // Create a TCP client
    tcp:Client tcpClient = check new (serverAddress, serverPort);

    if messageType == "ADT_A01" {

        log:printInfo("Sending ADT^A01 message...");
        
        check sendMessageAndReceiveResponse(tcpClient, message_a01);
    } else if messageType == "ADT_A06" {

        log:printInfo("Sending ADT^A06 message...");
        
        check sendMessageAndReceiveResponse(tcpClient, message_a06);
        
    } else if messageType == "ADT_A39" {
        log:printInfo("Sending ADT^A39 message...");
        check sendMessageAndReceiveResponse(tcpClient, message_a39);
    }

    // Close the TCP client connection
    check tcpClient->close();
    log:printInfo("TCP client connection closed.");
}

// Function to send a message and receive the response
function sendMessageAndReceiveResponse(tcp:Client tcpClient, string message) returns error? {
    // Send the message to the server
    check tcpClient->writeBytes(message.toBytes());
    log:printInfo("Message sent to the server.");

    // Read the response from the server
    byte[] response = check tcpClient->readBytes();
    string responseMessage = check string:fromBytes(response);
    io:println("Response from server: ", responseMessage);
}