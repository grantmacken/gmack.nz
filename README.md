# gmack.nz

WIP working files for an indieweb site 

## content

- structured data 
    - stored in docker eXistdb container 'data' volume
    - extracted and www delivered by xQuery as hyperlinked HTML5 views
    - proxied behind openresty with views cached ... 
- resource assets 
    - stored in a docker openresty container 'html' volume
    - optimised prior to storage 
      - css, js compressed ( gzipped , brotili )
      - svg ( gzipped )
      - png ( compressed  )

# security
 - everything over HTTPS
 - Bearer Token authentication, indieauth based access control via lua modules (openresty)




