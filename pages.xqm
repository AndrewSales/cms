xquery version "3.0";
module namespace cms = "http://www.andrewsales.com/xquery";
(: import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session"; :)
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:TODO make these discoverable from a central config:)
declare variable $cms:collConfig := doc('/ContentBase/collection/config/user-edit-permissions.xml');
declare variable $cms:collBase := $cms:collConfig/collection/@xml:base;
declare variable $cms:contentBase := '/ContentBase/collection/content/main';
declare variable $cms:reviewBase := '/ContentBase/collection/content/review';
declare variable $cms:xsltFormsLoc := '../static/xsltforms/xsltforms.xsl';

(:Files assigned to the current user:)
declare function cms:user-collection($user as xs:string) 
as element(file)*
{
 $cms:collConfig/collection/user[
     if($user = 'admin')
     then true()
     else @name = $user
   ]/file[exists(
    collection( $cms:collBase || '/' || @url )
        )]
};

(:~
 : Displays files available for the current user,
 : or all in the collection if logged in as admin.
 :) 
declare 
  %rest:path("/ContentBase/collection") 
  %output:method("html")
  %rest:cookie-param("user", "{$user}")
function cms:collection($user as xs:string?) 
as element()
{
    if(empty($user))
    then 
        <rest:redirect>/ContentBase/login</rest:redirect>
    else
    <html>
   
   
   <head>
      <meta http-equiv="X-UA-Compatible" content="IE=edge"></meta>
      <meta name="viewport" content="width=device-width, initial-scale=1"></meta>
      <meta name="description" content=""></meta>
      <meta name="author" content=""></meta>
      
      <title>Collection</title>      
      
      <link rel="stylesheet" 
         href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" 
         integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" 
         crossorigin="anonymous"/>
   </head>
   
   <body>
      
      <div class="container">
         <div class="page-header">
            <div class="text-right"><em>Logged in as:</em> <span>{$user}</span></div>
            <h1>Collection</h1>
         </div>
         
         <table class="table table-condensed table-hover ">
            <thead>
               <tr class='text-nowrap'>
                  <th>Catalogue no.</th>
                  <th>Author</th>
                  <th>Title</th>
                  <!--<th>Last modified</th>-->
               </tr>
            </thead>
            <tbody>{
               for $file in cms:user-collection($user)
               let $doc := doc(($cms:collBase || '/' || $file/@url))
               let $id := $doc/*/@xml:id/data()
               let $titles := $doc//tei:title[@corresp]
               return
               <tr valign='bottom'>
                  <th scope="row"><a href='toc?url={$file/@url}'>{$id}</a></th>
                  <td class='text-nowrap'>{($doc//tei:author[not(@role)])[1]/tei:persName[@type='default'][lang('en')]/data()}</td>
                  <td>{if($titles)
                    then 
                        for $title in $titles
                        return
                        <div><a href='work?catNum={$id}&amp;id={substring-after($title/@corresp, '#')}&amp;lang=en'>{$title/data()}</a></div>
                    else $doc//tei:title[@type='originalFull']/data()}</td>
                  <!--<td>{collection($cms:reviewBase||'/'||$id||'/'||$id||'.xml@en')/*/@when/data()}</td>-->
               </tr>
            }</tbody>
         </table>
      </div>
      
      
   </body>
</html>
};

declare 
  %rest:path("/ContentBase/toc") 
  %rest:query-param("url", "{$url}")
  %rest:cookie-param("user", "{$user}")
  %output:method("html")
function cms:toc($url, $user) 
as document-node()
{
    
    xslt:transform(
             doc($cms:collBase || '/' || $url),
             doc('xsl/toc.xsl'),
             map{'sys-id':$url}
             )
};

(:N.B. OUTPUT METHOD MUST BE XML:)
declare 
  %rest:path("/ContentBase/work") 
  %rest:GET
  %rest:query-param("catNum", "{$catNum}")
  %rest:query-param("id", "{$id}")
  %rest:query-param("lang", "{$lang}")
  %rest:cookie-param("user", "{$user}")
  %output:method("xml") 
  %output:omit-xml-declaration("yes")
  %output:indent("no")
function cms:work($catNum, $id, $lang, $user) 
as item()
{
    if(empty($user))
    then <rest:redirect>/ContentBase/login</rest:redirect>
    else
  let $reviewURL := $cms:reviewBase || '/' || $catNum || '/' || $id || '.xml@' || $lang

  return
  if(doc-available($reviewURL))
  then
        xslt:transform(
             doc($reviewURL),
             doc('xsl/metadata2xform.xsl'),
             map{
                'id':$id,
                'lang':$lang,
                'xsltformsStylesheet':$cms:xsltFormsLoc
                }
             )
    else
        xslt:transform(
             doc($cms:collBase || '/' || $catNum || '.xml'),
             doc('xsl/tei2xform.xsl'),
             map{
                'sys-id':$catNum, 
                'id':$id, 
                'xsltformsStylesheet':$cms:xsltFormsLoc,
                'lang':$lang
                }
             )
};

(:~
    
:)
declare function cms:get-url(
    $catNum as xs:string, 
    $id as xs:string, 
    $lang as xs:string
    )
as xs:string
{
    let $suffix := '/' || $catNum || '/' || $id || '.xml@' || $lang
    let $reviewURL := $cms:reviewBase || $suffix
    
    return 
        if(doc-available($reviewURL))
        then $reviewURL
        else $cms:collBase || $suffix
};

declare 
  %rest:path("/ContentBase/section") 
  %rest:query-param("catNum", "{$catNum}")
  %rest:query-param("id", "{$id}")
  %output:method("html")
function cms:section($catNum, $id) 
as document-node()
{
  xslt:transform(
             doc($cms:collBase || '/' || $catNum || '.xml'),
             doc('xsl/section.xsl'),
             map{'sys-id':$catNum, 'id':$id}
             )
};

declare 
  %rest:path("/ContentBase/page") 
  %rest:GET
  %rest:query-param("catNum", "{$catNum}")
  %rest:query-param("id", "{$id}")
  %rest:query-param("lang", "{$lang}")
  %output:method("xml") 
  %output:omit-xml-declaration("yes")
  %output:indent("yes")
function cms:page(
    $catNum as xs:string, 
    $id as xs:string,
    $lang as xs:string
    ) 
as document-node()
{
    let $reviewURL := cms:get-url($catNum, $id, $lang)
    
    let $input := 
        if(doc-available($reviewURL))
        then doc($reviewURL)
        else cms:get-chunk($catNum, $id)

    return xslt:transform(
             $input,
             doc('xsl/page.xsl'),
             map{'catNum':$catNum, 'id':$id, 'lang':$lang}
             )
};

(:~
    Returns the XML chunk for a given catalogue
    number and @xml:id.        
:)
declare function cms:get-chunk(
    $catNum as xs:string,
    $id as xs:string
)
as element()
{
    doc($cms:contentBase || '/' || $catNum || '.xml')//*[@xml:id=$id]
};

declare 
  %rest:path("/ContentBase/login")
  %output:method("html")
function cms:login()
{    
<html xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events">


    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="description" content="" />
        <meta name="author" content="" />

        <title>[Product name]</title>
        
        <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>

        <link href="../static/style.css" rel="stylesheet" />
        </head>
    <body>

        <div class="container">
            <div class="col-lg-3"></div>
            <div class="col-lg-6 ">
                <form class="form-signin" action='authenticate' method='post'>
                    <h2 class="form-signin-heading">Please sign in</h2>
                    <div>
                        <label for="inputEmail" class="sr-only">Email address</label>
                        <!--<input type="email" id="inputEmail" class="form-control"
                            placeholder="Email address" />-->
                            <input name='username' id="inputEmail" class="form-control"
                            placeholder="Email address"/>
                    </div>
                    <div>
                        <label for="inputPassword" class="sr-only">Password</label>
                        <input name='password' type="password" id="inputPassword" class="form-control"
                            placeholder="Password" />
                    </div>
                    
                    <button class="btn-lg btn-block text-center" type="submit">Sign in</button>
                </form>
            </div>
            <div class="col-lg-3"></div>
        </div>
        <!-- /container -->



    </body>

</html>

};

declare 
  %updating
  %rest:path("/ContentBase/save")
  %rest:POST("{$body}")
  %rest:query-param("catNum", "{$catNum}")
  %rest:query-param("id", "{$id}")
  %rest:query-param("lang", "{$lang}")
  %rest:cookie-param("user", "{$user}")
  %output:method("html")
function cms:save($body, $catNum, $id, $lang, $user)
{
    let $path := '/collection/content/review/' || $catNum || '/' || $id || '.xml@' || $lang
    let $doc := 
        <metadata when='{current-dateTime()}' who='{$user}'>
            {$body/metadata/(@docID, @chunkID) }
            {$body/*/*}
        </metadata>
    return db:replace('ContentBase', $path, $doc)
};

(:~
    User login.
    If successful, redirects to the user's collection.
    Otherwise, redirects to the login page.
:)
declare 
  %rest:path("/ContentBase/authenticate")
  %rest:POST
  %output:method("html")
  %rest:form-param("username", "{$username}", "(none)")
  %rest:form-param("password", "{$password}", "(none)")
function cms:check-login($username, $password)
as element()
{  
    (:TODO: add Secure for HTTPS; set Expires or Max-Age:)
    <rest:response>
      <http:response status='302'>{
        if(cms:valid-credentials($username, $password))
        then
            (<http:header name="Set-Cookie" value="user={$username}; HttpOnly; path=/"/>,
            <http:header name="location" value="/ContentBase/collection"/>)
        else
            <http:header name="location" value="/ContentBase/login"/>
        }
      </http:response>
    </rest:response>
  
};

(:~
    Returns whether a user's credentials match those held by
    the system.
    
    (Adapted from https://github.com/BaseXdb/basex/issues/1326,
    pending release of v8.6 and user:check-user().)
:)
declare function cms:valid-credentials($name as xs:string, $password as xs:string)
as xs:boolean
{
    
        (:
        FIXME: fails on invalid or unknown username
        try{user:exists($name)}
        catch user:name{false()},:)
    
        let $pw := user:list-details($name)/password[@algorithm = 'salted-sha256']
        let $hash := lower-case(string(xs:hexBinary(hash:sha256($pw/salt || $password))))
        return $pw/hash = $hash
    
  
};