#!  /usr/bin/python

# import modules
import sys, getopt, nltk, codecs

# main
def main(argv):
    # take parameters
    f_given=False
    filename = ""
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hf:",["filename="])
    except getopt.GetoptError:
        print >> sys.stderr, "tokenize -f <filename>"
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print "tokenize -f <string>"
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
        tokens = nltk.wordpunct_tokenize(line)
        if(len(tokens)>0):
            tok_sent=tokens[0]
            for t in tokens[1:]:
                tok_sent=tok_sent+" "+t
        else:
            tok_sent=""
        print tok_sent.encode("utf-8")

if __name__ == "__main__":
    main(sys.argv)
