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
                    href="../static/bootstrap.min.css"/>
   </head>
   
   <body>
      
      <div class="container">
         <div class="page-header">
            <div class="text-right"><em>Logged in as:</em> <span>{$user}</span></div>
            <div class="text-right"><a href='/ContentBase/logout'>Logout</a></div>
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
               order by xs:integer(substring-after($id, 'ARC_'))
               return
               <tr valign='bottom'>
                  <th scope="row" title='View ToC'><a href='toc?url={$file/@url}'>{$id}</a></th>
                  <td class='text-nowrap'>{
                    for $name in ($doc//tei:author[not(@role)])/tei:persName[@type='default'][lang('en')]/data()
                    return <div>{$name}</div>}
                  </td>
                  <td>{
                    let $titles := $doc//tei:title[@corresp]
                  
                  return if($titles)
                    then 
                        for $title in $titles
                        return 
                        <div title='View this title'><a href='work?catNum={$id}&amp;id={substring-after($title/@corresp, '#')}&amp;lang=en'>{$title/data()}</a></div>
                    else 
                        <div title='View this title'><a href='work?catNum={$id}&amp;id={$id}&amp;lang=en'>{$doc//tei:title[@type='originalFull']/data()}</a></div>
                }</td>
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
as item()
{
 
    if(empty($user))
    then <rest:redirect>/ContentBase/login</rest:redirect>
    else
    xslt:transform(
             doc($cms:collBase || '/' || $url),
             doc('xsl/toc.xsl'),
             map{'sys-id':$url, 'user':$user}
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
                'xsltformsStylesheet':$cms:xsltFormsLoc,
                'user':$user
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
                'lang':$lang,
                'user':$user
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
  %rest:cookie-param("user", "{$user}")
  %output:method("xml") 
  %output:omit-xml-declaration("yes")
  %output:indent("yes")
function cms:page(
    $catNum as xs:string, 
    $id as xs:string,
    $lang as xs:string,
    $user as xs:string?
    ) 
as item()
{
    let $reviewURL := cms:get-url($catNum, $id, $lang)
    
    return
    if(empty($user))
    then <rest:redirect>/ContentBase/login</rest:redirect>
    else
    if(doc-available($reviewURL))
        then cms:pageFromMetadata( 
            doc($reviewURL),
            $catNum,
            $id,
            $lang
            )
        else 
            cms:pageFromTEI(
                cms:get-chunk($catNum, $id),
                $catNum,
                $id,
                $lang
            )
};

declare function cms:pageFromMetadata(
    $doc as document-node(),
    $catNum as xs:string, 
    $id as xs:string,
    $lang as xs:string
)
as document-node()
{
    xslt:transform(
        $doc,
        doc('xsl/page.xsl'),
        map{'catNum':$catNum, 'id':$id, 'lang':$lang}
    )
};

declare function cms:pageFromTEI(
    $page as element(),
    $catNum as xs:string, 
    $id as xs:string,
    $lang as xs:string
)
as document-node()
{
    (:corresponding pb for this facsimile:)
    let $pb := $page/root()//tei:pb[substring-after(@facs, '#') = $id]
    
    return (:document{<html>no={$pb/following::tei:pb[1]/@facs/data()}</html>}:)
    xslt:transform(
        $page,
        doc('xsl/page.xsl'),
        map{
        'catNum':$catNum, 'id':$id, 'lang':$lang,
        'pageNum':string($pb/@n), (:if absent, use empty string:)
        'nextPageID':substring-after($pb/following::tei:pb[1]/@facs, '#'),
        'prevPageID':substring-after($pb/preceding::tei:pb[1]/@facs, '#')
        }
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
as element(html)
{    

    <html lang="en">
      <head>
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <meta name="description" content=""/>
        <meta name="author" content=""/>
        <link rel="icon" href="../../favicon.ico"/>
    
        <title>ALO metadata review</title>
    
        <!-- Bootstrap core CSS -->
        <link href="../static/bootstrap.min.css" rel="stylesheet"/>
    
        <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
        <link href="../../assets/css/ie10-viewport-bug-workaround.css" rel="stylesheet"/>
    
        <!-- Custom styles for this template -->
        <link href="../static/signin.css" rel="stylesheet"/>
    
        <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
        <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
        <script src="../../assets/js/ie-emulation-modes-warning.js"></script>
    
        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->
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
  %rest:path("/ContentBase/logout")
  %output:method("html")
  %rest:cookie-param("user", "{$user}")
function cms:logout($user as xs:string?)
as element()
{  
    (:TODO: add Secure for HTTPS:)
    <rest:response>
      <http:response status='302'>
        <http:header name="Set-Cookie" value="user={$user}; HttpOnly; path=/; Max-Age=0"/>
        <http:header name="location" value="/ContentBase/login"/>
      </http:response>
    </rest:response>
  
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
            {$body/metadata/(@* except @when, @who) }
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