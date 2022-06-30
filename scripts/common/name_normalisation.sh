#!/bin/bash

TRANSLITERATION_API_URI="http://hmlendea-translit.duckdns.org:9584/Transliteration"

function get-transliteration() {
    RAW_TEXT="${1}"
    LANGUAGE="${2}"
    ENCODED_TEXT=$(echo "${RAW_TEXT}" | python -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read()))")
    TRANSLITERATION_API_ENDPOINT="${TRANSLITERATION_API_URI}?text=${ENCODED_TEXT}&language=${LANGUAGE}"

    curl --silent --insecure --location "${TRANSLITERATION_API_ENDPOINT}" --request GET
}

function transliterate-name() {
    LANGUAGE_CODE="${1}" && shift
    RAW_NAME=$(echo "$*" | \
                sed 's/^"\(.*\)"$/\1/g' | \
                sed 's/^null//g' | \
                sed 's/%0A$//g')
    LATIN_NAME="${RAW_NAME}"

    [ -z "${RAW_NAME}" ] && return

    [ "${LANGUAGE_CODE}" == "ary" ] && LANGUAGE_CODE="ar"
    [ "${LANGUAGE_CODE}" == "arz" ] && LANGUAGE_CODE="ar"
    [ "${LANGUAGE_CODE}" == "be-tarask" ] && LANGUAGE_CODE="be"

    if [ "${LANGUAGE_CODE}" == "ab" ] \
    || [ "${LANGUAGE_CODE}" == "ady" ] \
    || [ "${LANGUAGE_CODE}" == "ar" ] \
    || [ "${LANGUAGE_CODE}" == "ba" ] \
    || [ "${LANGUAGE_CODE}" == "be" ] \
    || [ "${LANGUAGE_CODE}" == "bg" ] \
    || [ "${LANGUAGE_CODE}" == "bn" ] \
    || [ "${LANGUAGE_CODE}" == "cv" ] \
    || [ "${LANGUAGE_CODE}" == "cu" ] \
    || [ "${LANGUAGE_CODE}" == "el" ] \
    || [ "${LANGUAGE_CODE}" == "grc" ] \
    || [ "${LANGUAGE_CODE}" == "gu" ] \
    || [ "${LANGUAGE_CODE}" == "he" ] \
    || [ "${LANGUAGE_CODE}" == "hi" ] \
    || [ "${LANGUAGE_CODE}" == "hy" ] \
    || [ "${LANGUAGE_CODE}" == "hyw" ] \
    || [ "${LANGUAGE_CODE}" == "iu" ] \
    || [ "${LANGUAGE_CODE}" == "ja" ] \
    || [ "${LANGUAGE_CODE}" == "ka" ] \
    || [ "${LANGUAGE_CODE}" == "kk" ] \
    || [ "${LANGUAGE_CODE}" == "kn" ] \
    || [ "${LANGUAGE_CODE}" == "ko" ] \
    || [ "${LANGUAGE_CODE}" == "ky" ] \
    || [ "${LANGUAGE_CODE}" == "mk" ] \
    || [ "${LANGUAGE_CODE}" == "ml" ] \
    || [ "${LANGUAGE_CODE}" == "mn" ] \
    || [ "${LANGUAGE_CODE}" == "mr" ] \
    || [ "${LANGUAGE_CODE}" == "os" ] \
    || [ "${LANGUAGE_CODE}" == "ru" ] \
    || [ "${LANGUAGE_CODE}" == "sa" ] \
    || [ "${LANGUAGE_CODE}" == "si" ] \
    || [ "${LANGUAGE_CODE}" == "sr" ] \
    || [ "${LANGUAGE_CODE}" == "ta" ] \
    || [ "${LANGUAGE_CODE}" == "te" ] \
    || [ "${LANGUAGE_CODE}" == "th" ] \
    || [ "${LANGUAGE_CODE}" == "udm" ] \
    || [ "${LANGUAGE_CODE}" == "uk" ] \
    || [ "${LANGUAGE_CODE}" == "zh" ] \
    || [ "${LANGUAGE_CODE}" == "zh-hans" ]; then
        LATIN_NAME=$(get-transliteration "${RAW_NAME}" "${LANGUAGE_CODE}")
    fi

    echo "${LATIN_NAME}"
}

function normalise-name() {
    local LANGUAGE_CODE="${1}" && shift
    local NAME=$(echo "$*" | \
                    sed 's/^"\(.*\)"$/\1/g' | \
                    awk -F" - " '{print $1}' | \
                    awk -F"/" '{print $1}' | \
                    awk -F"(" '{print $1}' | \
                    awk -F"," '{print $1}' | \
                    sed 's/^\s*//g' | \
                    sed 's/\s*$//g')

    local P_ANCIENT="[Aa]ncient\|Antiikin [Aa]nti[i]*[ck]\(a\|in\)*\|Ar[c]*ha[ií][ac]"
    local P_CANTON="[CcKk][’]*[hy]*[aāe][i]*[nṇ][tṭ][’]*[aoóuū]n\(a\|i\|o\|s\|u[l]*\)*"
    local P_CASTLE="[CcGgKk]a[i]*[sz][lt][ei]*[aál][il]*[eoulmn]*[a]*\|[Cc]h[aâ]teau\|Dvorac\|[Kk]alesi\|Z[aá]m[aeo][gk][y]*"
    local P_CATHEDRAL="[CcKk]at[h]*[eé]dr[ai][kl][aeoó]*[s]*"
    local P_CITY="[CcSs]\(ee\|i\)[tṭ]\+[aàeiy]\|Nagara\|Oraș\(ul\)*\|Śahara\|Sich’i\|[Ss]tadt"
    local P_COMMUNE="[Cc]om[m]*un[ae]\|[Kk]özség"
    local P_COUNCIL="[Cc]o[u]*n[cs][ei]l[l]*\(iul\)\|[Cc]omhairle"
    local P_COUNTRY="[Nn]egeri"
    local P_DEPARTMENT="[DdḌḍ][eéi]p[’]*[aā][i]*r[tṭ][’]*[aei]*m[aeēi][e]*[nṇ]*[gtṭ]*[’]*\(as\|i\|o\|u\(l\|va\)*\)*\|Ilākhe\|Penbiran\|Tuṟai\|Vibhaaga\|Zhang Wàt"
    local P_DIOCESE="[Dd]io[eít][cks][eēi][sz][eēi]*[s]*"
    local P_DISTRICT="[Bb]arrutia\|[Bb]ucağı\|[Dd][iy]str[eiy][ckt]*[akt][eouy]*[als]*\|[Iiİi̇]l[cç]esi\|járás\|Qu\(ận\)*\|[Rr]a[iy]on[iu]\|sum"
    local P_FORT="\([CcKk][aá]str[aou][lm]*\|Festung\|[Ff]ort\(e\(tsya\)*\|ul\)*\|[Ff]ort\(ale[sz]a\|[e]*ress[e]*\)\|[Ff]ort[r]*e[t]*s[s]*[y]*[ae]*\|[Kk]repost\|[Tv]rdina\|[Yy]ōsai\|[Zz]amogy\)\( \(roman\|royale\)\)*"
    local P_GMINA="[Gg][e]*m[e]*in[d]*[ae]"
    local P_HUNDRED="[Hh][äe]r[r]*[ae]d\|[Hh]undred\|[Kk]ihlakunta"
    local P_ISLAND="[Aa]raly\|Đảo\|[Ǧǧ]zīrẗ\|[Ii]l[hl]a\|[Ii]nsula\|[Ii]sl[ae]\|[Ii]sland\|[Îî]le\|[Nn][eḗ]sos\|Ostr[io]v\|Sŏm"
    local P_KINGDOM="guó\|[Kk][eoö]ni[n]*[gk]r[e]*[iy][cej]*[hk]\|K[io]ng[e]*d[oø]m\(met\)*\|[Kk]irályság\|[Kk][o]*r[oa]l\(ev\)*stvo\|Ōkoku\|[Rr]egatul\|[Rr][eo][giy][an][eolu][m]*[e]*\|[Rr]īce\|[Tt]eyrnas"
    local P_LAKE="Gölü\|[Ll]a\(c\|cul\|go\|ke\)\|[Nn][uú][u]*r\|[Oo]zero"
    local P_LANGUAGE="[Bb][h]*[aā][a]*[sṣ][h]*[aā][a]*\|[Ll][l]*[aeií][mn][g]*[buv]*[ao]\(ge\)*"
    local P_MOUNTAIN="[GgHh][ao]ra\|[Mm][ouū][u]*nt[aei]*\([gi]*[ln][e]*\)*\|[Pp]arvata[ṁ]*\|San"
    local P_MONASTERY="[Kk]lo[o]*ster\(is\)*\|[Mm][ăo]n[aăe]st[eèi]r\(e[a]*\|i\|io[a]*\|o\|y\)*\|[Mm]onaĥejo\|[Mm]osteiro\|[Ss]hu[u]*dōin"
    local P_MUNICIPIUM="[Bb]elediyesi\|Chibang Chach’ije\|Chū-tī\|Đô thị tự trị\|[Kk]ong-[Ss]iā\|[Kk]otamadya\|[Mm]eūang\|[Mm][y]*un[i]*[t]*[cs]ip[’]*\([aā]*l[i]*[dtṭ][’]*\(a[ds]\|é\|et’i\|[iī]\|y\)\|i[ou][lm]*\)\|[Nn]agara [Ss]abhāva\|[Nn]a[gk][a]*r[aā]\(pālika\|ṭci\)\|[Pp]ašvaldība\|[Pp][a]*urasabh[āe]\|[Ss]avivaldybė"
    local P_MUNICIPALITY="O[bp]\([čš]\|s[hj]\)[t]*ina"
    local P_NATIONAL_PARK="[Nn]ational [Pp]ark\|Par[cq]u[el] Na[ctț]ional\|[Vv]ườn [Qq]uốc"
    local P_OASIS="[aā]l-[Ww]āḥāt\|[OoÓóŌō][syẏ]*[aáāeē][sz][h]*[aiīeėē][ans]*[uŭ]*\|Oūh Aēy Sít"
    local P_PENINSULA="[Bb][aá]n[ ]*[dđ][aả]o\|[Dd]uoninsulo\|[Hh]antō\|[Ll]edenez\|[Nn]iemimaa\|[Pp][ao][luŭ][ouv]ostr[ao][uŭv]\|[Pp][eé]n[iíì][n]*[t]*[csz][ou][lł][aāe]\|[Pp]enrhyn\|Poàn-tó\|[Ss]emenanjung\|Tīpakaṟpam\|[Yy]arim [Oo]roli\|[Yy]arımadası\|[Žž]arym [Aa]raly"
    local P_PLATEAU="Alt[io]p[il]*[aà]\(no\)*\|Àrd-thìr\|Daichi\|gāoyuán\|Hḍbẗ\|ordokia\|[Pp][’]*lat[’]*[e]*\([aå][nu]\(et\)*\|o\(s[iu]\)*\)\|[Pp]lošina\|[Pp]lynaukštė"
    local P_PREFECTURE="[Pp]r[aäeé][e]*fe[ckt]t[uúū]r[ae]*"
    local P_PROVINCE="Mḥāfẓẗ\|[Pp][’]*r[aāou][bpvw][ëií][nñ][t]*[csz]*[eėiíjoy]*[aeėsz]*\|Pradēśa\|Prānt[a]*\|Rát\|[Ss][h]*[éě]ng\|Shuu\|suyu"
    local P_REGION="Gobolka\|Kwáāen\|[Rr]e[gģhx][ij]*\([oóu][ou]*n*[ei]*[as]*\|st[aā]n\)"
    local P_REPUBLIC="D[eēi]mokr[h]*atía\|Kongwaguk\|Köztársaság\|Kyōwa\|Olómìnira\|[Rr][eéi][s]*[ ]*p[’]*[aāuüùúy][ā’]*b[ba]*l[ií][’]*[ckq][ck]*[’]*\([ai]\|as[ıy]\|en\|[hḥ]y\|i\|ue\)*"
    local P_RUIN="[Rr]uin[ae]*"
    local P_STATE="Bang\|[EeÉé]*[SsŜŝŜŝŠšŞş]*[h]*[tṭ][’]*[aeē][dtṭu][’]*[aeiıosu]*[l]*\|[Oo]st[’]*an[ıi]\|[Uu]stoni\|valstija*"
    local P_TEMPLE="[Dd]ēvālaya\(mu\)*\|[Kk]ōvil\|[Mm][a]*ndir[a]*\|Ná Tiān\|[Pp]agoda\|[Tt]emp[e]*l[eou]*[l]*"
    local P_TOWNSHIP="[CcKk]anton[ae]*\(mendua\)*\|[Tt]ownship"
    local P_UNIVERSITY="[Dd]aigaku\|\(Lā \)*[BbVv]i[sś][h]*[vw]\+\(a[bv]\)*idyāla[yẏ][a]*[ṁ]*\|[Oo]llscoil\|[Uu]niversit\(ate[a]a*\|y\)\|[Vv]idyaapith"

    local P_OF="\([AaĀā]p[h]*[a]*\|[Dd]\|[Dd][aeio][l]*\|gia\|of\|ng\|[Tt]a\|t[ēi]s\|[Tt]o[uy]\|van\|w\)[ \'\"’']"

    local COMMON_PATTERNS="${P_ANCIENT}\|${P_CANTON}\|${P_CASTLE}\|${P_CATHEDRAL}\|${P_CITY}\|${P_COMMUNE}\|${P_COUNCIL}\|${P_COUNTRY}\|${P_DEPARTMENT}\|${P_DIOCESE}\|${P_DISTRICT}\|${P_FORT}\|${P_GMINA}\|${P_HUNDRED}\|${P_ISLAND}\|${P_KINGDOM}\|${P_LAKE}\|${P_LANGUAGE}\|${P_MONASTERY}\|${P_MOUNTAIN}\|${P_MUNICIPIUM}\|${P_MUNICIPALITY}\|${P_NATIONAL_PARK}\|${P_OASIS}\|${P_PENINSULA}\|${P_PLATEAU}\|${P_PREFECTURE}\|${P_PROVINCE}\|${P_REGION}\|${P_REPUBLIC}\|${P_RUIN}\|${P_STATE}\|${P_TEMPLE}\|${P_TOWNSHIP}\|${P_UNIVERSITY}"

    local TRANSLITERATED_NAME=$(transliterate-name "${LANGUAGE_CODE}" "${NAME}")
    local NORMALISED_NAME=$(echo "${TRANSLITERATED_NAME}" | \
        sed 's/^"\(.*\)"$/\1/g' | \
        awk -F" - " '{print $1}' | \
        awk -F"/" '{print $1}' | \
        awk -F"(" '{print $1}' | \
        awk -F"," '{print $1}' | \
        sed \
            -e 's/ *$//g' \
            -e 's/^\([KC]ategor[iy][e]*\)\://g' \
            -e 's/^\([Gg]e*m[ei]+n*t*[aen]\|Faritan'"'"'i\|[Mm]agaalada\) //g' \
            -e 's/^[KkCc]om*un*[ea] d[eio] //g' \
            -e 's/^Lungsod ng //g' \
            \
            -e 's/^ẖ/H̱/g' \
            \
            -e 's/P‍/P/g' \
            -e 's/T‍/T/g' \
            -e 's/p‍/p/g' \
            -e 's/t‍/t/g' \
            \
            -e 's/-i vár$//g' \
            -e 's/'\''i \(krahvkond\|departemang\)$//g' \
            -e 's/'\''i \(krahvkond\|departemang\)$//g' \
            -e 's/'"’"'agang$/’a/g' \
            -e 's/’i\(bando\|sŏm\)$/’i/g' \
            -e 's/[gk]iel[l]*[aâ]$//g' \
            -e 's/\(hyŏn\|sŏm\)$//g' \
            -e 's/\(n\|ṉ\) [Pp]e\(n\|[ṉ]*\)i\(n\|[ṉ]*\)[cs]ulā$//g' \
            -e 's/^[Dd][eḗií]mos \(.*\)oú$/\1ós/g' \
            -e 's/^D //g' \
            -e 's/^Diecezja \(.*\)ska$/\1ia/g' \
            -e 's/^języki \(.*\)skie$/\1ski/g' \
            -e 's/^Półwysep \(.*\)ski$/\1/g' \
            -e 's/a \(fylka\|Śahara\)$//g' \
            -e 's/an Tazovaldkund$//g' \
            -e 's/an[sš]*[cćč]ina$/a/g' \
            -e 's/anis\(ch\|k\)$/a/g' \
            -e 's/ańĭskŭ językŭ$/a/g' \
            -e 's/ans[’]*ka\(ja\)* mova$/a/g' \
            -e 's/as \(vilāj[as]\|mintaka\|meģe\)$/a/g' \
            -e 's/bàn$//g' \
            -e 's/es \('"${P_CANTON}\|${P_MONASTERY}\|${P_MUNICIPIUM}"'\)$/a/g' \
            -e 's/ės \('"${P_MUNICIPIUM}"'\)$/ė/g' \
            -e 's/halvøen$//g' \
            -e 's/hantou$//g' \
            -e 's/hú$//g' \
            -e 's/i[ -]\('"${P_DEPARTMENT}"'\|félsziget\|[Gg]et\|lään\|ringkond\)$//g' \
            -e 's/iin tsöl$//g' \
            -e 's/in \('"${P_HUNDRED}\|${P_PROVINCE}"'\|autiomaa\|lääni\|linna\|niemimaa\)$//g' \
            -e 's/īn Ardhadvīpaya$//g' \
            -e 's/is \('"${P_DISTRICT}"'\)$//g' \
            -e 's/is \('"${P_CANTON}"'\|[Mm]edie\|[Tt]sikhesimagre\)$/i/g' \
            -e 's/janski jazik$/ja/g' \
            -e 's/jas \('"${P_HUNDRED}\|${P_PROVINCE}"'\|grāfiste\|nome\)$/ja/g' \
            -e 's/jos \('"${P_OASIS}\|${P_PROVINCE}"'\|nomas\|pusiasalis\)$/ja/g' \
            -e 's/ko \('"${P_MONASTERY}\|${P_PROVINCE}"'\|konderria\)$//g' \
            -e 's/maṇḍalam$//g' \
            -e 's/n \(kreivi\|piiri\)*kunta$//g' \
            -e 's/n dili$//g' \
            -e 's/n kieli$//g' \
            -e 's/na \('"${P_KINGDOM}"'\)$//g' \
            -e 's/nag ævzag$//g' \
            -e 's/nski ezik$//g' \
            -e 's/nūrs$//g' \
            -e 's/o \(apskritis\|emyratas\|grafystė\|plynaukštė\|provincija\)$/as/g' \
            -e 's/o[s]* \(pusiasalis\|vilaja\)$/as/g' \
            -e 's/ørkenen$/a/g' \
            -e 's/s \('"${P_DISTRICT}\|${P_HUNDRED}"'\|län\|nom[ae]\|rajons\)$//g' \
            -e 's/s’ka\(ya\)* \('"${P_FORT}"'\)$/a/g' \
            -e 's/s[’]*k[iy]y p\(i\|ol\)[uv]ostr[io]v$//g' \
            -e 's/shitii$//g' \
            -e 's/sk[aá] \(poušť\|župa.*\)$/sko/g' \
            -e 's/sk[iý] \('"${P_PENINSULA}"'\|sayuz\)$//g' \
            -e 's/skagi$//g' \
            -e 's/skaya oblast[’]*$/sk/g' \
            -e 's/ske \(gŏdki\|rěče\)$/ska/g' \
            -e 's/skiy kaganat$/iya/g' \
            -e 's/vsk[ai] [Pp]lanin[ai]$/vo/g' \
            -e 's/x žudecs$/a/g' \
            -e 's/ý polostrov$/o/g' \
            -e 's/yanskiy[e]* \(yazyk[i]*\)$/ya/g' \
            -e 's/yn khoig$//g' \
            \
            -e 's/\('"${P_KINGDOM}"'\|'"${P_OASIS}"'\)$//g' \
            \
            \
            -e 's/^Hl\. /Heilige /g' \
            -e 's/ mfiadini$/ Mfiadini/g' \
            \
            \
            -e 's/n-a$/na/g' \
            \
            -e 's/ norte$/ Norte/g' \
            -e 's/ septentrionale$/ Septentrionale/g' \
            \
            -e 's/\([^\s]\)-\s*/\1-/g' \
            -e 's/[·]//g' \
            -e 's/\(.\)\1\1/\1\1/g' \
            -e 's/^\s*//g' \
            -e 's/\s*$//g' \
            -e 's/\s\s*/ /g')

        NORMALISED_NAME=$(sed 's/'"${COMMON_PATTERNS}"'//g' <<< "${NORMALISED_NAME}")

        NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | \
            perl -p0e 's/\r*\n/ /g' | \
            sed \
                -e 's/\s\s*/ /g' \
                -e 's/^\s*//g' \
                -e 's/\s*$//g')

        if [ "${LANGUAGE_CODE}" != "ar" ] && \
           [ "${LANGUAGE_CODE}" != "ga" ] && \
           [ "${LANGUAGE_CODE}" != "jam" ] && \
           [ "${LANGUAGE_CODE}" != "jbo" ]; then
            NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^\([a-z]\)/\U\1/g')
        fi

        [ "${LANGUAGE_CODE}" == "kaa" ] && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed "s/U'/Ú/g")
        [ "${LANGUAGE_CODE}" == "lt" ]  && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^Šv\./Šventasis/g')
        [ "${LANGUAGE_CODE}" == "zh" ]  && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/-//g')
        [ "${LANGUAGE_CODE}" == "ang" ] && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/enrice$/e/g')

        NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^L'"'"'/l'"'"'/g')

        echo "${NORMALISED_NAME}"
}

function nameToLocationId() {
    local NAME="${1}"

    echo "${NAME}" | sed \
            -e 's/æ/ae/g' \
            -e 's/\([ČčŠšŽž]\)/\1h/g' \
            -e 's/[Ǧǧ]/j/g' | \
        iconv -f utf8 -t ascii//TRANSLIT | \
        sed 's/-le-/_le_/g' | \
        sed 's/ /_/g' | sed "s/\'//g" | \
        sed 's/['"\'"']//g' | sed "s/\'//g" | \
        sed 's/\(north\|west\|south\|east\)ern/\1/g' | \
        sed 's/^\(north\|west\|south\|east\)_\(.*\)$/\2_\1/g' | \
        tr '[:upper:]' '[:lower:]'
}

function locationIdToSearcheableId() {
    local LOCATION_ID="${1}"

    echo "${LOCATION_ID}" | sed \
        -e 's/^[ekdcb]_//g' \
        -e 's/[_-]//g' \
        -e 's/\(baron\|castle\|church\|city\|fort\|temple\|town\)//g'
}
