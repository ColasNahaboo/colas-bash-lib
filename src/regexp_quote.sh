# shellcheck shell=bash
################ regexp_quote functions
# These functions quote a regular expression, maing it match literally.
# This is very useful when you want to match a regular expression
# with some parts matching literally, parts matching as regexps.
# E.g: Email:[[:space:]]*$(quote_regexp "$email")
# allows to match lines in the form "Email:  an-user-email" with any number
# of spaces (regepx matching), but mayching literally the special characters
# in the email address (such as "." or "+")
#
# The "nocase" variant matches letters in a case-independent way
# E.g: regexp_quote_nocase 'ab.c' ==> [aA][bB][.][cC]
# regexp_quote 'ab.c' ==> ab[.]c

# Each of these functions are independent and can be copied into your code.
# They are pure bash, and the fastest code I could manage (no forks).
# Their code is compacted so that they visually appear as "black boxes"
# in bash scripts to differentiate them from the "regular" code.
# Also they turn of the debugging options (set -xv) during their execution
# to avoid polluting your debug traces with their mundane code, by the
# statements "local -; set +xve;" at their start.

# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_quote.sh

######## "set" forms
# these functions store the result into their first argument that must be
# a variable. My favorite form, as they are twice as fast as the functional ones
# Usage: set_quote_regexp quoted_re "$re"
# E.g: set_quote_regexp quoted_re "a*b"; echo "$quoted_re" ==> "a[*]b"

# sets the variable in 1rst arg to the quoted 2nd arg string for regexp use,
# quotes also / for safe use in sed /.../
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_quote.sh v1
set_regexp_quote(){ local -; set +xve; local -n _qs="$1"
  local i c len="${#2}"; _qs=; for (( i=0; i<len; i++ ));do
  c="${2:i:1}";case "$c" in [^][{}?*\|+.$\\\(\)/^])_qs+="$c";;'^')_qs+='\^';;
  *)_qs+="[$c]";;esac;done
}

# quote the 2nd arg string for regexp use, in a case insensitive way
# sets the results into the variable first argument
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_quote.sh v1
set_regexp_quote_nocase(){ local -; set +xve; local -n _qs="$1"
  local i c len="${#2}"; _qs=; for (( i=0; i<len; i++ ));do
  c="${2:i:1}";case "$c" in [[:alpha:]])_qs+="[${c,}${c^}]";;
  [^][{}?*\|+.$\\\(\)/^])_qs+="$c";;'^')_qs+='\^';;*)_qs+="[$c]";;
  esac;done
}

# appends to the variable in 1rst arg to the quoted 2nd arg for regexp use,
# quotes also / for safe use in sed /.../
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_quote.sh v1
add_regexp_quote(){ local -; set +xve; local -n _qs="$1"
  local i c len="${#2}";for (( i=0; i<len; i++ ));do
  c="${2:i:1}";case "$c" in [^][{}?*\|+.$\\\(\)/^])_qs+="$c";;'^')_qs+='\^';;
  *)_qs+="[$c]";;esac;done
}

# quote the 2nd arg string for regexp use, in a case insensitive way
# appends the results into first argument
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_quote.sh v1
add_regexp_quote_nocase(){ local -; set +xve; local -n _qs="$1"
  local i c len="${#2}"; for (( i=0; i<len; i++ ));do
  c="${2:i:1}";case "$c" in [[:alpha:]])_qs+="[${c,}${c^}]";;
  [^][{}?*\|+.$\\\(\)/^])_qs+="$c";;'^')_qs+='\^';;*)_qs+="[$c]";;
  esac;done
}

######## "functional" forms
# these functions print the result into the stdout, in the traditional way.
# Usage: quoted_re=$(quote_regexp "$re")
# E.g: quote_regexp "a*b" ==> "a[*]b"

# quote the argument string for regexp use, and prints them on stdout
# quotes also / for safe use in sed /.../
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_quote.sh v1
regexp_quote(){ local -; set +xve
  local i c len="${#1}" r; for (( i=0; i<len; i++ ));do
  c="${1:i:1}";case "$c" in [^][{}?*\|+.$\\\(\)/^])r+="$c";;'^')r+='\^';;
  *)r+="[$c]";;esac;done; echo "$r"
}

# quote the arg string for regexp use, case insensitive version
# from: https://github.com/ColasNahaboo/colas-bash-lib/blob/main/lib/regexp_quote.sh v1
regexp_quote_nocase(){ local -; set +xve
  local i r c len="${#1}";for (( i=0; i<len; i++ ));do
  c="${1:i:1}";case "$c" in [[:alpha:]])r+="[${c,}${c^}]";;
  [^][{}?*\|+.$\\\(\)/^])r+="$c";;'^')r+='\^';;*)r+="[$c]";;
  esac;done;echo "$r"
}
