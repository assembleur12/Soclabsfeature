#!/bin/bash

#------------------------- Gather parameters -------------------------#

# Extra arguments
read INPUT_JSON
YARA_PATH=$(echo $INPUT_JSON | jq -r .parameters.extra_args[1])
YARA_RULES=$(echo $INPUT_JSON | jq -r .parameters.extra_args[3])
FILENAME=$(echo $INPUT_JSON | jq -r .parameters.alert.syscheck.path)
QUARANTINE_PATH="/tmp/quarantined"

# Set LOG_FILE path
LOG_FILE="/var/ossec/logs/active-responses.log"

#------------------------- Wait for file stability --------------------------#

size=0
actual_size=$(stat -c %s ${FILENAME})
while [ ${size} -ne ${actual_size} ]; do
    sleep 1
    size=${actual_size}
    actual_size=$(stat -c %s ${FILENAME})
done

#----------------------- Analyze parameters -----------------------#

if [[ ! $YARA_PATH ]] || [[ ! $YARA_RULES ]]
then
    echo "wazuh-yara: ERROR - Yara active response error. Yara path and rules parameters are mandatory." >> ${LOG_FILE}
    exit 1
fi

#------------------------- Main workflow --------------------------#

# Execute Yara scan on the specified filename
yara_output="$("${YARA_PATH}"/yara -C -w -r -f -m "$YARA_RULES" "$FILENAME")"

if [[ $yara_output != "" ]]
then
    # Iterate every detected rule and append it to the LOG_FILE
    while read -r line; do
        echo "wazuh-yara: INFO - Scan result: $line" >> ${LOG_FILE}
    done <<< "$yara_output"
    
    # Move the infected file to quarantine
    /usr/bin/mv -f $FILENAME ${QUARANTINE_PATH}
    
    # Get the base name of the file (without path)
    FILEBASE=$(/usr/bin/basename $FILENAME)
    
    /usr/bin/chattr -R +i ${QUARANTINE_PATH}/${FILEBASE}
    
    /usr/bin/echo "wazuh-yara: $FILENAME moved to ${QUARANTINE_PATH}" >> ${LOG_FILE}
fi

exit 0;
