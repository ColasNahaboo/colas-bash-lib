# escape special chars & < > " ' for using strings in HTML
# pure bash
htmlencode() {
    local str="${1//&/\&amp;}"; str="${str//</\&lt;}"; str="${str//>/\&gt;}"
    str="${str//\"/\&quot;}"; echo "${str//\'/\&#39;}"
}

# reverse of htmlencode
htmldecode() {
    local str="${1//&#39;/\'}"; str="${str//\&quot;/\"}"
    str="${str//\&gt;/>}"; str="${str//\&lt;/<}"; echo "${str//\&amp;/\&}"
}

# decodes the %XX url encoding in $1, same as urlencode -d
# but faster for small strings as pure bash
# removes carriage returns to force unix newlines, converts + into space
urldecode() {
    local v="${1//+/ }" d r=''
    while [ -n "$v" ]; do
        if [[ $v =~ ^([^%]*)%([0-9a-fA-F][0-9a-fA-F])(.*)$ ]]; then
            eval d="\$'\x${BASH_REMATCH[2]}'"
	    [ "$d" = "$cr" ] && d=
            r="$r${BASH_REMATCH[1]}$d"
            v="${BASH_REMATCH[3]}"
        else
            r="$r$v"
            break
        fi
    done
    echo "$r"
}

# the reverse of urldecode above
urlencode() {
    local length="${#1}" i c
    for (( i = 0; i < length; i++ )); do
        c="${1:i:1}"
        case $c in
            [a-zA-Z0-9,.~_-]) echo -n "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
}
