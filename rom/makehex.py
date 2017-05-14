#!/usr/bin/python

import sys

assert(len(sys.argv) == 3)
           
infile = sys.argv[1]
outfile = sys.argv[2]

with open(infile, 'rb') as inf:
    with open(outfile, 'wb') as outf:
        outf.write('@0\n')
        
        while True:
            b = inf.read(4)
            if b == '':
                break
            
            assert(len(b) == 4)
            
            outf.write('{:08x}\n'.format(
                ord(b[0])
                + (ord(b[1]) << 8)
                + (ord(b[2]) << 16)
                + (ord(b[3]) << 24)))
