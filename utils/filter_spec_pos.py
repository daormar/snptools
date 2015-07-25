#!  /usr/bin/python

# import modules
import sys, getopt, nltk, codecs
from nltk.corpus import wordnet

# main
def main(argv):
    # take parameters
    f_given=False
    filename = ""
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hf:",["filename="])
    except getopt.GetoptError:
        print >> sys.stderr, "filter_spec_pos -f <filename>"
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
        outstr=split_line[0]
        for i in range(1,len(split_line)):
            synset_noun=wordnet.synsets(split_line[i], pos=wordnet.NOUN)
            synset_adj=wordnet.synsets(split_line[i], pos=wordnet.ADJ)
            if(len(synset_noun)!=0 or len(synset_adj)!=0):
                outstr=outstr+" "+split_line[i]
        print outstr

if __name__ == "__main__":
    main(sys.argv)
