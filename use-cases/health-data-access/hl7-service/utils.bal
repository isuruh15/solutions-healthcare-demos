
// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com).

// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerina/time;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.international401;
import ballerinax/health.hl7v2;
import ballerinax/health.hl7v23;
import ballerinax/health.hl7v24;
import ballerina/log;
import ballerina/uuid;
import ballerinax/health.fhir.r4.parser as r4parser;
import ballerinax/health.hl7v25;
import ballerinax/health.hl7v26;
import ballerinax/health.hl7v27;
import ballerinax/health.hl7v28;
import ballerinax/health.hl7v2.utils.v2tofhirr4;

// Function to map a FHIR Patient resource to HL7v2
// public isolated function mapFhirPatientToHL7(
//         international401:Patient fhirPatient,
//         string sendingApp,
//         string sendingFacility,
//         string receivingApp,
//         string receivingFacility,
//         string messageControlId) returns byte[]|error {
//     // Transforming the FHIR Patient resource to HL7v2
//     hl7v24:RSP_K21 queryResult = check transform(fhirPatient, sendingApp, sendingFacility, receivingApp, receivingFacility, messageControlId);
//     // Encoding the HL7 message
//     byte[] encodedMsg = check hl7v2:encode(hl7v24:VERSION, queryResult);
//     return encodedMsg;
// }

// isolated function transform(international401:Patient fhirPatient,
//         string sendingApp,
//         string sendingFacility,
//         string receivingApp,
//         string receivingFacility,
//         string messageControlId) returns hl7v24:RSP_K21|error =>
        
//         let
//         r4:HumanName[] name = check fhirPatient.name.ensureType(),
//         string familyName = check name[0].family.ensureType(),
//         string givenName = string:'join(" ", ...check name[0].given.ensureType()),
//         string gender = fhirPatient.gender.toString() == "male" ? "M" : "F",
//         string messageDateTime = getCurrentTimestamp()
//     in {
//         msh: {
//             msh2: "^~\\&",
//             msh3: {
//                 hd1: sendingApp
//             },
//             msh4: {
//                 hd1: sendingFacility
//             },
//             msh5: {
//                 hd1: receivingApp
//             },
//             msh6: {
//                 hd1: receivingFacility
//             },
//             msh7: {
//                 ts1: messageDateTime
//             },
//             msh9: {
//                 msg1: "RSP^K21"
//             },
//             msh10: messageControlId,
//             msh11: {
//                 pt1: "P"
//             },
//             msh12: {
//                 vid1: "2.4"
//             }
//         },
//         qpd: {
//             qpd1: {
//                 ce1: "IHE PDQ Query"
//             },
//             qpd2: messageControlId
//         },
//         msa: {
//             msa1: "AA",
//             msa2: messageControlId
//         },
//         qak: {
//             qak1: "12345",
//             qak2: "OK"
//         },
//         query_response: [
//             {
//                 pid: {
//                     pid1: "1",
//                     pid3: [
//                         {
//                             cx1: <string>fhirPatient.id,
//                             cx4: {
//                                 hd1: "Hospital",
//                                 hd2: "MR"
//                             }
//                         }
//                     ],
//                     pid5: [
//                         {
//                             xpn1: {fn1: familyName},
//                             xpn2: givenName
//                         }
//                     ],
//                     pid7: {
//                         ts1: fhirPatient.birthDate.toString()
//                     },
//                     pid8: gender
//                 }
//             }
//         ]
//     };

public isolated function getCurrentTimestamp() returns string {
    time:Utc currentTime = time:utcNow();
    return formatTimestamp(currentTime);
}

isolated function formatTimestamp(time:Utc timestamp) returns string {
    // Convert the UTC timestamp to a time:Civil record (this includes both date and time fields)
    time:Civil civil = time:utcToCivil(timestamp);

    // Extract the year, month, day, and time components
    string year = civil.year.toString();
    string month = civil.month < 10 ? "0" + civil.month.toString() : civil.month.toString();
    string day = civil.day < 10 ? "0" + civil.day.toString() : civil.day.toString();

    // Extract the time of day (hours, minutes, seconds)
    string hour = civil.hour < 10 ? "0" + civil.hour.toString() : civil.hour.toString();
    string minute = civil.minute < 10 ? "0" + civil.minute.toString() : civil.minute.toString();
    string second = <int>civil.second < 10 ? "0" : (<int>civil.second).toString();

    // Return the formatted timestamp as "YYYYMMDDHHMMSS"
    return year + month + day + hour + minute + second;
}

public isolated function loadConcreteMessageTypes(hl7v2:Message message) returns hl7v23:ADT_A01? {

    // This reference implementation is for an ADT_A01 message of hl7v2 version 2.3
    log:printDebug(string `Received ADT_A01 message: ${message.toString()}`);
    hl7v23:ADT_A01 parsedMessage;
    if message is hl7v23:ADT_A01 {
        parsedMessage = <hl7v23:ADT_A01>message;
        return parsedMessage;
    } else if message is hl7v24:ADT_A01 {
        hl7v24:ADT_A01 v24ParsedMessage = <hl7v24:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v24ParsedMessage.toString()}`);

    } else if message is hl7v25:ADT_A01 {
        hl7v25:ADT_A01 v25ParsedMessage = <hl7v25:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v25ParsedMessage.toString()}`);

    } else if message is hl7v26:ADT_A01 {
        hl7v26:ADT_A01 v25ParsedMessage = <hl7v26:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v25ParsedMessage.toString()}`);

    } else if message is hl7v27:ADT_A01 {
        hl7v27:ADT_A01 v25ParsedMessage = <hl7v27:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v25ParsedMessage.toString()}`);

    } else if message is hl7v28:ADT_A01 {
        hl7v28:ADT_A01 v25ParsedMessage = <hl7v28:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v25ParsedMessage.toString()}`);

    } else {
        log:printError(string `Received message is not an ADT_A01 message: ${message.toString()}`);
    }
    return;
}

public isolated function generateAckMessage(hl7v2:Message message) returns byte[]|error {

    hl7v2:Message? ack = ();
    string? hl7Version = ();

    if message is hl7v23:ADT_A01 || message is hl7v23:ADT_A39 {

        hl7v23:MSH? msh = ();
        if message is hl7v2:Message && message.hasKey("msh") {
            anydata mshEntry = message["msh"];
            hl7v23:MSH|error tempMSH = mshEntry.ensureType();
            if tempMSH is error {
                log:printError(string `Error occurred while casting MSH: ${tempMSH.message()}`);
                return error("Error occurred while casting MSH", tempMSH);
            }
            msh = tempMSH;
        }
        if msh is () {
            log:printError(string `Failed to extract MSH from HL7 message`);
            return error("Failed to extract MSH from HL7 message");
        }
        // Create Acknowledgement message.
        hl7v23:ACK hl7v23Ack = {
            msh: {
                msh2: "^~\\&",
                msh3: {hd1: "TESTSERVER"},
                msh4: {hd1: "WSO2OH"},
                msh5: {hd1: msh.msh3.hd1},
                msh6: {hd1: msh.msh4.hd1},
                msh9: {cm_msg1: hl7v23:ACK_MESSAGE_TYPE},
                msh10: uuid:createType1AsString().substring(0, 8),
                msh11: {pt1: "P"},
                msh12: "2.3"
            },
            msa: {
                msa1: "AA",
                msa2: msh.msh10
            }
        };
        ack = hl7v23Ack;
        hl7Version = hl7v23:VERSION;
    } else if message is hl7v24:ADT_A01 {
        hl7v24:ADT_A01 v24ParsedMessage = <hl7v24:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v24ParsedMessage.toString()}`);

        hl7v24:ADT_A01 parsedMsg = <hl7v24:ADT_A01>message;

        hl7v24:MSH? msh = ();
        if parsedMsg is hl7v2:Message && parsedMsg.hasKey("msh") {
            anydata mshEntry = parsedMsg["msh"];
            hl7v24:MSH|error tempMSH = mshEntry.ensureType();
            if tempMSH is error {
                log:printError(string `Error occurred while casting MSH: ${tempMSH.message()}`);
                return error("Error occurred while casting MSH", tempMSH);
            }
            msh = tempMSH;
        }
        if msh is () {
            log:printError(string `Failed to extract MSH from HL7 message`);
            return error("Failed to extract MSH from HL7 message");
        }
        // Create Acknowledgement message.
        hl7v24:ACK hl7v24Ack = {
            msh: {
                msh2: "^~\\&",
                msh3: {hd1: "TESTSERVER"},
                msh4: {hd1: "WSO2OH"},
                msh5: {hd1: msh.msh3.hd1},
                msh6: {hd1: msh.msh4.hd1},
                msh9: {},
                msh10: uuid:createType1AsString().substring(0, 8),
                msh11: {pt1: "P"},
                msh12: {vid1: "2.4"}
            },
            msa: {
                msa1: "AA",
                msa2: msh.msh10
            }
        };
        ack = hl7v24Ack;
        hl7Version = hl7v24:VERSION;

    } else if message is hl7v25:ADT_A01 {
        hl7v25:ADT_A01 v25ParsedMessage = <hl7v25:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v25ParsedMessage.toString()}`);

    } else if message is hl7v26:ADT_A01 {
        hl7v26:ADT_A01 v25ParsedMessage = <hl7v26:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v25ParsedMessage.toString()}`);

    } else if message is hl7v27:ADT_A01 {
        hl7v27:ADT_A01 v25ParsedMessage = <hl7v27:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v25ParsedMessage.toString()}`);

    } else if message is hl7v28:ADT_A01 {
        hl7v28:ADT_A01 v25ParsedMessage = <hl7v28:ADT_A01>message;
        log:printDebug(string `Received ADT_A01 message: ${v25ParsedMessage.toString()}`);

    } else {
        log:printError(string `Received message is not an ADT_A01 message: ${message.toString()}`);
    }

    if ack is () || hl7Version is () {
        log:printError(string `Failed to create ACK message`);
        return error("Failed to create ACK message");
    } else {
        // Encode message to wire format.
        byte[]|hl7v2:HL7Error encodedMsg = hl7v2:encode(hl7Version, ack);
        if encodedMsg is hl7v2:HL7Error {
            return error("Error occurred while encoding acknowledgement", encodedMsg);
        }
        return encodedMsg;
    }
}

public isolated function extractPatientFromADT_A01(hl7v2:Message adtA01) returns json|error {

    json v2tofhirResult = check v2tofhirr4:v2ToFhir(adtA01);

    r4:Bundle bundle = <r4:Bundle>check r4parser:parse(v2tofhirResult);

    if bundle is r4:Bundle {
        r4:BundleEntry[] entries = <r4:BundleEntry[]>bundle.entry;
        foreach var entry in entries {
            map<anydata> fhirResource = <map<anydata>>entry?.'resource;
            if fhirResource["resourceType"].toString() == "Patient" {
                international401:Patient patientResource = <international401:Patient>check r4parser:parse(fhirResource.toJson());
                return patientResource.toJson();

            }
        }
        return error("Patient resource not found in the FHIR bundle");
    }
}
