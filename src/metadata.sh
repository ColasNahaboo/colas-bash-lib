# from: https://github.com/ColasNahaboo/colas-bash-lib
# metadata are stored in memory as associative arrays key,values

# normal metas are human friendly: key value or key: value
# continuations lines permit newlines in values, and start with space or :
# empty lines and comments starting with # are allowed
# all comment lines are collapsed into the value of the '#' key
meta-read(){
    local file="$1"  _metaname="${2:-metas}" last_key key value _meta
    declare -gA "$_metaname"        # ensure it is globally created as AA
    local -n _meta="$_metaname"
    while IFS= read -r line; do
        (( ${#line} == 0 )) && continue
        if [[ $line =~ ^[:[:space:]][[:space:]]*(.*)$ ]]; then
            # If line starts with : or space, append to the last key's value
            _meta["$last_key"]+=$'\n'"${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^([^:[:space:]]+)[:[:space:]][[:space:]]*(.*)$ ]]; then
            # Otherwise, split by the first colon or space
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            if [[ "$key" == '#' ]]; then # regroup all comments under key '#'
                [[ -n "${_meta[#]}" ]] && _meta[#]+=$'\n'
                _meta[#]+="$value"
            else
                _meta["$key"]="$value"
                last_key="$key"
            fi
        fi
    done <"$file"
}

meta-write(){
    local file="$1" _meta key value
    declare -n _meta="$2"
    for key in "${!_meta[@]}"; do
        value="${_meta[$key]}"
        if [[ "$key" == '#' ]]; then
            echo "$key ${value//$'\n'/$'\n'# }"
        else
            echo "$key: ${value//$'\n'/$'\n' }"
        fi
    done >"$file"
}

# raw meta files: super efficient, but not very human friendly
# we use the native marsdhalling of data built-in into bash: declare -p
# reads metadata from "raw" file $1, info array named $2" (defaults to "metas")
# the metadata file is a declaration of a global associative array named metas
meta-read-raw(){
    local file="$1" metaname="$2"
    if [[ -n "$metaname" ]]; then
        # To rename the arra, swap the name in a temporary file and source it
        local tmp="/tmp/meta-raw.$$"
        sed "1s/^declare -Ag metas=/declare -Ag $metaname=/" "$file" > "$tmp"
        source "$tmp"
        rm "$tmp"
    else                        # default name is faster
        source "$file"
    fi
}

# $1=file $2=metadata array name, default  "metas"
# We need to force the declaration to have global scope (with "g" option
# Otherwise sourcing the file inside a function will not work
meta-write-raw(){
    local file="$1" name="${2:-metas}"
    declare -p "$name" |
        sed "1s/^declare -A $name=/declare -Ag metas=/" >"$file"
}
