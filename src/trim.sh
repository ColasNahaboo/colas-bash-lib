# shellcheck shell=bash
################ trim_quote functions
# trim (removes) the white space at the start or at the end of a string
# Algorithm used:
# Suppose we have a string s="   x "
# ${s%%[![:space:]]*} removes everything after the first non-space character
# including it: "x ". This expression, lets call it s1 consists then in the
# leading spaces "   ".
# ${s#$s1} then removes this leading spaces from s, the result, s2 is s
# trimmed on the left.
# We then do the same thing to remove the trailing spaces:
# s3=${s2##*[![:space:]]} are the trailing spaces
# ${s2%$s3} is the string s trtimmed on both sides.

# Each of these functions are independent and can be copied into your code.
# They are pure bash, and the fastest code I could manage (no forks).
# Also they turn of the debugging options (set -xv) during their execution
# to avoid polluting your debug traces with their mundane code, by the
# statements "local -; set +xve;" at their start.

# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/trim.sh

######## "set" forms
# these functions store the result into their first argument that must be
# a variable. My favorite form, as they are twice as fast as the functional ones
# Usage: set_trim trimmed_string "$string"
# E.g: set_trim ts "  a b   "; echo "[$ts]" ==> "[a b]"

# sets the variable in 1rst arg to the 2nd arg string with spaces removed
# from start and end
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/trim.sh v1
set_trim(){
    local -; set +xve
    local -n _v="$1"
    _v="$2"
    _v="${2#"${_v%%[![:space:]]*}"}"
    _v="${_v%"${_v##*[![:space:]]}"}"
}

######## "var" in place forms
# these functions modify in place their argument, a variable with a string value

# removes in place the spaces from start and end of the string value of the
# variable argument
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/trim.sh v1
var_trim(){
    local -; set +xve
    local -n _v="$1"
    _v="${_v#"${_v%%[![:space:]]*}"}"
    _v="${_v%"${_v##*[![:space:]]}"}"
}

######## "functional" forms
# these functions print the result into the stdout, in the traditional way.

# removes the spaces from start and end of the string argument
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/trim.sh v1
trim(){
    local -; set +xve
    local v="$1"
    v="${v#"${v%%[![:space:]]*}"}"
    v="${v%"${v##*[![:space:]]}"}"
    echo "$v"
}
