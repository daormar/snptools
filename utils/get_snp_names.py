# Author: Daniel Ortiz Mart\'inez
# *- python -*

from wikitools import wiki, category

# main
def main(argv):

    # open snpedia
    site = wiki.Wiki("http://bots.snpedia.com/api.php") 
    snps = category.Category(site, "Is_a_snp")
    snpedia = []
       
    # get all snp-names as list and print them
    for article in snps.getAllMembersGen(namespaces=[0]):   
        snpedia.append(article.title.lower())
        print article.title

if __name__ == "__main__":
    main(sys.argv)
