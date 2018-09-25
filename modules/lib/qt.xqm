xquery version "3.1";
(:~
This module contains helper functions for qt
@author Grant MacKenzie
@version 0.0.1
@see unit-tests/lib/qt.xqm
:)

module namespace qt="http://markup.nz/#qt";

(:~
recursive process of templates to produce doc
@see unit-tests/tests/lib/qt.xqm;t-qt
@param  data model as a map()
@param  nodes to process
@return result node
:)
declare
function qt:dispatch( $model as map(*), $nodes as node()* ) {
 for $node in $nodes
  return
    typeswitch ($node)
    case document-node() return (
        for $child in $node/node()
        return ( qt:dispatch( $model, $child) )
        )
    (: head :)
    (: always set title from model :)
    case element() return (
        (: includes :)
        if ( $node/@data-include ) then (
          qt:include( $model, $node )
          )
        else if ( $node/@data-render ) then (
           qt:render( $model, $node )
           )
        else(
          qt:passthru( $model, $node )
          )
        )
        default return
      $node
};

(:~
make a copy of the node to return to dispatch
@param  data model as a map()
@param  HTML template node as a node()
@return a copy of the template node
:)
declare
function qt:passthru( $model as map(*), $node as node()* ) as item()* {
       element {name($node)} {
          (: output each attribute in this element :)
          for $att in $node/@*
          return
          attribute {name($att)} {$att}
          ,
          (: output all the sub-elements of this element recursively :)
          for $child in $node
          return qt:dispatch($model, $child/node())
          }
};


(:~
given a string and a node
output should be a node containing the string
@param  data model as a map()
@param  HTML template node as a node()
@return a node containing the string
:)
declare function qt:include( $model as map(*), $node as node()* ) as item()* {
  let $path := $model('includes') || '/' || $node/@data-include   || '.html'
  return
    qt:dispatch($model, doc($path))
};

declare
function qt:render(  $model as map(*), $node as node()) {
  switch ( $node/@data-render/string() )
      case "sub" return qt:substitute( $model, $node )
      case "card" return qt:substitute( $model('card'), $node )
      case "profiles" return qt:forEach( $model('profiles'), $node )
      default    return qt:passthru( $model, $node )
};

(:~
given a string and a node
output should be a node containing the string
@param  string
@param  HTML template node as a node()
@return a node containing the string
:)
declare
function qt:insert( $str as xs:string , $node as node()* ) as node()  {
        element { node-name($node) } {
            $str
            }
};

(:~
given a string and a node
output should be a node containing the string
@param  key
@param  data model as a map()
@param  HTML template node as a node()
@return a node containing the string
:)
declare
function qt:insertKeyValue( $key as xs:string , $model as map(*), $node as node()* ) as node()  {
 if ( map:contains( $model, $key ) ) then (
  element { node-name($node) } {
     attribute name { $key },
     attribute value { $model($key) }
    }
  )
else(
  qt:passthru( $model, $node )
  )
};


(:~
given an array of items and a node
function call should produce a sequence of nodes
@param  an array of strings
@param  HTML template node as a node()
@return sequence of nodes
:)
declare
function qt:wrap( $arr as array(*), $node as node()*)
as node()* {

  for-each( $arr?*, qt:insert(?,$node))
};

(:~
given an array of items and a node
function call should produce a sequence of nodes
@param  an array of strings
@param  HTML template node as a node()
@return sequence of nodes
:)
declare
function qt:forEach( $arr as array(*), $node as node()*)
as node()* {
  for-each( $arr?*, qt:substitute(?,$node))
};

declare
function qt:substitute( $model as map(*), $node as node() ) {
  let $str := $node/string() => normalize-space()
  let $attrs := for $attr in $node/@*
    where $attr/name(.) ne 'data-render'
    return $attr

  return
  element { local-name($node) } {
    for $att in $attrs
      return
      if ( map:contains( $model, $att/string()) ) then (
          attribute {$att/name(.)} {
          $model($att/string())
          })
      else (
          attribute {$att/name(.)} {
          $att
          }),
   if ( map:contains( $model, $str) )
    then  $model($str)
   else if ( $node/img )
    then qt:substitute( $model, $node/img )
   else
    $str
 }
};

(:half
 
  for $att in $node/@*
  where map:contains( $model, $att )
  return (-
  attribute {$att}{$model($att)}
  ),



  element {local-name($node)} {
    attribute title {$model('title')},
    attribute href {$model('website')},
     $model('author')
    }

:)
