xquery version "3.1";
(:~
:
@author 
@version 
@see 
:)

module namespace unavailable="http://markup.nz/#unavailable";

declare
function unavailable:head( $title, $myPhoto ) {
  element head {
    element meta { attribute charset { 'utf-8' }},
    element title { $title },
    element meta {
      attribute name { 'viewport' },
      attribute content { 'width=device-width, initial-scale=1' }
    },
    element link {
      attribute href { '/styles' },
      attribute rel { 'Stylesheet' },
      attribute type { 'text/css' }
    },
    element link {
      attribute href { '/icons/compose' },
      attribute rel { 'icon' },
      attribute type { 'image/svg+xml' }
    },
    element link {
      attribute href { $myPhoto } ,
      attribute rel { 'apple-touch-icon' }
    }
  }
};

declare
function unavailable:header( $map  as map(*) ) {
  element header {
    attribute title { $map('repo-description') },
    attribute role  { 'banner' },
    element a {
      attribute href {'/'},
      attribute title {'home page'},
      $map('card-name')
    }
  }
};


declare
function unavailable:content( $map  as map(*)) {
 element main {
  element h1 {
    'Not Found'
    }

  }
};


declare
function unavailable:footer( $map  as map(*) ) {
  element footer {
    attribute title { 'page footer' },
    element a {
      attribute href {'/'},
      attribute title {'home page'},
      $map('domain')
      },
      ' is the website owned, authored and operated by ',
      element a {
        attribute href {'/'},
        attribute title {'author'},
        attribute class {'h-card p-name'},
        $map('card-name')
        }
    }
};


declare
function unavailable:render( $map as map(*) ) {
  let $title :=  'document unavailable'
  let $myPhoto := $map('card-photo')
  return
  element html {
    unavailable:head( $title, $myPhoto ),
    element body {
      unavailable:header( $map ),
      unavailable:content( $map),
      unavailable:footer( $map )
      }
    }
};
