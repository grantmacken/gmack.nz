xquery version "3.1";
(:~
Tests for qt functions
:)
module namespace t-qt = "http://markup.nz/#t-qt";
import module namespace qt = "http://markup.nz/#qt" at "../../modules/lib/qt.xqm";
declare namespace test="http://exist-db.org/xquery/xqsuite";

(:~
@param $arg  string
:)
declare
%test:name(
'process the simplist HTML fragment'
)
%test:args('<html/>')
%test:assertXPath('deep-equal($result,<html/>)')
function t-qt:dispatch( $arg1 ) {
let $map := map {}
let $doc := parse-xml( $arg1  )
return
  qt:dispatch( $map, $doc )
};

declare
%test:name(
'should insert string within node'
)
%test:args('item','<li/>')
%test:assertXPath('deep-equal($result,<li>item</li>)')
%test:assertXPath('$result/text() eq "item"')
function t-qt:insert( $str as xs:string  , $node as element()* ) {
  qt:insert( $str , $node  )
};

declare
%test:name(
'should wrap single input items with node tag'
)
%test:args('<li/>')
%test:assertXPath('deep-equal($result,<li>item1</li>)')
function t-qt:wrap( $node as element() ) {
  qt:wrap(  ['item1' ] , $node )
};

declare
%test:name(
'should wrap each array item with node tag'
)
%test:args( '<li/>')
%test:assertXPath('$result instance of node()')
%test:assertXPath('count($result//li) eq 2')
%test:assertXPath('$result//li[1]/text() = ("item1")')
function t-qt:wrap_2( $node as element() ) as item()* {
  (
  <ul>{qt:wrap( ['item1','item2' ], $node )}</ul>
  )
};

declare
%test:name(
'should substitute node string with named model item '
)
%test:args( '<a data-render="substitute" class="h-card" href="website">author</a>')
%test:assertXPath('$result instance of node()')
%test:assertXPath('deep-equal($result,<a class="h-card" href="website">grantmacken</a>)')
function t-qt:substitute_01( $node as element() ) as item()* {
  (
  qt:substitute( map {'author': 'grantmacken'} , $node )
  )
};

declare
%test:name(
'should substitute node attribute with named model item '
)
%test:args( '<a data-render="substitute" class="h-card" href="website">author</a>')
%test:assertXPath('$result instance of node()')
%test:assertXPath('deep-equal($result,<a class="h-card" href="https://gmack.nz">grantmacken</a>)')
function t-qt:substitute_02( $node as element() ) as item()* {
  (
  qt:substitute( map {'author': 'grantmacken','website': 'https://gmack.nz' } , $node )
  )
};
