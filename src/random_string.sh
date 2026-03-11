# from: https://github.com/ColasNahaboo/colas-bash-lib
# REQUIRES: dc
# returns a random alphanumeric string of N chars, non-nl-terminated
#   arg#1: the length of the string (default 12)
#   arg#2: the characters to use, with ranges written as a-z or A-Z or 0-9...
#          Defaults to alphanumeric
# LC_ALL=C is mandatory to avoid unicode multibytes messing the randomness
random_string() { 
    LC_ALL=C tr -dc "${2:-a-zA-Z0-9}" < /dev/urandom 2>/dev/null | head -c "${1:-12}"
}
