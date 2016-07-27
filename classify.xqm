(:~

 : ----------------------------------------------------------------------
 : A module of hopefully useful functions for use in a content management
 : system.
 : ----------------------------------------------------------------------

 : Copyright (c) 2016 Andrew Sales

 : This program is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.

 : This program is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 : GNU General Public License for more details.

 : You should have received a copy of the GNU General Public License
 : along with this program.  If not, see <http://www.gnu.org/licenses/>.


 : @version 0.1
 : mailto:andrew@andrewsales.com     
 :) 

xquery version "3.0";
module namespace cms = "http://www.andrewsales.com/xquery"; 

(:~
 : Adds taxonomy facet(s) to a node.
 :
 : @author  Andrew Sales 
 : @version 0.1
 : @param   $doc the path to the document storing the classification
 : @param   $node-id the ID of the node to classify
 : @param   $facet the facet(s) to associate with the node
 :
 : Intended usage is to replace doc($doc)/nodes/node[@id=$node-id] with the 
 : facet(s) passed in. Such a document may be stored in a collection related to 
 : the content to be classified.
 :
 : N.B. no attempt is made to update any nodes or facets already present 
 : intelligently; all are simply replaced on each call.
 : This means that passing the empty sequence as $facet deletes all facets for 
 : $id.
 :) 
declare 
  %updating
function cms:classify(
    $doc as xs:anyURI,
    $node-id as xs:ID,
    $facet as xs:anyURI*
)
{
  (: update parallel doc in classification collection with $facet :)
  if(doc-available($doc))
    then 
      (
        delete
          node doc($doc)/nodes/node[@id=$node-id],
        insert 
          node (
            for $f in $facet 
            return <node id='{$node-id}' facet='{$f}'/>
          )
        into doc($doc)/nodes
      )
    else(
      error(xs:QName('err'), 'no such document to classify: ' || $doc)
    )
};