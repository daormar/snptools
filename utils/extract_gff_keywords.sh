# Author: Daniel Ortiz Mart\'inez
# *- bash -*

########
tolower()
{
    "$AWK" '{printf"%s\n",tolower($0)}'
}

########
one_word_per_line()
{
    "$AWK" '{for(i=1;i<=NF;++i) printf"%s\n",$i}'
}

########
cutoff_pruning()
{
    func_cutoff=$1

    "$AWK" -v c=${func_cutoff} '{if($1>c) printf"%s\n",$0}'
}

########
get_snp_note_from_gff_entry()
{
    "$AWK" -F ";" '{
                  if(NF>=4)
                  {
                   split($2,arridf,"=rs")
                   idf=arridf[2]
                   split($4,arrnotef,"\"")
                   notef=arrnotef[2]
                   printf"rs%s ; %s\n",idf,notef
                  }
                 }'
}

########
extract_gff_keywords_vocab()
{
    # Init variables
    vocab_infile=$1
    vocab_cutoff=$2
    vocab_outfile=$3

    # Obtain keywords
    cat "${vocab_infile}" | "$AWK" -F "\"" '{if(NF>=4 && $4!="") printf"%s\n",$4}' | "$bindir"/tokenize \
        | tolower | one_word_per_line | "$SORT" | "$UNIQ" -c \
        | cutoff_pruning $cutoff > "${vocab_outfile}".kw
    
    # Obtain SNPs + keywords
    cat "${vocab_infile}" | get_snp_note_from_gff_entry | "$bindir"/tokenize \
        | tolower > "${vocab_outfile}".snp_kw
}

########
extract_gff_keywords_pos()
{
    # Init variables
    pos_infile=$1
    pos_cutoff=$2
    pos_outfile=$3

    # Obtain keywords
    cat "${pos_infile}" | "$AWK" -F "\"" '{if(NF>=4 && $4!="") printf"%s\n",$4}' | "$bindir"/tokenize \
        | tolower | "$bindir"/filter_spec_pos | one_word_per_line | "$SORT" | "$UNIQ" -c \
        | cutoff_pruning $cutoff > "${pos_outfile}".kw
    
    # Obtain SNPs + keywords
    cat "${pos_infile}" | get_snp_note_from_gff_entry | "$bindir"/tokenize \
        | tolower > "${pos_outfile}".snp_kw
}

########
extract_gff_keywords_hyper()
{
    # Init variables
    hyper_infile=$1
    hyper_cutoff=$2
    hyper_outfile=$3

    # Obtain keywords
    cat "${hyper_infile}" | "$AWK" -F "\"" '{if(NF>=4 && $4!="") printf"%s\n",$4}' | "$bindir"/tokenize \
        | tolower | "$bindir"/filter_spec_pos | "$bindir"/obtain_hypernyms -a | one_word_per_line | "$SORT" | "$UNIQ" -c \
        | cutoff_pruning $cutoff > "${hyper_outfile}".kw
    
    # Obtain SNPs + keywords
    cat "${hyper_infile}" | get_snp_note_from_gff_entry | "$bindir"/tokenize \
        | tolower | "$bindir"/obtain_hypernyms -s 2 > "${hyper_outfile}".snp_kw
}

########
if [ $# -lt 1 ]; then
    echo "Use: extract_gff_keywords -f <string> -c <string> -o <string> [-v <integer>]"
    echo ""
    echo "-f <string>   :  path to gff file"
    echo "-c <string>   :  extraction criterion, <string> can be one of the following,"
    echo "                 vocab -> obtain list with vocabulary words"
    echo "                 pos -> same as vocab but filter specific parts of speech"
    echo "                 hyper -> same as pos but obtaining hypernyms for words"
    echo "-o <string>   :  output files prefix"
    echo "-v <integer>  :  ommit keywords with count less than <integer> (optional)"
    echo ""
else
    
    # Read parameters
    f_given=0
    c_given=0
    o_given=0
    cutoff=0
    v_given=0
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
        "-v") shift
            if [ $# -ne 0 ]; then
                cutoff=$1
                v_given=1
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

    if [ ! -f "${gff}" ]; then
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
        "vocab") 
            extract_gff_keywords_vocab "$gff" $cutoff "$outpref"
            ;;
        "pos") 
            extract_gff_keywords_pos "$gff" $cutoff "$outpref"
            ;;
        "hyper") 
            extract_gff_keywords_hyper "$gff" $cutoff "$outpref"
            ;;
    esac
    
fi
