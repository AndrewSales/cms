import random

collection = 200
minImages = 0
maxImages = 90000
prefix = 'ABC'

books = {}

for i in range(collection):
    books[i] = 0

#print(books) 

for i in range(maxImages - (minImages*collection)):
    books[random.randint(0, collection-1)] += 1
    
#print(books)

def facsimiles(n, fn):
    s = ''
    for i in range(n):
        s+='<facsimile xml:id="f%s">\n\t<graphic url="%s%s_%s_[Image type].jpg"/>\n</facsimile>\n' % \
        (i,prefix,fn,str(i).zfill(4))
    return s

for b in books:
    n = str(b).zfill(4)
    f = open('C:/temp/alo/%s%s' % (prefix, n + '.xml'), 'w')
    f.write("<TEI xmlns='http://www.tei-c.org/ns/1.0'>\n%s%s" % \
    (facsimiles(minImages+books[b], n), '</TEI>'))
    f.close()