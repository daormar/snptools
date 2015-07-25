#!  /usr/bin/python

# import modules
import sys, getopt, nltk, codecs
from nltk.corpus import wordnet

# obtain_hypernym
def obtain_hypernym(word):
#    print "****",word
    word_ss=wordnet.synsets(word)
#    print word_ss
    if len(word_ss)>0:
        synset=word_ss[0]
        if len(synset.hypernyms())>0:
            return synset.hypernyms()[0].lemma_names[0]
        else:
            return ""
    else:
        return ""

# main
def main(argv):
    # take parameters
    f_given=False
    filename = ""
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hf:",["filename="])
    except getopt.GetoptError:
        print >> sys.stderr, "obtain_hypernyms -f <filename>"
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print "obtain_hypernyms -f <string>"
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
            # if(outstr==""):
            #     outstr=split_line[i]+"::"+obtain_hypernym(split_line[i])
            # else:
            #     outstr=outstr+" "+split_line[i]+"::"+obtain_hypernym(split_line[i])
            hypernym=obtain_hypernym(split_line[i])
            if hypernym!="":
                if(outstr==""):
                    outstr=obtain_hypernym(split_line[i])
                else:
                    outstr=outstr+" "+obtain_hypernym(split_line[i])
        print outstr

if __name__ == "__main__":
    main(sys.argv)
