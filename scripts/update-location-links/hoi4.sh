#!/bin/bash

STEAM_APPS_DIR="${HOME}/.local/share/Steam/steamapps"
STEAM_GAMES_DIR="${STEAM_APPS_DIR}/common"
STEAM_WORKSHOP_DIR="${STEAM_APPS_DIR}/workshop"

HOI4_WORKSHOP_MODS_DIR="${STEAM_WORKSHOP_DIR}/content/394360"

HOI4_DIR="${STEAM_GAMES_DIR}/Hearts of Iron IV"
HOI4_STATES_DIR="${HOI4_DIR}/history/states"
HOI4_LOCALISATIONS_DIR="${HOI4_DIR}/localisation/english"

HOI4TGW_DIR="${HOI4_WORKSHOP_MODS_DIR}/699709023"
HOI4TGW_STATES_DIR="${HOI4TGW_DIR}/history/states"
HOI4TGW_LOCALISATIONS_DIR="${HOI4TGW_DIR}/localisation"

LOCATIONS_FILE="$(pwd)/locations.xml"
OUTPUT_FILES_DIR="$(pwd)"

source "scripts/common/name_normalisation.sh"

function getCityName() {
    local CITY_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local CITY_NAME=""

    CITY_NAME=$(cat "${LOCALISATIONS_DIR}/victory_points_l_english.yml" | \
                grep "^\s*VICTORY_POINTS_${CITY_ID}:" | \
                sed 's/^\s*VICTORY_POINTS_'"${CITY_ID}"':[0-9]\s*\"\([^\"]*\).*/\1/g')

    echo "${CITY_NAME}"
}

for GAME_ID in "HOI4" "HOI4TGW"; do
    echo "" > "$(pwd)/${GAME_ID}_parents.txt"
    echo "" > "$(pwd)/${GAME_ID}_cities.txt"
    echo "" > "$(pwd)/${GAME_ID}_states.txt"
done

function getStates() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local STATES_DIR="${3}"

    for  FILE in "${STATES_DIR}"/*.txt ; do
        STATE_ID=$(basename "${FILE}" | sed 's/^\([0-9]*\)\s*-\s*.*/\1/g')
        STATE_NAME=$(cat "${LOCALISATIONS_DIR}/state_names_l_english.yml" | \
                        grep "^\s*STATE_${STATE_ID}:" | \
                        sed 's/^\s*STATE_'"${STATE_ID}"':[0-9]\s*\"\([^\"]*\).*/\1/g')
        
        PROVINCE_LIST=$(cat "${FILE}" | \
            sed 's/\r//g' | \
            tr '\n' ' ' | \
            sed 's/\s\s*/ /g' | \
            sed 's/.*provinces\s*=\s*{\([^}]*\).*/\1/g' | \
            sed 's/\(^\s*\|\s*$\)//g')

        for PROVINCE_ID in ${PROVINCE_LIST}; do
            [[ -n "${PROVINCE_LIST// }" ]] && echo "${PROVINCE_ID}=${STATE_ID}" >> "${OUTPUT_FILES_DIR}/${GAME_ID}_parents.txt"
        done
        
        #echo "State #${STATE_ID}: Name='${STATE_NAME}'"
        if $(cat "${LOCATIONS_FILE}" | grep "<GameId game=\"${GAME_ID}\"" | grep "type=\"State\"" | grep -q ">${STATE_ID}<"); then
            sed -i 's/\(^\s*<GameId game=\"'"${GAME_ID}"'\" type=\"State\">'"${STATE_ID}"'<\/GameId>\).*/\1 <!-- '"${STATE_NAME}"' -->/g' "${LOCATIONS_FILE}"
        else
            echo "      <GameId game=\"${GAME_ID}\" type=\"State\">${STATE_ID}</GameId> <!-- ${STATE_NAME} -->" >> "${OUTPUT_FILES_DIR}/${GAME_ID}_states.txt"

            LOCATION_ID=$(nameToLocationId "${STATE_NAME}")

            if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
                echo "    > ${GAME_ID}: State #${STATE_ID} (${STATE_NAME}) could potentially be linked with location ${LOCATION_ID}"
            fi
        fi
    done
}

function getCities() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"

    for CITY_ID in $(grep "^\s*VICTORY_POINTS_" "${LOCALISATIONS_DIR}/victory_points_l_english.yml" | \
                        sed 's/^\s*VICTORY_POINTS_\([0-9]*\).*/\1/g' | \
                        sort -h | uniq); do
        STATE_ID=$(grep "^${CITY_ID}=" "${OUTPUT_FILES_DIR}/${GAME_ID}_parents.txt" | awk -F = '{print $2}')
        CITY_NAME=$(getCityName "${CITY_ID}" "${LOCALISATIONS_DIR}")

        #echo "Province #${CITY_ID}: State=#${STATE_ID} Name='${CITY_NAME}'"
        if $(cat "${LOCATIONS_FILE}" | grep "<GameId game=\"${GAME_ID}\"" | grep "type=\"City\"" | grep -q ">${CITY_ID}<"); then
            sed -i 's/\(^\s*<GameId game=\"'"${GAME_ID}"'\" type=\"City\"\)\( parent=\"[^\"]*\"\)*>'"${CITY_ID}"'<.*/\1 parent=\"'"${STATE_ID}"'\">'"${CITY_ID}"'<\/GameId> <!-- '"${CITY_NAME}"' -->/g' "${LOCATIONS_FILE}"
        else
            echo "      <GameId game=\"${GAME_ID}\" type=\"City\" parent=\"${STATE_ID}\">${CITY_ID}</GameId> <!-- ${CITY_NAME} -->" >> "${OUTPUT_FILES_DIR}/${GAME_ID}_cities.txt"
        
            LOCATION_ID=$(nameToLocationId "${CITY_NAME}")

            if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
                echo "    > ${GAME_ID}: City #${CITY_ID} (${CITY_NAME}) could potentially be linked with location ${LOCATION_ID}"
            fi
        fi
    done
}

getStates "HOI4" "${HOI4_LOCALISATIONS_DIR}" "${HOI4_STATES_DIR}"
getCities "HOI4" "${HOI4_LOCALISATIONS_DIR}"

getStates "HOI4TGW" "${HOI4_LOCALISATIONS_DIR}" "${HOI4_STATES_DIR}"
getCities "HOI4TGW" "${HOI4_LOCALISATIONS_DIR}"
