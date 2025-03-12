import ballerinax/health.fhir.r4;

isolated function transformPatient(Patient patient) returns Patient {

    r4:HumanName[]? originalName = patient.name.clone();
    if originalName != null {
        foreach r4:HumanName name in originalName {
            string? family = name.family;
            if family != null {
                string updatedFamily = family.toUpperAscii();
                name.family = updatedFamily;
            }
        }
        patient.name = originalName;
    }
    return patient;
}