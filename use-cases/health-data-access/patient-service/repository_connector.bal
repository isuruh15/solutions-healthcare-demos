import ballerina/http;
import ballerina/log;
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
import ballerinax/health.clients.fhir;
import ballerinax/health.fhir.r4;

http:OAuth2ClientCredentialsGrantConfig fhirServerAuthConfig = {
    tokenUrl: tokenUrl,
    clientId: client_id,
    clientSecret: client_secret,
    scopes: scopes,
    optionalParams: {
        "resource": fhirServerUrl
    }
};

fhir:FHIRConnectorConfig fhirServerConfig = {
    baseURL: fhirServerUrl,
    mimeType: fhir:FHIR_JSON,
    authConfig: fhirServerAuthConfig
};

isolated fhir:FHIRConnector fhirConnectorObj = check new (fhirServerConfig);

# Create FHIR resource in the FHIR Repository. Resource type is determined by the payload.
#
# + payload - FHIR resource payload
# + return - return value description
public isolated function create(json payload) returns r4:FHIRError|fhir:FHIRResponse {
    lock {
        fhir:FHIRResponse|fhir:FHIRError fhirResponse = fhirConnectorObj->create(payload.clone());

        if fhirResponse is fhir:FHIRError {
            log:printError(fhirResponse.toBalString());
            return r4:createFHIRError(fhirResponse.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);

        }

        log:printInfo(string `Data stored successfully: ${fhirResponse.toJsonString()}`);
        return fhirResponse.clone();
    }
}

public isolated function getById(string 'resource, string id) returns r4:FHIRError|fhir:FHIRResponse {
    lock {
        fhir:FHIRResponse|fhir:FHIRError response = fhirConnectorObj->getById('resource, id, fhir:FHIR_JSON);

        if response is fhir:FHIRError {
            log:printError(response.toBalString());
            return r4:createFHIRError(response.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
        }

        return response.clone();
    }
}

public isolated function update(json payload) returns r4:FHIRError|fhir:FHIRResponse {
    lock {
        fhir:FHIRResponse|fhir:FHIRError fhirResponse = fhirConnectorObj->update(payload.clone(), returnPreference = fhir:REPRESENTATION);

        if fhirResponse is fhir:FHIRError {
            log:printError(fhirResponse.toBalString());
            return r4:createFHIRError(fhirResponse.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
        }

        log:printInfo(string `Data updated successfully: ${fhirResponse.toJsonString()}`);
        return fhirResponse.clone();
    }
}

public isolated function patchResource(string 'resource, string id, json payload) returns r4:FHIRError|fhir:FHIRResponse {
    lock {
        fhir:FHIRResponse|fhir:FHIRError fhirResponse = fhirConnectorObj->patch('resource, id, payload.clone());

        if fhirResponse is fhir:FHIRError {
            log:printError(fhirResponse.toBalString());
            return r4:createFHIRError(fhirResponse.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
        }

        log:printInfo(string `Data patched successfully: ${fhirResponse.toJsonString()}`);
        return fhirResponse.clone();
    }
}

public isolated function delete(string 'resource, string id) returns r4:FHIRError|fhir:FHIRResponse {
    lock {
        fhir:FHIRResponse|fhir:FHIRError response = fhirConnectorObj->delete('resource, id);

        if response is fhir:FHIRError {
            log:printError(response.toBalString());
            return r4:createFHIRError(response.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
        }

        log:printInfo(string `Data deleted successfully: ${response.toJsonString()}`);
        return response.clone();
    }
}

public isolated function search(string 'resource, map<string[]>? searchParameters = ()) returns r4:FHIRError|fhir:FHIRResponse {
    lock {
        fhir:FHIRResponse|fhir:FHIRError response = fhirConnectorObj->search('resource, searchParameters.clone(), fhir:FHIR_JSON);

        if response is fhir:FHIRError {
            log:printError(response.toBalString());
            return r4:createFHIRError(response.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
        }

        return response.clone();
    }
}

public isolated function extractBundleAndCreate(r4:Bundle bundle) returns fhir:FHIRResponse {

    r4:BundleEntry[] entries = <r4:BundleEntry[]>bundle.entry;
    map<string> headers = {};
    map<string> errors = {};
    foreach var entry in entries {
        map<anydata> fhirResource = <map<anydata>>entry?.'resource;
        r4:FHIRError|fhir:FHIRResponse sendToFhirRepoResult = create(fhirResource.toJson());
        if sendToFhirRepoResult is r4:FHIRError {
            errors[sendToFhirRepoResult.message()] = sendToFhirRepoResult.message();
            log:printWarn(string `Failed to send FHIR resource to the FHIR repository: ${fhirResource.toJsonString()}`);
            log:printError(sendToFhirRepoResult.toBalString());
        } else {
            headers = sendToFhirRepoResult.serverResponseHeaders;
        }
    }
    string details = string `Resources creation completed. ${(errors.length() == 0) ? "All resources created successfully." : "Errors occurred while creating resources."}:${errors.toString()}`;
    r4:OperationOutcome operationOutcome = {
        issue: [
            {
                severity: "information",
                code: "informational",
                details: {
                    text: details
                }
            }
        ]
    };
    fhir:FHIRResponse response = {

        serverResponseHeaders: headers,
        'resource: operationOutcome.toJson(),
        httpStatusCode: 201
    };
    return response;
}
