# shellcheck shell=bash
################ ascii / character conversions
# These functions convert to and from the ascii numeric value of a character
# they are inpired from the bash FAQ at http://mywiki.wooledge.org/BashFAQ/071

# Each of these functions are independent and can be copied into your code.
# They are pure bash, and the fastest code I could manage (no forks).
# Their code is compacted so that they visually appear as "black boxes"
# in bash scripts to differentiate them from the "regular" code.

# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh

######## "set" forms
# these functions store the result into their first argument that must be
# a variable. My favorite form, as they are twice as fast as the functional ones

# set_i2a var integer: sets "var" to character of ascii code "integer"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh v1
set_i2a() {
    local -n _v="$1"
    printf -v _v %o "$2"
    # shellcheck disable=SC2059 # yes, we must use vars in format
    printf -v _v "\\$_v"
}

# set_a2i var char: sets "var" to ascii value of character "char"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh v1
set_a2i(){
    local -n _v="$1"
    LC_CTYPE=C printf -v _v %d "'$2"
}

# set_x2a var hex: sets "var" to character of ascii hexadecimal value "hex"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh v1
set_x2a(){
    local -n _v="$1"
    # shellcheck disable=SC2059 # yes, we must use vars in format
    printf -v _v "\\x$2"
}

# set_a2x var char: sets "var" to hexadecimal ascii value of character "char"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh v1
set_a2x() {
    local -n _v="$1"
    LC_CTYPE=C printf -v _v %x "'$2"
}

######## "functional" forms
# these functions print the result into the stdout, in the traditional way.

# i2a integer: print character of ascii code "integer"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh v1
i2a() {
    local v
    printf -v v %o "$1"
    # shellcheck disable=SC2059 # yes, we must use vars in format
    printf "\\$v"
}

# a2i char: print ascii value of character "char"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh v1
a2i(){
    LC_CTYPE=C printf %d "'$1"
}

# x2a hex: print character of ascii hexadecimal value "hex"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh v1
x2a(){
    # shellcheck disable=SC2059 # yes, we must use vars in format
    printf "\\x$1"
}

# a2x char: print hexadecimal ascii value of character "char"
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/ascii.sh v1
a2x() {
    LC_CTYPE=C printf %x "'$1"
}
