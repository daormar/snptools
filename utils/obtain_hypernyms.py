# Author: Daniel Ortiz Mart\'inez
# *- python -*

# import modules
import sys, getopt, nltk, codecs
from nltk.corpus import wordnet

def obtain_hypernym(word):
    word_ss=wordnet.synsets(word)
    if len(word_ss)>0:
        synset=word_ss[0]
        if len(synset.hypernyms())>0:
            return synset.hypernyms()[0].lemma_names[0]
        else:
            return ""
    else:
        return ""

def main(argv):
    # take parameters
    f_given=False
    filename = ""
    s_given=False
    startfield=0
    a_given=False
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hf:s:a",["filename=","startfield="])
    except getopt.GetoptError:
        print >> sys.stderr, "obtain_hypernyms -f <string> [-s <int>] [-a]"
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print "obtain_hypernyms -f <string> [-s <int>] [-a]"
            sys.exit()
        elif opt in ("-f", "--filename"):
            filename = arg
            f_given=True
        elif opt in ("-s", "--startfield"):
            startfield = int(arg)
            s_given=True
        if opt == '-a':
            a_given=True

    # print parameters
    if(f_given==True):
        print >> sys.stderr, "f is %s" % (filename)

    if(s_given==True):
        print >> sys.stderr, "s is %d" % (startfield)

    if(a_given==True):
        print >> sys.stderr, "a is %d" % (a_given)

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
            if(a_given==True):
                hypernym=obtain_hypernym(split_line[i])
                if hypernym!="":
                    if(outstr==""):
                        outstr=hypernym
                    else:
                        outstr=outstr+" "+hypernym
            else:
                if(outstr==""):
                    if(i<startfield):
                        outstr=split_line[i]
                    else:
                        outstr=split_line[i]+"::"+obtain_hypernym(split_line[i])
                else:
                    if(i<startfield):
                        outstr=outstr+" "+split_line[i]
                    else:
                        outstr=outstr+" "+split_line[i]+"::"+obtain_hypernym(split_line[i])
        print outstr

if __name__ == "__main__":
    main(sys.argv)
