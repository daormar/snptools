# Author: Daniel Ortiz Mart\'inez
# *- bash -*

########
function get_snp_note_from_gff_entry()
{
    $AWK -F ";" '{
                  if(NF>=4)
                  {
                   split($2,arridf,"rs:")
                   idf=arridf[2]
                   split($4,arrnotef,"\"")
                   notef=arrnotef[2]
                   printf"%s ; %s\n",idf,notef
                  }
                 }'
}

########
function extract_gff_keywords_unique()
{
    # Init variables
    unique_infile=$1
    unique_outfile=$2

    # Obtain keywords
    cat ${unique_infile} | $AWK -F "\"" '{if(NF>=4 && $4!="") printf"%s\n",$4}' | $bindir/tokenize \
        | $AWK '{for(i=1;i<=NF;++i) printf"%s\n",tolower($i)}' | $SORT | $UNIQ -c > ${unique_outfile}.kw
    
    # Obtain SNPs + keywords
    cat ${unique_infile} | get_snp_note_from_gff_entry | $bindir/tokenize \
        | $AWK '{printf"%s\n",tolower($0)}' > ${unique_outfile}.snp_kw
}

########
if [ $# -lt 1 ]; then
    echo "Use: extract_gff_keywords -f <string> -c <string> -o <string>"
    echo ""
    echo "-f <string>   :  path to gff file"
    echo "-c <string>   :  extraction criterion, <string> can be one of the following,"
    echo "                 unique -> obtain list with unique words"
    echo "-o <string>   :  output files prefix"
    echo ""
else
    
    # Read parameters
    f_given=0
    c_given=0
    o_given=0
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
        "-o") shift
            if [ $# -ne 0 ]; then
                outpref=$1
                o_given=1
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

    if [ ${o_given} -eq 0 ]; then
        echo "Error! -o parameter not given" >&2
        exit 1
    fi

    # Process parameters
    case $crit in
        "unique") 
            extract_gff_keywords_unique $gff $outpref
            ;;
    esac
    
fi
