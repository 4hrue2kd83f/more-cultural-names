#!/bin/bash
source "scripts/common/paths.sh"

BUILD_VERSION="${1}"

if [ -z "${BUILD_VERSION}" ] || ! [[ ${BUILD_VERSION} =~ ^[0-9]+$ ]]; then
    BUILD_VERSION=0
fi

VERSION=$(date +"%y").$(date +"%j").${BUILD_VERSION}

if [[ $* != *--skip-updates* ]]; then
    bash "${SCRIPTS_DIR}/update-builder.sh"
    bash "${SCRIPTS_DIR}/update-vanilla-files.sh"
fi

if [[ $* != *--skip-validation* ]]; then
    echo "Validating the files..."
    VALIDATE_DATA="$(bash scripts/validate-data.sh | tr '\0' '\n')"
    if [ -n "${VALIDATE_DATA}" ]; then
        echo "Input files validation failed!"
        echo "${VALIDATE_DATA}"
        exit 1
    fi
fi

function build-edition {
    ID="${1}" && shift
    NAME="${1}" && shift
    GAME="${1}" && shift
    GAME_VERSION="${1}" && shift

    PACKAGE_NAME="mcn_${GAME}_${VERSION}"
    ORIGINAL_WORKING_DIRECTORY=$(pwd)

    [ -d "${OUTPUT_DIR}/${GAME}" ] && rm -rf "${OUTPUT_DIR:?}/${GAME:?}"
    [ -f "${OUTPUT_DIR}/${PACKAGE_NAME}.zip" ] && rm "${OUTPUT_DIR}/${PACKAGE_NAME}.zip"

    cd "${REPO_DIR}"
    "${REPO_DIR}/.builder/MoreCulturalNamesBuilder" \
        --lang "${LANGUAGES_FILE}" \
        --loc "${LOCATIONS_FILE}" \
        --titles "${TITLES_FILE}" \
        --game "${GAME}" --game-version "${GAME_VERSION}" \
        --id "${ID}" --name "${NAME}" --ver "${VERSION}" \
        --out "${OUTPUT_DIR}" "$@"

    if [ ! -d "${OUTPUT_DIR}/${GAME}/" ]; then
        echo "   > ERROR: Failed to build the ${GAME} edition!"
        exit 200
    fi

    echo "   > Copying extras..."
    cp -rf "${EXTRAS_DIR}/${GAME}"/* "${OUTPUT_DIR}/${GAME}/"

    echo "   > Building the package..."
    cd "${OUTPUT_DIR}/${GAME}"
    zip -q -r "${PACKAGE_NAME}.zip" ./*
    mv "${PACKAGE_NAME}.zip" "${OUTPUT_DIR}/${PACKAGE_NAME}.zip"

    cd "${ORIGINAL_WORKING_DIRECTORY}"
}

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "CK2" "3.3.5.1" \
    --landed-titles "${VANILLA_FILES_DIR}/ck2_landed_titles.txt" --landed-titles-name "landed_titles.txt"

build-edition \
    "hip-more-cultural-names" "HIP - More Cultural Names" \
    "CK2HIP" "Frosty3" \
    --landed-titles "${VANILLA_FILES_DIR}/ck2hip_landed_titles.txt" --landed-titles-name "swmh_landed_titles.txt" \
    --dep "HIP - Historical Immersion Project"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "CK3" "1.5.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3_landed_titles.txt" --landed-titles-name "999_MoreCulturalNames.txt"

build-edition \
    "atha-more-cultural-names" "Apotheosis: More Cultural Names" \
    "CK3ATHA" "1.5.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3atha_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "ibl-more-cultural-names" "Ibn Battuta's Legacy 2 - More Cultural Names" \
    "CK3IBL" "1.5.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3ibl_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "mbp-more-cultural-names" "More Bookmarks+ - More Cultural Names" \
    "CK3MBP" "1.5.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3mbp_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "tfe-more-cultural-names" "The Fallen Eagle: More Cultural Names" \
    "CK3TFE" "1.4.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3tfe_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "HOI4" "1.11.*"

build-edition \
    "tgw-more-cultural-names" "The Great War: More Cultural Names" \
    "HOI4TGW" "1.11.*"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "IR" "2.0.*"

build-edition \
    "aoe-more-cultural-names" "Ashes of Empire: More Cultural Names" \
    "IR_AoE" "2.0.*"

cd "${REPO_DIR}"
bash "${REPO_DIR}/scripts/count-localisations.sh"

echo ""
echo "Mod version: ${VERSION}"
