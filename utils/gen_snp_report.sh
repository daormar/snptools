# Author: Daniel Ortiz Mart\'inez
# *- bash -*

########
raw_to_csv_cnames()
{
    # Init variables
    snp=$1
    line=$2

    # Convert line
    echo $line | $AWK -F " ; " -v snp=$snp '{
                                 for(i=1;i<=NF;++i)
                                 {
                                   numf=split($i,arr,": ")
                                   printf"\"%s\" ",arr[1]
                                 }
                                 printf"\n"
                                }'
}

########
raw_to_csv_entry()
{
    # Init variables
    snp=$1
    line=$2

    # Convert line
    echo $line | $AWK -F " ; " -v snp=$snp '{
                                 printf "\"%s\"",snp
                                 for(i=1;i<=NF;++i)
                                 {
                                   numf=split($i,arr,": ")
                                   printf" \"%s\"",arr[2]
                                 }
                                 printf"\n"
                                }'
}

########
gen_snp_report_csv()
{
    # Init variables
    csv_source=$1
    csv_outfile=$2

    # Check if output file exists
    if [ -f ${csv_outfile} ]; then
        rm ${csv_outfile}
    fi

    # Print column names
    snp=`head -1 ${csv_source}`
    line=`$bindir/retrieve_snp_info -s $snp 2> /dev/null`
    raw_to_csv_cnames $snp "$line" >> ${csv_outfile}

    # Process source
    cat ${csv_source} | while read snp; do
        line=`$bindir/retrieve_snp_info -s $snp 2> /dev/null`
        raw_to_csv_entry $snp "$line" >> ${csv_outfile}
    done
}

########
raw_to_md_line()
{
    # Init variables
    line=$1

    # Convert line
    echo $line | $AWK -F " ; " '{
                                 for(i=1;i<=NF;++i)
                                 {
                                   numf=split($i,arr,": ")
                                   printf"- **%s**: %s\n",arr[1],arr[2]
                                 }
                                }'
}

########
raw_to_md_entry()
{
    # Init variables
    snp=$1
    line=$2

    # Create header
    echo "# [$snp][$snp]"
    echo ""
    echo "[$snp]: http://www.snpedia.com/index.php/$snp"
    echo "" 

    # Process line
    raw_to_md_line "$line"

    # Add ending blank line
    echo ""
}

########
gen_snp_report_md()
{
    # Init variables
    md_source=$1
    md_outfile=$2

    # Check if output file exists
    if [ -f ${md_outfile} ]; then
#        echo "Warning, file ${md_outfile} exists, it will be overwritten" > /dev/stderr
        rm ${md_outfile}
    fi

    # Process source
    cat ${md_source} | while read snp; do
        line=`$bindir/retrieve_snp_info -s $snp 2> /dev/null`
        raw_to_md_entry $snp "$line" >> ${md_outfile}
    done
}

########
gen_snp_report_html()
{
    # Init variables
    html_source=$1
    html_outfile=$2
    tmpfile=`${MKTEMP}`

    # Generate md file
    gen_snp_report_md ${html_source} $tmpfile

    # Conver md file to html file
    ${PANDOC} $tmpfile -o ${html_outfile}

    # Remove temporary files
    rm $tmpfile
}

########
gen_snp_report_pdf()
{
    # Init variables
    pdf_source=$1
    pdf_outfile=$2
    tmpfile=`${MKTEMP}`

    # Generate md file
    gen_snp_report_md ${pdf_source} $tmpfile

    # Conver md file to pdf file
    ${PANDOC} -V colorlinks $tmpfile -o ${pdf_outfile}

    # Remove temporary files
    rm $tmpfile
}

########
gen_snp_report()
{
    # Init variables
    source=$1
    outfile=$2

    # Obtain file extension
    fname=`basename $outfile`
    ext="${fname##*.}"
    
    # Generate report in the appropriate format
    case $ext in
        "csv")
            gen_snp_report_csv $source $outfile
            ;;
        "md")
            gen_snp_report_md $source $outfile
            ;;
        "html")
            gen_snp_report_html $source $outfile
            ;;
        "pdf")
            gen_snp_report_pdf $source $outfile
            ;;
    esac
}

########
if [ $# -lt 1 ]; then
    echo "Use: gen_snp_report -s <string> -o <string>"
    echo ""
    echo "-s <string>   :  path to file with SNP ids"
    echo "-o <string>   :  output file name. File extension given will determine file"
    echo "                 format. Current options: html, pdf, markdown, csv"
    echo ""
else
    
    # Read parameters
    s_given=0
    o_given=0
    while [ $# -ne 0 ]; do
        case $1 in
        "-s") shift
            if [ $# -ne 0 ]; then
                source=$1
                s_given=1
            fi
            ;;
        "-o") shift
            if [ $# -ne 0 ]; then
                outfile=$1
                o_given=1
            fi
            ;;
        esac
        shift
    done

    # Check parameters
    if [ ${s_given} -eq 0 ]; then
        echo "Error! -s parameter not given" >&2
        exit 1
    fi

    if [ ! -f ${source} ]; then
        echo "Error! ${source} file does not exist" >&2
        exit 1
    fi

    if [ ${o_given} -eq 0 ]; then
        echo "Error! -o parameter not given" >&2
        exit 1
    fi

    # Process parameters
    gen_snp_report $source $outfile

fi
