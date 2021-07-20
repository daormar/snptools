# Author: Daniel Ortiz Mart\'inez
# *- bash -*

########
if [ $# -lt 1 ]; then
    echo "Use: gen_snp_list <outpref> <keyword1> ... <keywordn>"
    echo ""
    echo "<outpref>                 : prefix of output files generated with the tool"
    echo "                            extract_gff_keywords"
    echo "<keyword1> ... <keywordn> : list of keywords used to filter SNPs"
    echo ""
else
    
    # Read parameters
    outpref=$1
    shift

    # Create temporary files
    tmpfile1=`${MKTEMP}`
    tmpfile2=`${MKTEMP}`

    # Check parameters
    if [ ! -f "${outpref}".snp_kw ]; then
        echo "Error! ${outpref}.snp_kw file does not exist" >&2
        exit 1
    fi

    # Copy snp_kw file to tmpfile1
    cp "${outpref}".snp_kw "$tmpfile1"

    # Filter SNPs
    while [ $# -ne 0 ]; do
        word="$1"
        $GREP "$word" "$tmpfile1" > "$tmpfile2"
        cp "$tmpfile2" "$tmpfile1"
        shift
    done

    # Generate output
    cat "$tmpfile1" | $AWK '{printf"%s\n",$1}'

    # Remove temporary files
    rm "$tmpfile1" "$tmpfile2"
fi
