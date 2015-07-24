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
#    snp = "rs7412"
    pagehandle = page.Page(site,snp)
    snp_page = pagehandle.getWikiText()

    # parse snp page
    wikicode = mwparserfromhell.parse(snp_page)
    templates = wikicode.filter_templates()
    print(templates[0])
    print(templates[0].get("rsid").value)

if __name__ == "__main__":
    main(sys.argv)
