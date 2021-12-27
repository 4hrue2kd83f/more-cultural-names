#!/bin/bash

HOI4_DIR="${HOME}/.local/share/Steam/steamapps/common/Hearts of Iron IV"
HOI4_STATES_DIR="${HOI4_DIR}/history/states"
HOI4_LOCALISATION_DIR="${HOI4_DIR}/localisation/english"
LOCATIONS_FILE="$(pwd)/locations.xml"

HOI4_PARENTS_FILE="$(pwd)/hoi4_parents.txt"
HOI4_CITIES_FILE="$(pwd)/hoi4_cities.txt"
HOI4_STATES_FILE="$(pwd)/hoi4_states.txt"

source "scripts/common/name_normalisation.sh"

function getCityName() {
    local CITY_ID="${1}"

    cat "${HOI4_LOCALISATION_DIR}/victory_points_l_english.yml" | \
        grep "^\s*VICTORY_POINTS_${CITY_ID}:" | \
        sed 's/^\s*VICTORY_POINTS_'"${CITY_ID}"':[0-9]\s*\"\([^\"]*\).*/\1/g'
}

echo "" > "${HOI4_PARENTS_FILE}"
echo "" > "${HOI4_CITIES_FILE}"
echo "" > "${HOI4_STATES_FILE}"

for FILE in "${HOI4_STATES_DIR}"/*.txt ; do
    STATE_ID=$(basename "${FILE}" | sed 's/^\([0-9]*\)\s*-\s*.*/\1/g')
    STATE_NAME=$(cat "${HOI4_LOCALISATION_DIR}/state_names_l_english.yml" | \
                    grep "^\s*STATE_${STATE_ID}:" | \
                    sed 's/^\s*STATE_'"${STATE_ID}"':[0-9]\s*\"\([^\"]*\).*/\1/g')
    
    PROVINCE_LIST=$(cat "${FILE}" | \
        sed 's/\r//g' | \
        tr '\n' ' ' | \
        sed 's/\s\s*/ /g' | \
        sed 's/.*provinces\s*=\s*{\([^}]*\).*/\1/g' | \
        sed 's/\(^\s*\|\s*$\)//g')

    for PROVINCE_ID in ${PROVINCE_LIST}; do
        [[ -n "${PROVINCE_LIST// }" ]] && echo "${PROVINCE_ID}=${STATE_ID}" >> "${HOI4_PARENTS_FILE}"
    done
    
    #echo "State #${STATE_ID}: Name='${STATE_NAME}'"
    if $(cat "${LOCATIONS_FILE}" | grep "<GameId game=\"HOI4\"" | grep "type=\"State\"" | grep -q ">${STATE_ID}<"); then
        sed -i 's/\(^\s*<GameId game=\"HOI4\" type=\"State\">'"${STATE_ID}"'<\/GameId>\).*/\1 <!-- '"${STATE_NAME}"' -->/g' "${LOCATIONS_FILE}"
    else
        echo "      <GameId game=\"HOI4\" type=\"State\">${STATE_ID}</GameId> <!-- ${STATE_NAME} -->" >> "${HOI4_STATES_FILE}"

        LOCATION_ID=$(nameToLocationId "${STATE_NAME}")

        if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
            echo "    > HOI4: State #${STATE_ID} (${STATE_NAME}) could potentially be linked with location ${LOCATION_ID}"
        fi
    fi
done

for CITY_ID in $(grep "^\s*VICTORY_POINTS_" "${HOI4_LOCALISATION_DIR}/victory_points_l_english.yml" | \
                    sed 's/^\s*VICTORY_POINTS_\([0-9]*\).*/\1/g' | \
                    sort -h | uniq); do
    STATE_ID=$(grep "^${CITY_ID}=" "${HOI4_PARENTS_FILE}" | awk -F = '{print $2}')
    CITY_NAME=$(getCityName "${CITY_ID}")

    #echo "Province #${CITY_ID}: State=#${STATE_ID} Name='${CITY_NAME}'"
    if $(cat "${LOCATIONS_FILE}" | grep "<GameId game=\"HOI4\"" | grep "type=\"City\"" | grep -q ">${CITY_ID}<"); then
        sed -i 's/\(^\s*<GameId game=\"HOI4\" type=\"City\"\)\( parent=\"[^\"]*\"\)*>'"${CITY_ID}"'<.*/\1 parent=\"'"${STATE_ID}"'\">'"${CITY_ID}"'<\/GameId> <!-- '"${CITY_NAME}"' -->/g' "${LOCATIONS_FILE}"
    else
        echo "      <GameId game=\"HOI4\" type=\"City\" parent=\"${STATE_ID}\">${CITY_ID}</GameId> <!-- ${CITY_NAME} -->" >> "${HOI4_CITIES_FILE}"
    
        LOCATION_ID=$(nameToLocationId "${CITY_NAME}")

        if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
            echo "    > HOI4: City #${CITY_ID} (${CITY_NAME}) could potentially be linked with location ${LOCATION_ID}"
        fi
    fi
done