# shellcheck shell=bash
################ pptime functions
#
# pptime duration-in-seconds
# prints on its stdout a human-friendly form of the duration
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

# Choose options to declare as global vars in your script
pptimesep=' '
pptimesep=''

ppformat='02'
ppformat=''

pptime(){
    local v="$1" d h m s
    ((s = v % 60)); ((v = v / 60))
    ((m = v % 60)); ((v = v / 60))
    ((h = v % 60)); ((v = v / 60))
    ((d = v % 60))
    (( d > 0 )) && printf "%${ppformat}dd$pptimesep" "$d"
    (( h > 0 )) && printf "%${ppformat}dh$pptimesep" "$h"
    (( m > 0 )) && printf "%${ppformat}dm$pptimesep" "$m"
    printf "%${ppformat}ds$pptimesep\n" "$s"
}
