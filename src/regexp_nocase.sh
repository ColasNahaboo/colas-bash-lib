# shellcheck shell=bash
################ regexp_nocase functions
# These functions transform a regular expression to make it match in a
# case-independent way.
# This is very useful when you want to match a regular expression
# with some parts matching with case, and others not, because bash lacks
# inline regepx modifiers such as (?i).
# E.g: Email:[[:space:]]*$(nocase_regexp "$email")
# allows to match lines in the form "Email:  an-user-email" with the exact
# case for "Email" but case-independent for the email itself.
# It parses the regepx via a state machine with 3 states:
# 0=main(toplevel) 1=starting a char group([) 2=in a char group([abc])

# Each of these functions are independent and can be copied into your code.
# They are pure bash, and the fastest code I could manage (no forks).
# Also they turn of the debugging options (set -xv) during their execution
# to avoid polluting your debug traces with their mundane code, by the
# statements "local -; set +xv;" at their start.

# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_nocase.sh

######## "set" forms
# this function store the result of "nocase-ing" the 2nd regexp argument
# into their first argument that must be a variable.
# Returns error code if could not parse regexp
# My favorite form, as it is the fastest form in bash.

# sets in 1st arg the 2nd arg regexp transformed to be case-insensitive
# Usage: set_regexp_nocase rei "$re"
# E.g: set_regexp_nocase rei "a*B"; echo "$rei" ==> "[aA]*[bB]"
#      x[a-e[:space:][:upper:]]y ==> [xX][a-eA-E[:space:][:alpha:]][yY]
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_nocase.sh v1
set_regexp_nocase(){
    local -; set +xv
    local -n _re="$1"; _re=
    local cre="$2" c chars ce prechar postchar notchar
    local -i i len=${#2} state=0
    for (( i=0; i<len; i++ ));do
        c="${cre:i:1}"
        if ((state == 0)); then # 0 state: main
            if [[ $c == '[' ]]; then
                ((state=1))
                notchar=
                chars=
            elif [[ $c =~ [[:alpha:]] ]]; then
                _re+="[${c,}${c^}]"
            elif [[ $c == \\ ]]; then
                ce="${cre:i+1:1}"
                if [[ $ce =~ [[:alpha:]] ]]; then
                    _re+="[${ce,}${ce^}]"
                else
                    _re+="\\$ce"
                fi
                ((++i))
            else
                _re+="$c"
            fi
        elif ((state == 1)) && [[ $c == '^' ]] ; then # 1 state: chars-start [
            notchar='^'
            ((state=2))
        elif ((state == 2)) && [[ $c == ']' ]]; then
            #  build the char range
            _re+="[$notchar$prechar$chars$postchar]"
            ((state=0))
        elif ((state == 2)) || ((state == 1)); then # 2 state: chars [...]
            if [[ ${cre:i:3} =~ ^[[:alpha:]]-[[:alpha:]]$ ]]; then
                ce="${cre:i+2:1}"
                chars+="${c,}-${ce,}${c^}-${ce^}"
                ((i+=2))
            elif [[ ${cre:i:12} =~ ^([[]:[[:lower:]]{4,8}:[]]) ]]; then
                ce="${BASH_REMATCH[1]}"
                if [[ $ce == '[:lower:]' ]] || [[ $ce == '[:upper:]' ]]; then
                    ce='[:alpha:]'
                fi
                chars+="$ce"
                ((i+=${#ce}-1))
            elif [[ $c =~ [[:alpha:]] ]]; then
                chars+="${c,}${c^}"
            elif [[ $c == ']' ]]; then
                prechar=']'
            elif [[ $c == '-' ]]; then
                postchar='-'
            else
                chars+="$c"
            fi
            ((state=2))
        fi
    done
    # if we do not end at toplevel "main" state, expression was badly formed
    return "$state"
}

######## "functional" forms
# these functions print the result into the stdout, in the traditional way.

# prints regexp regexp transformed to be case-insensitive
# E.g: rei=$(regexp_nocase "a*B"); echo "$rei" ==> "[aA]*[bB]"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_nocase.sh v1
regexp_nocase(){
    local -; set +xv
    local _re=
    local cre="$1" c chars ce prechar postchar notchar
    local -i i len=${#1} state=0
    for (( i=0; i<len; i++ ));do
        c="${cre:i:1}"
        if ((state == 0)); then # 0 state: main
            if [[ $c == '[' ]]; then
                ((state=1))
                notchar=
                chars=
            elif [[ $c =~ [[:alpha:]] ]]; then
                _re+="[${c,}${c^}]"
            elif [[ $c == \\ ]]; then
                ce="${cre:i+1:1}"
                if [[ $ce =~ [[:alpha:]] ]]; then
                    _re+="[${ce,}${ce^}]"
                else
                    _re+="\\$ce"
                fi
                ((++i))
            else
                _re+="$c"
            fi
        elif ((state == 1)) && [[ $c == '^' ]] ; then # 1 state: chars-start [
            notchar='^'
            ((state=2))
        elif ((state == 2)) && [[ $c == ']' ]]; then
            #  build the char range
            _re+="[$notchar$prechar$chars$postchar]"
            ((state=0))
        elif ((state == 2)) || ((state == 1)); then # 2 state: chars [...]
            if [[ ${cre:i:3} =~ ^[[:alpha:]]-[[:alpha:]]$ ]]; then
                ce="${cre:i+2:1}"
                chars+="${c,}-${ce,}${c^}-${ce^}"
                ((i+=2))
            elif [[ ${cre:i:12} =~ ^([[]:[[:lower:]]{4,8}:[]]) ]]; then
                ce="${BASH_REMATCH[1]}"
                if [[ $ce == '[:lower:]' ]] || [[ $ce == '[:upper:]' ]]; then
                    ce='[:alpha:]'
                fi
                chars+="$ce"
                ((i+=${#ce}-1))
            elif [[ $c =~ [[:alpha:]] ]]; then
                chars+="${c,}${c^}"
            elif [[ $c == ']' ]]; then
                prechar=']'
            elif [[ $c == '-' ]]; then
                postchar='-'
            else
                chars+="$c"
            fi
            ((state=2))
        fi
    done
    echo "$_re"
    # if we do not end at toplevel "main" state, expression was badly formed
    return "$state"
}
