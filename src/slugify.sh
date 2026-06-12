# A slug is a string of hyphens and lower case letters
# We remove accents and replace non-letters by hypens

# This version is pure bash, but only works for common accented Latin
# characters in the western european languages

slugify-latin(){
    local name="$1"
    local n="$(strip-accents "${name,,}")" s
    [[ $n =~ ^[^[:lower:][:digit:]]+(.*)$ ]] &&
        n="${BASH_REMATCH[1]}" # skip leading -
    while [[ $n =~ ^([[:lower:][:digit:]]+)([^[:lower:][:digit:]]*)(.*)$ ]]; do
        s="${s}${BASH_REMATCH[1]}-"
        n="${BASH_REMATCH[3]}"
    done
    echo "${s%-}"

}

strip-accents() {
    local s="$1"
    s=${s//à/a}; s=${s//á/a}; s=${s//â/a}; s=${s//ä/a}; s=${s//ã/a}; s=${s//å/a}
    s=${s//À/A}; s=${s//Á/A}; s=${s//Â/A}; s=${s//Ä/A}; s=${s//Ã/A}; s=${s//Å/A}
    s=${s//è/e}; s=${s//é/e}; s=${s//ê/e}; s=${s//ë/e}
    s=${s//È/E}; s=${s//É/E}; s=${s//Ê/E}; s=${s//Ë/E}
    s=${s//ì/i}; s=${s//í/i}; s=${s//î/i}; s=${s//ï/i}
    s=${s//Ì/I}; s=${s//Í/I}; s=${s//Î/I}; s=${s//Ï/I}
    s=${s//ò/o}; s=${s//ó/o}; s=${s//ô/o}; s=${s//ö/o}; s=${s//õ/o}
    s=${s//Ò/O}; s=${s//Ó/O}; s=${s//Ô/O}; s=${s//Ö/O}; s=${s//Õ/O}
    s=${s//ù/u}; s=${s//ú/u}; s=${s//û/u}; s=${s//ü/u}
    s=${s//Ù/U}; s=${s//Ú/U}; s=${s//Û/U}; s=${s//Ü/U}
    s=${s//ç/c}; s=${s//Ç/C}
    s=${s//ñ/n}; s=${s//Ñ/N}
    printf '%s\n' "$s"
}

# This version needs "iconv", but should work in all languages

slugify(){
    local name="$1"
    local n="$(iconv -f UTF-8 -t ASCII//TRANSLIT <<<"${name,,}")" s
    [[ $n =~ ^[^[:lower:][:digit:]]+(.*)$ ]] &&
        n="${BASH_REMATCH[1]}" # skip leading -
    while [[ $n =~ ^([[:lower:][:digit:]]+)([^[:lower:][:digit:]]*)(.*)$ ]]; do
        s="${s}${BASH_REMATCH[1]}-"
        n="${BASH_REMATCH[3]}"
    done
    echo "${s%-}"
}
