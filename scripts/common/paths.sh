#!/bin/bash

REPO_DIR="$(pwd)"
SCRIPTS_DIR="${REPO_DIR}/scripts"
OUTPUT_DIR="${REPO_DIR}/out"
EXTRAS_DIR="${REPO_DIR}/extras"
VANILLA_FILES_DIR="${REPO_DIR}/vanilla"

LANGUAGES_FILE="${REPO_DIR}/languages.xml"
LOCATIONS_FILE="${REPO_DIR}/locations.xml"
TITLES_FILE="${REPO_DIR}/titles.xml"

if [ -d "${HOME}/.games/Steam/common" ]; then
    STEAM_APPS_DIR="${HOME}/.games/Steam"
elif [ -d "${HOME}/.local/share/Steam/steamapps/common" ]; then
    STEAM_APPS_DIR="${HOME}/.local/share/Steam/steamapps"
fi

STEAM_GAMES_DIR="${STEAM_APPS_DIR}/common"
STEAM_WORKSHOP_DIR="${STEAM_APPS_DIR}/workshop"
STEAM_WORKSHOP_CK3_DIR="${STEAM_WORKSHOP_DIR}/content/1158310"
STEAM_WORKSHOP_HOI4_DIR="${STEAM_WORKSHOP_DIR}/content/394360"
STEAM_WORKSHOP_IR_DIR="${STEAM_WORKSHOP_DIR}/content/859580"
CK2_LOCAL_MODS_DIR="${HOME}/.paradoxinteractive/Crusader Kings II/mod"

CK2_DIR="${STEAM_GAMES_DIR}/Crusader Kings II"
CK2_CULTURES_DIR="${CK2_DIR}/common/cultures"
CK2_LOCALISATIONS_DIR="${CK2_DIR}/localisation"
CK2_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck2_landed_titles.txt"

CK2HIP_DIR="${CK2_LOCAL_MODS_DIR}/Historical_Immersion_Project"
CK2HIP_CULTURES_DIR="${CK2HIP_DIR}/common/cultures"
CK2HIP_LOCALISATIONS_DIR="${CK2HIP_DIR}/localisation"
CK2HIP_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck2hip_landed_titles.txt"

CK2TWK_DIR="${CK2_LOCAL_MODS_DIR}/britannia"
CK2TWK_CULTURES_DIR="${CK2TWK_DIR}/common/cultures"
CK2TWK_LOCALISATIONS_DIR="${CK2TWK_DIR}/localisation"
CK2TWK_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck2twk_landed_titles.txt"

CK3_DIR="${STEAM_GAMES_DIR}/Crusader Kings III"
CK3_CULTURES_DIR="${CK3_DIR}/game/common/culture/cultures"
CK3_LOCALISATIONS_DIR="${CK3_DIR}/game/localization/english"
CK3_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3_landed_titles.txt"
CK3_VANILLA_LOCALISATION_FILE="${CK3_DIR}/game/localization/english/titles_l_english.yml"
CK3_VANILLA_CULTURAL_LOCALISATION_FILE="${CK3_LOCALISATIONS_DIR}/titles_cultural_names_l_english.yml"

CK3AP_DIR="${STEAM_WORKSHOP_CK3_DIR}/2273832430"
CK3AP_CULTURES_DIR="${CK3AP_DIR}/common/culture/cultures"
CK3AP_LOCALISATIONS_DIR="${CK3AP_DIR}/localization/english"
CK3AP_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3ap_landed_titles.txt"
CK3AP_VANILLA_LOCALISATION_FILE="${CK3AP_LOCALISATIONS_DIR}/titles_l_english.yml"

CK3ATHA_DIR="${STEAM_WORKSHOP_CK3_DIR}/2618149514"
CK3ATHA_CULTURES_DIR="${CK3ATHA_DIR}/common/culture/cultures"
CK3ATHA_LOCALISATIONS_DIR="${CK3ATHA_DIR}/localization/english"
CK3ATHA_LANDED_TITLES_DIR="${CK3ATHA_DIR}/common/landed_titles"
CK3ATHA_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3atha_landed_titles.txt"

CK3CMH_DIR="${STEAM_WORKSHOP_CK3_DIR}/2416949291"
CK3CMH_CULTURES_DIR="${CK3CMH_DIR}/common/culture/cultures"
CK3CMH_LOCALISATIONS_DIR="${CK3CMH_DIR}/localization/english"
CK3CMH_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3cmh_landed_titles.txt"
CK3CMH_VANILLA_LOCALISATION_FILE="${CK3CMH_LOCALISATIONS_DIR}/replace/ibl_titles_l_english.yml"

CK3IBL_DIR="${STEAM_WORKSHOP_CK3_DIR}/2416949291"
CK3IBL_CULTURES_DIR="${CK3IBL_DIR}/common/culture/cultures"
CK3IBL_LOCALISATIONS_DIR="${CK3IBL_DIR}/localization/english"
CK3IBL_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3ibl_landed_titles.txt"
CK3IBL_VANILLA_LOCALISATION_FILE="${CK3IBL_LOCALISATIONS_DIR}/replace/ibl_titles_l_english.yml"

CK3MBP_DIR="${STEAM_WORKSHOP_CK3_DIR}/2216670956"
CK3MBP_CULTURES_DIR="${CK3MBP_DIR}/common/culture/cultures"
CK3MBP_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3mbp_landed_titles.txt"
CK3MBP_VANILLA_LOCALISATION_FILE_1="${CK3MBP_DIR}/localization/english/titles_l_english.yml"
CK3MBP_VANILLA_LOCALISATION_FILE_2="${CK3MBP_DIR}/localization/replace/english/zNB_Titles_l_english.yml"

CK3RICE_DIR="${STEAM_WORKSHOP_CK3_DIR}/2273832430"
CK3RICE_CULTURES_DIR="${CK3RICE_DIR}/common/culture/cultures"
CK3RICE_LOCALISATIONS_DIR="${CK3RICE_DIR}/localization/english"
CK3RICE_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3rice_landed_titles.txt"
CK3RICE_VANILLA_LOCALISATION_FILE="${CK3RICE_LOCALISATIONS_DIR}/titles_l_english.yml"

CK3SoW_DIR="${STEAM_WORKSHOP_CK3_DIR}/2566883856"
CK3SoW_CULTURES_DIR="${CK3SoW_DIR}/common/culture/cultures"
CK3SoW_LOCALISATIONS_DIR="${CK3SoW_DIR}/localization/english"
CK3SoW_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3sow_landed_titles.txt"
CK3SoW_VANILLA_LOCALISATION_FILE="${CK3SoCK3SoW_LOCALISATIONS_DIRW_DIR}/replace/demd_titles_l_english.yml"

CK3TBA_DIR="${STEAM_WORKSHOP_CK3_DIR}/2216525506"
CK3TBA_CULTURES_DIR="${CK3TBA_DIR}/common/culture/cultures"
CK3TBA_LOCALISATIONS_DIR="${CK3TBA_DIR}/localization/english"
CK3TBA_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3tba_landed_titles.txt"
CK3TBA_VANILLA_LOCALISATION_FILE="${CK3TBA_LOCALISATIONS_DIR}/titles_l_english.yml"

CK3TFE_DIR="${STEAM_WORKSHOP_CK3_DIR}/2243307127"
CK3TFE_CULTURES_DIR="${CK3TFE_DIR}/common/culture/cultures"
CK3TFE_LOCALISATIONS_DIR="${CK3TFE_DIR}/localization/english"
CK3TFE_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3tfe_landed_titles.txt"
CK3TFE_VANILLA_LOCALISATION_FILE="${CK3TFE_LOCALISATIONS_DIR}/replace/TFE_titles_l_english.yml"

HOI4_DIR="${STEAM_GAMES_DIR}/Hearts of Iron IV"
HOI4_TAGS_DIR="${HOI4_DIR}/common/country_tags"
HOI4_STATES_DIR="${HOI4_DIR}/history/states"
HOI4_LOCALISATIONS_DIR="${HOI4_DIR}/localisation/english"

HOI4MDM_DIR="${STEAM_WORKSHOP_HOI4_DIR}/2777392649"
HOI4MDM_TAGS_DIR="${HOI4MDM_DIR}/common/country_tags"
HOI4MDM_STATES_DIR="${HOI4MDM_DIR}/history/states"
HOI4MDM_LOCALISATIONS_DIR="${HOI4MDM_DIR}/localisation/english"

HOI4TGW_DIR="${STEAM_WORKSHOP_HOI4_DIR}/699709023"
HOI4TGW_TAGS_DIR="${HOI4TGW_DIR}/common/country_tags"
HOI4TGW_STATES_DIR="${HOI4TGW_DIR}/history/states"
HOI4TGW_LOCALISATIONS_DIR="${HOI4TGW_DIR}/localisation"

IR_DIR="${STEAM_GAMES_DIR}/ImperatorRome"
IR_CULTURES_DIR="${IR_DIR}/game/common/cultures"
IR_LOCALISATIONS_DIR="${IR_DIR}/game/localization/english"
IR_VANILLA_FILE="${VANILLA_FILES_DIR}/ir_province_names.yml"

IR_AoE_DIR="${STEAM_WORKSHOP_IR_DIR}/2578689167"
IR_AoE_CULTURES_DIR="${IR_AoE_DIR}/common/cultures"
IR_AoE_LOCALISATIONS_DIR="${IR_AoE_DIR}/localization/english"
IR_AoE_VANILLA_FILE="${VANILLA_FILES_DIR}/iraoe_province_names.yml"

IR_INV_DIR="${STEAM_WORKSHOP_IR_DIR}/2532715348"
IR_INV_CULTURES_DIR="${IR_INV_DIR}/common/cultures"
IR_INV_LOCALISATIONS_DIR="${IR_INV_DIR}/localization/english"
IR_INV_VANILLA_FILE="${VANILLA_FILES_DIR}/irinv_province_names.yml"

IR_TBA_DIR="${STEAM_WORKSHOP_IR_DIR}/2448788091"
IR_TBA_CULTURES_DIR="${IR_TBA_DIR}/common/cultures"
IR_TBA_LOCALISATIONS_DIR="${IR_TBA_DIR}/localization/english"
IR_TBA_VANILLA_FILE="${VANILLA_FILES_DIR}/irtba_province_names.yml"
