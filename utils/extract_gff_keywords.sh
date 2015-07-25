# Author: Daniel Ortiz Mart\'inez
# *- bash -*

########
function extract_gff_keywords_unique()
{
    # Init variables
    file=$1

    # Obtain keywords
    cat $file | $AWK -F "\"" '{if(NF>=4 && $4!="") printf"%s\n",$4}' | $bindir/tokenize \
        | $AWK '{for(i=1;i<=NF;++i) printf"%s\n",$i}' | $SORT | $UNIQ -c
}

########
if [ $# -lt 1 ]; then
    echo "Use: extract_gff_keywords -f <string> -c <string>"
    echo ""
    echo "-f <string>   :  path to gff file"
    echo "-c <string>   :  extraction criterion, <string> can be one of the following,"
    echo "                 unique -> obtain list with unique words"
    echo ""
else
    
    # Read parameters
    f_given=0
    c_given=0
    while [ $# -ne 0 ]; do
        case $1 in
        "-f") shift
            if [ $# -ne 0 ]; then
                gff=$1
                f_given=1
            fi
            ;;
        "-c") shift
            if [ $# -ne 0 ]; then
                crit=$1
                c_given=1
            fi
            ;;
        esac
        shift
    done

    # Check parameters
    if [ ${f_given} -eq 0 ]; then
        echo "Error! -f parameter not given" >&2
        exit 1
    fi

    if [ ! -f ${gff} ]; then
        echo "Error! ${gff} file does not exist" >&2
        exit 1
    fi

    if [ ${c_given} -eq 0 ]; then
        echo "Error! -c parameter not given" >&2
        exit 1
    fi

    # Process parameters
    case $crit in
        "unique") 
            extract_gff_keywords_unique $gff
            ;;
    esac
    
fi
