# Author: Daniel Ortiz Mart\'inez
# *- python -*

# import modules
import sys, getopt, nltk, codecs
from nltk.corpus import wordnet

# to_be_filtered
def to_be_filtered(word):
    synset_noun=wordnet.synsets(word, pos=wordnet.NOUN)
    synset_adj=wordnet.synsets(word, pos=wordnet.ADJ)
    if(len(synset_noun)!=0 or len(synset_adj)!=0):
        return True
    else:
        return False

# main
def main(argv):
    # take parameters
    f_given=False
    filename = ""
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hf:",["filename="])
    except getopt.GetoptError:
        print >> sys.stderr, "filter_spec_pos -f <string>"
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print "filter_spec_pos -f <string>"
            sys.exit()
        elif opt in ("-f", "--filename"):
            filename = arg
            f_given=True

    # print parameters
    if(f_given==True):
        print >> sys.stderr, "f is %s" % (filename)

    # open file
    if(f_given==True):
        # open file
        file = codecs.open(filename, 'r', "utf-8")
    else:
        # fallback to stdin
        file=codecs.getreader("utf-8")(sys.stdin)

    # read file line by line
    for line in file:
        line=line.strip("\n")
        split_line=line.split(" ")
        outstr=""
        for i in range(len(split_line)):
            if(to_be_filtered(split_line[i])):
                if(outstr==""):
                    outstr=split_line[i]
                else:
                    outstr=outstr+" "+split_line[i]
        print outstr

if __name__ == "__main__":
    main(sys.argv)
