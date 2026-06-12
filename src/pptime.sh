# shellcheck shell=bash
################ pptime functions
#
# pptime duration-in-seconds
# prints on its stdout a human-friendly form of the duration
# pptime
# prints on its stdout a human-friendly form of (now - $ppstart) seconds
# if $ppstart is not yet defined, just sets it to now and print nothing
# E.g:
#   pptime 57689243 ==> 27d4h47m23s
#   pptime 666      ==> 11m6s
# You can define pptimesep as the separator:
#   pptimesep=' '
#   pptime 57689243 ==> 27d 4h 47m 23s
#   pptime 666      ==> 11m 6s
# You can define ppformat as '02' to have numbers printed with at least 2 digits
#   ppformat='02'
#   pptime 57689243 ==> 27d04h47m23s
#   pptime 666      ==> 11m06s
# default is to not use 2 digits for the first number, e.g:
#   9h02s, 2s, 3d09h02s

# Choose options to declare as global vars in your script
pptimesep=' '
pptimesep=''

ppformat='02'
ppformat=''

pptime(){
    local v="$1" d h m s pf="$ppformat"
    if [[ -z "$v" ]]; then
        if [[ -z "$ppstart" ]]; then ppstart=$(date +%s); return; fi
        ((v = $(date +%s) - ppstart))
    fi
    ((s = v % 60)); ((v = v / 60)); ((m = v % 60)); ((v = v / 60))
    ((h = v % 60)); ((v = v / 60)); ((d = v % 60))
    (( d > 0 )) && { printf "%${pf}dd$pptimesep" "$d"; pf=02;}
    (( h > 0 )) && { printf "%${pf}dh$pptimesep" "$h"; pf=02;}
    (( m > 0 )) && { printf "%${pf}dm$pptimesep" "$m"; pf=02;}
    printf "%${ppformat}ds$pptimesep\n" "$s"
}
