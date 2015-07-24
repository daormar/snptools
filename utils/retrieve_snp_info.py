# Author: Daniel Ortiz Mart\'inez
# *- python -*

from wikitools import wiki, category, page
import mwparserfromhell
import sys, getopt

# main
def main(argv):

    # take parameters
    snp = ""
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hs:",["snp="])
    except getopt.GetoptError:
        print >> sys.stderr, "retrieve_snp_page.py -s <string>"
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print "retrieve_snp_page.py -s <string>"
            sys.exit()
        elif opt in ("-s", "--snp"):
            snp = arg

    # print parameters
    print >> sys.stderr, "s is %s" % (snp)

    # retrieve snp page
    site = wiki.Wiki("http://bots.snpedia.com/api.php")
    pagehandle = page.Page(site,snp)
    snp_page = pagehandle.getWikiText()

    # parse snp page
    wikicode = mwparserfromhell.parse(snp_page)
    templates = wikicode.filter_templates()

    # retrieve information
    tags=["rsid","Chromosome","position","GMAF","Assembly","GenomeBuild","dbSNPBuild","geno1","geno2","geno3","StabilizedOrientation","Status","Merged","Gene","Gene_s"]
    values=[]
    for t in tags:
        if templates[0].has_param(t):
            values.append(str(templates[0].get(t).value).strip("\n"))
        else:
            values.append("-")

    # print information
    entry=tags[0]+": "+values[0]+" ;"
    for i in range(1,len(tags)):
        entry=entry+" "+tags[i]+": "+values[i]+" ;"
    print entry

if __name__ == "__main__":
    main(sys.argv)
