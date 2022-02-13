#!/bin/bash

VANILLA_FILES_DIR="$(pwd)/vanilla"

LANGUAGES_FILE="languages.xml"
LOCATIONS_FILE="locations.xml"
TITLES_FILE="titles.xml"

if [ -d "${HOME}/.games/Steam/common" ]; then
    STEAM_APPS_DIR="${HOME}/.games/Steam"
elif [ -d "${HOME}/.local/share/Steam/steamapps/common" ]; then
    STEAM_APPS_DIR="${HOME}/.local/share/Steam/steamapps"
fi

STEAM_GAMES_DIR="${STEAM_APPS_DIR}/common"
STEAM_WORKSHOP_DIR="${STEAM_APPS_DIR}/workshop"

CK2_VANILLA_FILE="${VANILLA_FILES_DIR}/ck2_landed_titles.txt"
CK2HIP_VANILLA_FILE="${VANILLA_FILES_DIR}/ck2hip_landed_titles.txt"
CK3_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3_landed_titles.txt"
CK3ATHA_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3atha_landed_titles.txt"
CK3IBL_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3ibl_landed_titles.txt"
CK3MBP_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3mbp_landed_titles.txt"
CK3TFE_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3tfe_landed_titles.txt"
IR_VANILLA_FILE="${VANILLA_FILES_DIR}/ir_province_names.yml"
IR_AoE_VANILLA_FILE="${VANILLA_FILES_DIR}/iraoe_province_names.yml"

CK3_WORKSHOP_MODS_DIR="${STEAM_WORKSHOP_DIR}/content/1158310"

CK3_VANILLA_LOCALISATION_FILE="${STEAM_GAMES_DIR}/Crusader Kings III/game/localization/english/titles_l_english.yml"
CK3ATHA_VANILLA_BARONIES_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2618149514/localization/english/ATHA_titles_baronies_l_english.yml"
CK3ATHA_VANILLA_COUNTIES_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2618149514/localization/english/ATHA_titles_counties_l_english.yml"
CK3ATHA_VANILLA_DUCHIES_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2618149514/localization/english/ATHA_titles_duchies_l_english.yml"
CK3ATHA_VANILLA_KINGDOMS_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2618149514/localization/english/ATHA_titles_kingdoms_l_english.yml"
CK3ATHA_VANILLA_EMPIRES_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2618149514/localization/english/ATHA_titles_empires_l_english.yml"
CK3ATHA_VANILLA_SPECIAL_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2618149514/localization/english/ATHA_titles_special_l_english.yml"
CK3IBL_VANILLA_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2416949291/localization/english/replace/ibl_titles_l_english.yml"
CK3MBP_VANILLA_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2216670956/localization/english/titles_l_english.yml"
CK3TFE_VANILLA_LOCALISATION_FILE="${CK3_WORKSHOP_MODS_DIR}/2243307127/localization/english/titles_l_english.yml"

LANGUAGE_IDS="$(grep "<Id>" "${LANGUAGES_FILE}" | sed 's/[^>]*>\([^<]*\).*/\1/g' | sort)"
LOCATION_IDS="$(grep "<Id>" "${LOCATIONS_FILE}" | sed 's/[^>]*>\([^<]*\).*/\1/g' | sort)"

GAME_IDS_CK="$(grep "<GameId game=\"CK" "${LOCATIONS_FILE}" | sed 's/^[^>]*>\([^<]*\).*/\1/g' | sort | uniq)"

function getGameIds() {
    GAME="${1}"

    grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
        sed 's/[^>]*>\([^<]*\).*/\1/g' | \
        sort
}

function checkForMissingCkLocationLinks() {
    GAME="${1}"
    VANILLA_FILE="${2}"

    for TITLE_ID in $(diff \
                        <(getGameIds "${GAME}") \
                        <( \
                            cat "${VANILLA_FILE}" | \
                            if file "${VANILLA_FILE}" | grep -q 'Non-ISO\|ISO-8859'; then
                                iconv -f WINDOWS-1252 -t UTF-8 2> /dev/null
                            else
                                cat
                            fi | \
                            grep -i "^\s*[ekdcb]_.*=" | \
                            awk -F"=" '{print $1}' | \
                            sed 's/[^a-zA-Z0-9_\-]//g' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        LOCATION_ID=${TITLE_ID:2}
        LOCATION_ID_FOR_SEARCH=$(echo "${LOCATION_ID}" | sed 's/[_-]//g')

        if ! $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$") &&
           ! $(echo "${GAME_IDS_CK}" | sed 's/[_-]//g' | grep -Eioq "^[ekdcb]_${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME}: ${TITLE_ID} is missing"
        else
            echo "    > ${GAME}: ${TITLE_ID} is missing (but location \"${LOCATION_ID}\" exists)"
        fi
    done
}

function checkForSurplusCkLocationLinks() {
    GAME="${1}"
    VANILLA_FILE="${2}"

    for TITLE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) <( \
                            cat "${VANILLA_FILE}" | \
                            if file "${VANILLA_FILE}" | grep -q 'Non-ISO\|ISO-8859'; then
                                iconv -f WINDOWS-1252 -t UTF-8 2> /dev/null
                            else
                                cat
                            fi | \
                            grep -i "^\s*[ekdcb]_.*=" | \
                            awk -F"=" '{print $1}' | \
                            sed 's/[^a-zA-Z0-9_\-]//g' | \
                            sort | uniq \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME}: ${TITLE_ID} is defined but it does not exist"
    done
}

function checkForSurplusIrLocationLinks() {
    GAME="${1}"
    VANILLA_FILE="${2}"

    for TITLE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) <( \
                            grep -i "^\s*PROV[0-9]*:.*" "${VANILLA_FILE}" | \
                            sed 's/^\s*PROV\([0-9]*\):.*$/\1/g' | \
                            sort | uniq \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME}: ${TITLE_ID} is defined but it does not exist"
    done
}

function checkForMismatchingLocationLinks() {
    GAME="${1}"
    VANILLA_FILE="${2}"

    [ ! -f "${VANILLA_FILE}" ] && return

    if [[ ${GAME} == CK* ]]; then
        checkForMissingCkLocationLinks "${GAME}" "${VANILLA_FILE}"
        checkForSurplusCkLocationLinks "${GAME}" "${VANILLA_FILE}"
    elif [[ ${GAME} == IR* ]]; then
        checkForSurplusIrLocationLinks "${GAME}" "${VANILLA_FILE}"
    fi
}

function checkDefaultCk3Localisations() {
    local GAME_ID="${1}"
    local LOCALISATIONS_FILE="${2}"

    [ ! -f "${LOCALISATIONS_FILE}" ] && return

    for GAMEID_DEFINITION in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/^ *//g' |
                            sort
                        ) <( \
                            awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                                <(getGameIds "${GAME_ID}") \
                                <( \
                                    grep "^ *[ekdcb]_" "${LOCALISATIONS_FILE}" | \
                                    grep -v "_adj:" | \
                                    sed 's/^ *\([^:]*\):[0-9]* *\"\([^\"]*\).*/\1=\2/g' | \
                                    sed -e 's/= */=/g' -e 's/ *$//g'
                                ) | \
                            awk -F"=" '{print "<GameId game=\"'${GAME_ID}'\">"$1"</GameId> <!-- "$2" -->"}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
        echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
    done
}

function checkDefaultIrLocalisations() {
    local GAME_ID="${1}"
    local LOCALISATIONS_FILE="${2}"

    [ ! -f "${LOCALISATIONS_FILE}" ] && return

    for GAMEID_DEFINITION in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/^ *//g' |
                            sort
                        ) <( \
                            awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                                <(getGameIds "${GAME_ID}") \
                                <( \
                                    tac "${LOCALISATIONS_FILE}" "${IR_VANILLA_FILE}" | \
                                    grep "^ *PROV" | \
                                    grep -v "_[A-Za-z_-]*:" | \
                                    awk '!x[substr($0,0,9)]++' | \
                                    sed 's/^ *PROV\([0-9]*\):[0-9]* *\"\([^\"]*\).*/\1=\2/g' | \
                                    sed -e 's/= */=/g' -e 's/ *$//g'
                                ) | \
                            awk -F"=" '{print "<GameId game=\"'${GAME_ID}'\">"$1"</GameId> <!-- "$2" -->"}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
        echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
    done
}

function validateHoi4Parentage() {
    local GAME_ID="${1}"

    for STATE_ID in $(grep "${GAME_ID}\" type=\"City" "${LOCATIONS_FILE}" | \
                            sed 's/.*parent=\"\([^\"]*\).*/\1/g' | \
                            sort -g | uniq); do
        if ! grep -q "${GAME_ID}\" type=\"State\">${STATE_ID}<" "${LOCATIONS_FILE}"; then
            echo "${GAME_ID}: State #${STATE_ID} is missing while there are cities referencing it"
        fi
    done
}

### Make sure locations are sorted alphabetically

OLD_LC_COLLATE=${LC_COLLATE}
export LC_COLLATE=C

WELL_COVERED_SECTION_END_LINE_NR=$(grep -n "@@@@ BELOW TITLES NEED REVIEW" "${LOCATIONS_FILE}" | awk -F":" '{print $1}')
ACTUAL_LOCATIONS_LIST=$(head "${LOCATIONS_FILE}" -n "${WELL_COVERED_SECTION_END_LINE_NR}" | \
                        grep "^\s*<Id>" | \
                        sed 's/^\s*<Id>\([^<]*\).*/\1/g' | \
                        sed -r '/^\s*$/d' | \
                        perl -p0e 's/\r*\n/%NL%/g')
EXPECTED_LOCATIONS_LIST=$(echo "${ACTUAL_LOCATIONS_LIST}" | \
                            sed 's/%NL%/\n/g' | \
                            sort | \
                            sed -r '/^\s*$/d' | \
                            perl -p0e 's/\r*\n/%NL%/g')

diff --context=1 --color --suppress-common-lines <(echo "${ACTUAL_LOCATIONS_LIST}" | sed 's/%NL%/\n/g') <(echo "${EXPECTED_LOCATIONS_LIST}" | sed 's/%NL%/\n/g')
export LC_COLLATE=${OLD_LC_COLLATE}

# Find duplicated IDs
grep "^ *<Id>" *.xml | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find duplicated game IDs
grep "<GameId game=" *.xml | \
    sed -e 's/[ \t]*<!--.*-->.*//g' -e 's/^[ \t]*//g' | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find duplicated names
grep -Pzo "\n *<Name language=\"([^\"]*)\" value=\"([^\"]*)\" />((\n *<Name l.*)*)\n *<Name language=\"\1\" value=\"\2\" />.*\n" *.xml

# Find empty definitions
grep "><" "${LOCATIONS_FILE}" "${LANGUAGES_FILE}" "${TITLES_FILE}"

# Find duplicated language codes
for I in {1..3}; do
    grep "iso-639-" "${LANGUAGES_FILE}" | \
        sed -e 's/^ *<Code \(.*\) \/>.*/\1/g' \
            -e 's/ /\n/g' \
            -e 's/\"//g' | \
        grep "iso-639-${I}" | \
        awk -F"=" '{print $2}' | \
        sort | uniq -c | grep "^ *[2-9]"
done

# Validate XML structure
grep -Pzo "\n *<[a-zA-Z]*Entity>\n *<Id>.*\n *</[a-zA-Z]*Entity>.*\n" *.xml
grep -Pzo "\n *</Names.*\n *</*(Names|GameId).*\n" *.xml
grep -Pzo "\n *<Names>\n *<[^N].*\n" *.xml
grep -Pzo "\n *<Name .*\n *</L.*\n" *.xml
grep -Pzo "\n *</GameIds>\n *<Name .*\n" *.xml
grep -Pzo "\n *<GameId .*\n *<Name.*\n" *.xml
grep -Pzo "\n *<(/*)GameIds.*\n *<\1GameIds.*\n" *.xml
grep -Pzo "\n *<GameIds>\n *<[^G].*\n" *.xml
grep -Pzo "\n\s*<Language>\n\s*<[^I][^d].*\n" *.xml # Missing Id (right after definition)
grep -n "^\s*</[^>]*>\s*[a-zA-Z0-9\s]" *.xml # Text after ending tags
grep -Pzo "\n\s*<(/[^>]*)>.*\n\s*<\1>\n" *.xml # Double tags
grep -Pzo "\n\s*<([^>]*)>\s*\n\s*</\1>\n" *.xml # Empty tags
grep -Pzo "\n\s*<Name .*\n\s*</GameId.*\n" *.xml # </GameId.* after <Name> 
grep -Pzo "\s*([^=\s]*)\s*=\s*\"[^\"]*\"\s*\1\s*=\"[^\"]*\".*\n" *.xml # Double attributes
grep -Pzo "\n.*=\s*\"\s*\".*\n" *.xml # Empty attributes
grep -n "^\s*<\([^> ]*\).*<\/.*" *.xml | grep -v "^[a-z0-9:.]*\s*<\([^> ]*\).*<\/\1>.*" # Mismatching start/end tag on same line
grep -Pzo "\n *</(Language|Location|Title)>.*\n *<Fallback.*\n" *.xml
grep -Pzo "\n *</[A-Za-z]*Entity.*\n *<(Id|Name).*\n" *.xml
grep -n "\(adjective\|value\)=\"\([^\"]*\)\"\s*>" *.xml
grep -n "<<\|>>" *.xml
grep -n "[^=]\"[a-zA-Z]*=" *.xml
grep -n "==\"" *.xml
grep --color -n "[a-zA-Z0-9]\"[^ <>/?]" *.xml
grep --color -n "/>\s*[a-z]" *.xml

grep -n "\(iso-639-[0-9]\)=\"[a-z]*\" \1" "${LANGUAGES_FILE}"
grep -Pzo "\n *<Code.*\n *<Language>.*\n" "${LANGUAGES_FILE}"

grep -Pzo "\n *<LocationEntity.*\n *<[^I].*\n" "${LOCATIONS_FILE}"

# Find non-existing fallback languages
for FALLBACK_LANGUAGE_ID in $(diff \
                    <( \
                        grep "<LanguageId>" "${LANGUAGES_FILE}" | \
                        sed 's/.*<LanguageId>\([^<>]*\)<\/LanguageId>.*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        echo "${LANGUAGE_IDS}" | \
                        sed 's/ /\n/g') | \
                    grep "^<" | sed 's/^< //g' | sed 's/ /@/g'); do
    echo "The \"${FALLBACK_LANGUAGE_ID}\" fallback language does not exit"
done

# Find non-existing fallback locations
for FALLBACK_LOCATION_ID in $(diff \
                    <( \
                        grep "<LocationId>" "${LOCATIONS_FILE}" | \
                        sed 's/.*<LocationId>\([^<>]*\)<\/LocationId>.*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        echo "${LOCATION_IDS}" | \
                        sed 's/ /\n/g') | \
                    grep "^<" | sed 's/^< //g' | sed 's/ /@/g'); do
    echo "The \"${FALLBACK_LOCATION_ID}\" fallback location does not exit"
done

# Find non-existing fallback titles
for FALLBACK_TITLE_ID in $(diff \
                    <( \
                        grep "<TitleId>" "${TITLES_FILE}" | \
                        sed 's/.*<TitleId>\([^<>]*\)<\/TitleId>.*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        grep "<Id>" "${TITLES_FILE}" | \
                        sed 's/^[^<]*<Id>\([^<]*\).*/\1/g' | \
                        sort | uniq \
                    ) | \
                    grep "^<" | sed 's/^< //g' | sed 's/ /@/g'); do
    echo "The \"${FALLBACK_TITLE_ID}\" fallback title does not exit"
done

# Find non-existing name languages
for LANGUAGE_ID in $(diff \
                    <( \
                        grep "<Name " *.xml | \
                        sed 's/.*language=\"\([^\"]*\).*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        grep "<Id>" "${LANGUAGES_FILE}" | \
                        sed 's/^[^<]*<Id>\([^<]*\).*/\1/g' | \
                        sort | uniq \
                    ) | \
                    grep "^<" | sed 's/^< //g' | sed 's/ /@/g'); do
    echo "The \"${LANGUAGE_ID}\" language does not exit"
done

# Find multiple name definitions for the same language
#grep -Pzo "\n.* language=\"([^\"]*)\".*\n.*language=\"\1\".*\n" *.xml
#
## Make sure all titles are defined and exist in the game
#checkForMismatchingLocationLinks "CK2"      "${CK2_VANILLA_FILE}"
#checkForMismatchingLocationLinks "CK2HIP"   "${CK2HIP_VANILLA_FILE}"
#checkForMismatchingLocationLinks "CK3"      "${CK3_VANILLA_FILE}"
#checkForMismatchingLocationLinks "CK3IBL"   "${CK3IBL_VANILLA_FILE}"
#checkForMismatchingLocationLinks "CK3MBP"   "${CK3MBP_VANILLA_FILE}"
#checkForMismatchingLocationLinks "CK3TFE"   "${CK3TFE_VANILLA_FILE}"
#checkForMismatchingLocationLinks "CK3ATHA"  "${CK3ATHA_VANILLA_FILE}"
#checkForMismatchingLocationLinks "IR"       "${IR_VANILLA_FILE}"
#
#validateHoi4Parentage "HOI4"
#validateHoi4Parentage "HOI4TGW"
#
## Validate default localisations
#checkDefaultCk3Localisations "CK3"      "${CK3_VANILLA_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_BARONIES_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_COUNTIES_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_DUCHIES_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_KINGDOMS_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_EMPIRES_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_SPECIAL_LOCALISATION_FILE}"
##checkDefaultCk3Localisations "CK3TFE"   "${CK3TFE_VANILLA_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3IBL"   "${CK3IBL_VANILLA_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3MBP"   "${CK3MBP_VANILLA_LOCALISATION_FILE}"
#checkDefaultIrLocalisations "IR"        "${IR_VANILLA_FILE}"
checkDefaultIrLocalisations "IR_AoE"    "${IR_AoE_VANILLA_FILE}"
