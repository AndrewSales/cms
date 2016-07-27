import module namespace cms = "http://www.andrewsales.com/xquery" at "../classify.xqm";

cms:classify(
  xs:anyURI('test/classify/foo.xml'),
  xs:ID('a123'),
  (xs:anyURI('http://www.example.com/taxonomy#foo'), 
  xs:anyURI('http://www.example.com/taxonomy#bar'), 
  xs:anyURI('http://www.example.com/taxonomy#blort'))
)