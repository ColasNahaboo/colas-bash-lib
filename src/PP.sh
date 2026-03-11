############ PP print-debugging
# Crude debugging: prints args to logfile "$PPLOG", (empty = stdout)
# If an arg is -t, switch to trace mode: the following arguments will be
# taken as variable names whose values will be printed
# -v (defaut) reset prints mode to normal, printing to $PPSTD
# PPT is a shortcut to PP -t.
# E.g: PP after scan: -t foo bar  ==> after scan: foo=a bar='a and b'

# Uncomment the line below to redirect PP functions to a file
# export PPLOG=/tmp/PPLOG

# Uncomment the line below to redirect PP functions to stderr
# export PPSTD=2

# The user-level functions: PPT & PP
PPT(){ PP -t "$@";}
PP(){
    local _arg _mode _info _sep
    local -
    for _arg in "$@"; do
        case "$_arg" in
            '-t') _mode=t; continue;;
            '-v') _mode=v; continue;;
        esac
        PPV "$_sep"
        if [[ "$_mode" == t ]]; then
            local __desc=$(declare -p "$_arg" 2>/dev/null)
            if [[ -z "$__desc" ]]; then
                PPV "$_arg!"
            else
                local __attr=$(echo "$__desc" | cut -d' ' -f2 | sed 's/-//')
                # If no flag was found, it's a scalar
                case "$__attr" in
                    A) PPV "$_arg=("; PPAA "$_arg"; PPV ')';;
                    a) PPV "$_arg=("; PPIA "$_arg"; PPV ')';;
                    *) PPV "$_arg="; PPV "$(printf %q "${!_arg}")";;
                esac
            fi
        else
            PPQ "$_arg"
        fi
        _sep=' '
    done
    PPN ''
}

# PPV is the low-level I/O, that can be redefined to output on other devices
PPV(){
    [[ -n "$PPLOG" ]] &&
        echo -n "${1}" >>"$PPLOG" ||
            echo -n "${1}" >&"${PPSTD:-1}"
}

# handle Associative Arrays
PPAA() {
    local -n _array=$1  # Creates a reference to the array name passed
    local _key
    for _key in "${!_array[@]}"; do
        PPV "[$_key]="; PPQ "${_array[$_key]}"; PPV ' '
    done
}
# handle Indexed Arrays
PPIA() {
    local -n _array=$1  # Creates a reference to the array name passed
    local val
    for val in "${!_array[@]}"; do
        PPQ "${_array[val]}"; PPV ' '
    done
}
# convenience: PPV with terminating newline
PPN(){ PPV "$1"$'\n';}
# convenience: PPV quoting its argument
PPQ(){ PPV "$(printf %q "$1")";}
