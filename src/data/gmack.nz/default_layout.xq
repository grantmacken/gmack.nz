function($map as map(*)) as element() {
  element html {
  attribute lang {'en'},
    element head {
    element title { $map?title },
    element meta {
      attribute http-equiv { "Content-Type"},
      attribute content { "text/html; charset=UTF-8"}
      },
    element link { 
      attribute rel {"stylesheet"},
      attribute href { "/assets/styles/index.css"},
      attribute type {"text/css"}
    },  
    element link { 
      attribute rel {"icon"},
      attribute href { "/assets/images/favicon.ico"},
      attribute sizes {"any"}
    }
  },
  element body{
    element header { 
      attribute role { 'banner' },
     element h1 { 
      $map?title 
      }
    },
    element main {
      $map?content
    },
    element footer {
    <!--
      request:path(),element br {},
      request:uri(),element br {},
      request:scheme(),element br {},
      request:address(),element br {},
      -->
    }
    }
  }
}
