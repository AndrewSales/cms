xquery version "3.0";
module namespace cms = "http://www.andrewsales.com/xquery";
import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";


declare variable $cms:collConfig := doc('/ContentBase/collection/config/user-edit-permissions.xml');
declare variable $cms:collBase := $cms:collConfig/collection/@xml:base;
declare variable $cms:reviewBase := $cms:collBase/../review;
declare variable $cms:user := user:current();

(:Files assigned to the current user:)
declare function cms:collection-for-user($user) 
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
function cms:collection($user) 
as element(html)
{
    (:TODO: handle lack of user :)
  
  <html>
     <head>
       <title>ContentBase</title>
     </head>
     <body>       
       <div>Documents for: <span>{$user}</span></div>
       {
           for $file in cms:collection-for-user($user)
           let $doc := doc(string-join(($cms:collBase, $file/@url), '/'))
           return 
           <div><a href='toc?url={$file/@url}'>{substring-before($file/@url/data(), '.xml')}</a>
           {($doc//*:author[not(@role)])[1]/*:persName[@type='default'][lang('en')], $doc//*:title[@type='originalFull']/data()}
           </div>
       }
     </body>
   </html>
};

declare 
  %rest:path("/ContentBase/toc") 
  %rest:query-param("url", "{$url}")
  %output:method("html")
function cms:toc($url) 
as document-node()
{
    (:let $thisFile := $cms:myColl[@url = $url]:)
  
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
  %rest:query-param("url", "{$url}")
  %rest:query-param("id", "{$id}")
  %output:method("xml") 
  %output:omit-xml-declaration("yes")
  %output:indent("no")
function cms:work($url, $id) 
as document-node()
{
  let $reviewURL := $cms:reviewBase || '/' || $url

  return
  if(doc-available($reviewURL))
  then
    xslt:transform(
             doc($reviewURL),
             doc('xsl/metadata2xform.xsl')
             )
    else
    xslt:transform(
             doc($cms:collBase || '/' || $url),
             doc('xsl/tei2xform.xsl'),
             map{
                'sys-id':$url, 
                'id':$id, 
                'xsltformsStylesheet':'../static/xsltforms/xsltforms.xsl'
                }
             )
};

declare 
  %rest:path("/ContentBase/section") 
  %rest:query-param("url", "{$url}")
  %rest:query-param("id", "{$id}")
  %output:method("html")
function cms:section($url, $id) 
as document-node()
{
  xslt:transform(
             doc($cms:collBase || '/' || $url),
             doc('xsl/section.xsl'),
             map{'sys-id':$url, 'id':$id}
             )
};

declare 
  %rest:path("/ContentBase/page") 
  %rest:query-param("id", "{$id}")
  %rest:query-param("url", "{$url}")
  %output:method("xhtml")
function cms:page($url, $id) 
as document-node()
{
  xslt:transform(
             doc($cms:collBase || '/' || $url),
             doc('xsl/page.xsl'),
             map{'sys-id':$url, 'id':$id}
             )
};

declare 
  %rest:path("/ContentBase/login")
  %output:method("html")
function cms:login()
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

    <title>Signin Template for Bootstrap</title>

    <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"/>

<!-- Custom styles for this template -->
    <link href="{resolve-uri('signin.css', static-base-uri())}" rel="stylesheet"/>

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="container">

      <form class="form-signin" action='authenticate' method='post'>
        <h2 class="form-signin-heading">Please sign in</h2>
        <label for="inputEmail" class="sr-only">Email address</label>
        <input id="inputEmail" name='username' class="form-control" placeholder="Email address" required='' autofocus=''/>
        <label for="inputPassword" class="sr-only">Password</label>
        <input name='password' type="password" id="inputPassword" class="form-control" placeholder="Password" required=''/>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
      </form>

    </div> <!-- /container -->


    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="../../assets/js/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>

};

declare 
  %updating
  %rest:path("/ContentBase/test")
  %rest:POST("{$body}")
  %rest:query-param("url", "{$url}")
  %rest:query-param("lang", "{$lang}")
  %output:method("html")
function cms:test($body, $url, $lang)
{
    let $path := '/collection/content/review/' || $url || '@' || $lang
    let $doc := 
        <metadata when='{current-dateTime()}' who='{session:get("user")}'>
            {$body/metadata/@xml:id}
            {$body/*/*}
        </metadata>
    return db:replace('ContentBase', $path, $doc)
};

declare 
  %rest:path("/ContentBase/authenticate")
  %rest:POST
  %output:method("html")
  %rest:form-param("username", "{$username}", "(none)")
  %rest:form-param("password", "{$password}", "(none)")
function cms:checkLogin($username, $password)
{
  if(cms:check($username, $password))
  then
    (:TODO: add Secure for HTTPS; set Expires or Max-Age:)
    (session:set("user", string($username)),
        <rest:response>
      <http:response status='302'>    
        <http:header name="Set-Cookie" value="user={$username}; HttpOnly; path=/"/>
        <http:header name="location" value="/ContentBase/collection"/>
      </http:response>
    </rest:response>)
    else "BAD!!"    (:TODO: something more graceful...:)
  
};

(:taken from https://github.com/BaseXdb/basex/issues/1326,
pending release of 8.6 and user:check-user() :)
declare function cms:check($name as xs:string, $password as xs:string)
as xs:boolean
{
  let $pw := user:list-details($name)/password[@algorithm = 'salted-sha256']
  let $hash := lower-case(string(xs:hexBinary(hash:sha256($pw/salt || $password))))
  return $pw/hash = $hash
  
};