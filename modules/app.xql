xquery version "3.1";

module namespace app="http://www.example.org/abesabesi/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.example.org/abesabesi/config" at "config.xqm";
import module namespace dict="http://www.example.org/abesabesi/dict" at "dict.xql";
import module namespace search="http://www.example.org/abesabesi/search" at "search.xql";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace en="https://endnote.com/";

 
declare variable $app:doc := doc("/db/apps/Abesabesi/resources/data/ekirom.xml");
declare variable $app:examples := doc("/db/apps/Abesabesi/resources/data/examples.xml");
declare variable $app:terms := doc("/db/apps/Abesabesi/resources/data/terminology.xml");
declare variable $app:abbreviations := doc("/db/apps/Abesabesi/resources/data/glossary.xml");
declare variable $app:bibliography:= doc("/db/apps/Abesabesi/resources/data/bibliography.xml");
declare variable $app:default := "ch1";
declare variable $app:default-text := "ibe035-00m";


(:-------------------------TITLE------------------------------------:)

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute: data-template="app:test" or class="app:test" (deprecated). 
 : The function has to take 2 default parameters. Additional parameters are automatically mapped to
 : any matching request or function parameter.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
 

 
declare function app:title($node as node(), $model as map(*))
{
    let $id:= request:get-parameter('section', $app:default)
    let $no := app:section-number($id)
    let $title := app:section-head($id)
    return 
        <div title="Please cite this section as follows: Lau, J. (2021) {$title}. Abesabesi Grammar. http://abesabesi.cceh.uni-koeln.de/">
            <h2 class="w3-center">
            {concat($no, " ")} {$title}
            </h2>
        </div>
};

declare function app:section-head($id as xs:string){
    let $section:= $app:doc/TEI/text/body//div[@xml:id = $id]
    return app:text($section/head)
};

declare function app:section-number($id as xs:string){
    let $section:= $app:doc/TEI/text/body//div[@xml:id = $id]
    return data($section/@n)
};

declare function app:tags($node as node(), $model as map(*), $tag as xs:string, $color as xs:string)
{
   
    let $page-id:= request:get-parameter('section', $app:default)
    let $section:= $app:doc/TEI/text/body//div[@xml:id = $page-id]
    let $note := $section/note[@ana = $tag]
    let $width := data($note/@cert)
    return
        if (empty($width))
        then
            <i class="w3-text-white" style="padding-left:5px"> no figures</i>
        else if (not($note/node()))
        then
            <div class="w3-container {$color} jl-progress" style="width:{$width}%; padding:0;"><span style="padding-left:5px">{$width}%</span></div>
        else 
            <div class="w3-container {$color} jl-progress" style="width:{$width}%; padding:0;"><span style="padding-left:5px">{data($note)}</span></div>
        
};
(:-------------------------------------BIB-------------------------------------------------------:)
declare function app:bibliography($node as node(), $model as map(*)) 
{
   let $entry-id:= request:get-parameter('entry', 'full')
   return
        if ($entry-id = 'full')
        then
            app:bibliographyFull()
        else
            app:bibliographyEntry($entry-id)
};
        
declare function app:bibliographyFull()
{
let $records:= $app:bibliography//en:record
    return
         <ol class="toc">
             {for $record in $records
                return
                    <li>
                    <a class="jl-txt" style="display:inline-block; padding: 20px 20px; text-indent: -20px;"  href="bibliography.html?entry={data($record/@xml:id)}">
                        {app:bibname($record)} ({app:bibdate($record)}). {app:bibtitle($record)}
                        </a>
                    </li>}
        </ol>
};
     
declare function app:bibliographyEntry($entry-id as xs:string)
{
    let $entry:= $app:bibliography//en:record[@xml:id=$entry-id]
    let $ref-type:= data($entry/en:ref-type)
    return
        <div>
            <table class="w3-table">
                      <tr>
                        <td>Author</td><td>{app:bibname($entry)}</td>
                     </tr>
                        <tr>
                        <td>Year</td><td>{app:bibdate($entry)}</td>
                        </tr>
                        <tr>
                        <td>Title</td><td>{app:bibtitle($entry)}</td>
                        </tr>
                         {
                         
                         if ($ref-type=1)
                            then
                                app:bibBook($entry)
                            else if ($ref-type=0)
                            then
                                app:bibJournal($entry)
                            else if ($ref-type=3)
                            then
                                app:bibProceedings($entry)
                            else if ($ref-type=7)
                            then
                                app:bibSection($entry)
                            else if ($ref-type=16)
                            then
                                app:bibWeb($entry)
                            else
                            
                                ()}                     
            </table>
            <a class="w3-button" style="float:right; color:#aaa" href="bibliography.html">Full Bibliography</a>
        </div>
        
        
 };
 
 declare function app:bibBook ($entry as node())
 {
    <tr>
        <td>Publisher</td><td class="jl-txt">{data($entry/en:pub-location)}: {data($entry/en:publisher)}</td>
    </tr>                    
 };
 
  declare function app:bibJournal ($entry as node())
 {
    <tr>
        <td>Journal</td><td class="jl-txt">{data($entry/en:periodical/en:full-title)}, {data($entry/en:volume)}, pp. {data($entry/en:pages)}</td>
    </tr>                    
 };
 
  declare function app:bibWeb ($entry as node())
 {
    let $url := data($entry/en:urls/en:web-urls/en:url)
    return
    <div>
    <tr>
        <td>Publication</td><td class="jl-txt">{data($entry/en:periodical/en:full-title)}</td>
    </tr> 
    <tr>
        <td>Website</td><td><a href="{$url}">{$url}</a></td>
    </tr>
    </div>
 };
 
  declare function app:bibSection ($entry as node())
 {
    let $url := data($entry/en:urls/en:web-urls/en:url)
    return
    <div>
    <tr>
        <td>Book</td><td class="jl-txt">{data($entry/en:periodical/en:full-title)}, pp. {data($entry/en:pages)}</td>
    </tr> 
    <tr>
        <td>Editors</td><td class="jl-txt">{data($entry/en:contributors/en:secondary-authors/en:author)}</td>
    </tr>
    <tr>
        <td>Publisher</td><td class="jl-txt">{data($entry/en:pub-location)}: {data($entry/en:publisher)}</td>
    </tr>
    </div>
 };
 
  declare function app:bibProceedings ($entry as node())
 {
    <tr>
        <td>Publication</td><td class="jl-txt">{data($entry/en:periodical/en:full-title)}</td>
    </tr> 
 };

declare function app:bibname($record as node()) 
{
  let $author:= $record/en:contributors/en:authors/en:author
  return
    <span class="jl-txt">{data($author)}</span>
         
};

declare function app:bibdate($record as node()) 
{
  let $date:= $record/en:dates/en:year
  return
    <span class="jl-txt">{data($date)}</span>
};

declare function app:bibtitle($record as node()) 
{
  let $title:= $record/en:titles/en:title
  return
    <i class="jl-txt">{data($title)}</i>
};

(:-------------------------------------TOC-------------------------------------------------------:)

declare function app:toc($node as node(), $model as map(*)) 
{
    let $body:= $app:doc/TEI/text/body
    return
         <ol class="toc">
             {for $div in $body/div
                return
                    app:toc-child($div)}
        </ol>
};

declare function app:toc-child($node as node()){
    let $child := "a"
    return
        if (exists($node/div))
        then
            <li>
                <span class="w3-padding">{data($node/@n)}</span>
                <a href="grammar-entry.html?section={$node/@xml:id}" class="w3-button">
                    {data($node/head)}
                </a>
                <div class="w3-button w3-text-teal" style="cursor:pointer" onClick="showLevelBeneath(this)" title="Show subsections">
                    <i class="fa fa-caret-right"/>
                </div>
            
                <ol class="toc" style="display:none">
                    {
                    for $div in $node/div
                    return
                        app:toc-child($div)
                    }
                </ol>
            </li>
        else
            <li>
                <span class="w3-padding">{data($node/@n)}</span>
                <a href="grammar-entry.html?section={$node/@xml:id}" class="w3-button">
                    {data($node/head)}
                </a>
                {
                        if ($node/@type = 'fomp')
                        then 
                            <div class="w3-button w3-text-teal" style="cursor:pointer" onClick="" title="Show functions">
                            <i class="fa fa-exchange-alt"/>
                             </div>
                        else
                            ()
                }
            </li>
};

(:================================================TEXTS============================================:)

declare function app:content-text($node as node(), $model as map(*))
{
    let $text-id:= request:get-parameter('text', $app:default-text)
   (: let $text:= doc("/db/apps/Abesabesi/resources/data/texts/{$text-id}.xml"):)
   let $text:= doc("/db/apps/Abesabesi/resources/data/texts/ibe035-00m.xml")
    return
        for $utterance in $text/TEI//u
        return
            
        <div class="w3-padding-16 w3-container w3-white w3-margin-bottom" >
            <div style="overflow-x:auto;">
                <table class="w3-table" style="width:auto">
                     <tr class="jl-txt">
                        <td>{data($utterance/@n)}</td>
                        {for $word in $utterance//w
                        return
                        if ($word/@lemmaRef)
                        then 
                        <td>
                        <a href="dictionary.html?entry={data(app:getSecondPartOfTarget($word/@lemmaRef))}">
                        {data($word/note[@ana = "#txt"])}
                        </a></td>
                        else
                        <td>{data($word/note[@ana = "#txt"])}</td>
                        }
                    </tr>
                    <tr class="jl-gloss"> 
                        <td></td>
                        {for $word in $utterance//w
                        return
                        <td>{app:exGloss($word/note[@ana='#gls'])}</td>}
                    </tr>
                    <tr>
                        <td></td>
                        <td colspan="19">'{data($utterance/note[@ana='#gls'])}'</td>
                    </tr>
                </table>
            </div>
        </div>
};

declare function app:texts($node as node(), $model as map(*))
{
    <div class="w3-bar-block w3-white">
            <a class="w3-button w3-bar-item" style="padding-left:35px;">Pear Story Awolami (ibe023-00)</a>
            <a class="w3-button w3-bar-item" style="padding-left:35px;">Planting Yam (ibe035-00)</a>   
            <a class="w3-button w3-bar-item" style="padding-left:35px;">Parents Elegbeleye (ibe065-00)</a>
            <a class="w3-button w3-bar-item" style="padding-left:35px;">Tortoise and the Pond (ibe301-00)</a>
    </div>
};

declare function app:previousText($node as node(), $model as map(*))
{
    <div class="w3-container w3-padding-16 w3-text-grey " style="cursor:pointer">
    
            <a class= "jl-hover-opacity w3-right" title="previous text">
                                <i class="fa fa-chevron-left w3-jumbo"/>
            </a>
      
    </div>
};

declare function app:nextText($node as node(), $model as map(*))
{
   <div class="w3-container w3-padding-16 w3-text-grey " style="cursor:pointer">
    
            <a class= "jl-hover-opacity w3-left" title="following text">
                                <i class="fa fa-chevron-right w3-jumbo"/>
            </a>
      
    </div>
};

declare function app:title-text($node as node(), $model as map(*))
{
    <div title="Please cite this section as follows: Haruna, A. (2019). Planting Yam. In J. Lau, Documentation of Abesabesi. Retrieved [date], from https://elar.soas.ac.uk/Collection/MPI1207813">
            <h2 class="w3-center">
            ibe035-00: Planting Yam
            </h2>
        </div>
};


declare function app:audio($node as node(), $model as map(*))
{
   <audio class="w3-bar-item w3-hide" id="audio" controls="controls">
        <source src="resources/recordings/ibe120-00m.wav" type="video/wav"/>
        Your browser does not support the audio tag.
    </audio>
};


declare function app:video($node as node(), $model as map(*))
{
    <video class="w3-bar-item w3-hide" id="video" controls="controls">
        <source src="resources/recordings/ibe120-00m.mp4#t=20,50" type="video/mp4"/>
        Your browser does not support the video tag.
    </video>
};

(:====================================================CONTENT======================================:)

declare function app:content($node as node(), $model as map(*))
{
    
    let $page-id:= request:get-parameter('section', $app:default)
    let $section:= $app:doc/TEI/text/body//div[@xml:id = $page-id]
    return
        <div>
            {
                for $element in $section/* 
                let $id := data($element/@xml:id)
                return
                    if (name($element) = 'head' or name($element)= 'note')
                    then
                        ()
                    else if (name($element) ='list')
                    then
                        app:list($element)
                    else if (name($element) ='entry')
                    then
                        app:entry($element)
                        else
                            if (name($element) = 'table')
                            then
                                app:table($element)
                            else
                                if (name($element) = 'joinGrp')
                                then 
                                    app:examples($element)
                                else
                                    if (name($element) = 'figure')
                                    then
                                        app:figure($element)
                                    else
                                        if (name($element) = 'p')
                                        then
                                            app:text-card($element)
                                        else
                                        ()
            }
            {
                if ($section/p or $section/table or $section/figure or $section/joinGrp or $section/entry)
                then
                    ()
                else
                    <div class="w3-padding-16 w3-container w3-white w3-margin-bottom">
                    No content available at the moment.
                    </div>
            }
            
        </div>
};

declare function app:text-card($node as node())
{
    let $id := data($node/@xml:id)
    return
        <div class="w3-padding-16 w3-container w3-white w3-margin-bottom">
            {app:text($node)}
            <button class="w3-button" style="float:right; color:#aaa" onclick="openMod('modCite', '{$id}')">Cite</button>
        </div> 
};

declare function app:cite($node as node(), $model as map(*), $id as xs:string){
     let $page-id:= request:get-parameter('section', $app:default)
     let $section:= $app:doc/TEI/text/body//div[@xml:id = $page-id]
     return
        <p class="" id="modCite-inner">Lau, J. (2021) {$section/head}. <i>Abesabesi Grammar</i>. http://abesabesi.cceh.uni-koeln.de/ {$id}</p>

};

declare function app:text($node as node()){
    for $element in $node/node()
            return
                if (name($element) = 'ref')
                then
                    app:ref($element)
                else if (name($element) = 'foreign')
                then
                    <span class="jl-txt">{data($element)}</span>
                else if (name($element) = 'name')
                then
                    <span>"{data($element)}"</span>
                else if (name($element) = 'note')
                then
                    <sup class="w3-text-teal" style="cursor:pointer" title="{data($element)}">{data($element/@n)}</sup>
                else if (name($element) = 'unclear')
                then
                    <span class="jl-unclear">{data($element)}</span>
                else if (name($element) ='gloss')
                then
                    <span style="font-size:13px; letter-spacing: 1px;">'{app:text($element)}'</span>
                else if (name($element) = 'abbr')
                then
                    app:abbr($element)
                else if (name($element) ='list')
                then ()
                else if (name($element) ='term')
                then
                    if ($element/@ref)
                    then
                     <a href="{app:resolve-target-uri($element/@ref)}">{data($element)}</a>
                    else
                        <a>{data($element)}</a>
                else
                    data($element)
                    };

declare function app:abbr($node as node()){
    let $target := app:getSecondPartOfTarget($node/@corresp)
    let $item := $app:abbreviations/TEI/text/body//item[@xml:id = $target]
    let $expan := $item/expan
    return
        <abbr style="text-decoration:none" title="{data($expan)}" href="glossary.html">{data($item/abbr)}</abbr>
    
};

declare function app:ref($node as node()){
    if (data($node))
    then
        if ($node/@type = "pair" or $node/@type = "lemma")
        then
            app:refPair($node)
        else
        <a class="intext-button" href="{app:resolve-target-uri($node/@target)}">{data($node)}</a>
    else
        if (fn:starts-with($node/@target, '#ch'))
        then
            <a class="intext-button" href="{app:resolve-target-uri($node/@target)}">
            {data($app:doc//fn:id(fn:substring(data($node/@target),2))/@n)}
                
            </a>
        else
           if (fn:starts-with($node/@target, '#'))
           then
                <a class="intext-button" href="{$node/@target}">
                {data($app:doc//fn:id(fn:substring(data($node/@target),2))/@n)}
                   
                </a>
             else
            ()
};

declare function app:refPair($ref as node()) {
<a  href="{app:resolve-target-uri($ref/@target)}">{app:text($ref)}</a>
};

declare function app:resolve-target-uri($target as xs:string)
{
    let $parts := fn:tokenize($target, "#")
    return
        if (fn:starts-with($target, "#ch"))
        then
            concat("grammar-entry.html?section=", substring($target, 2))
        else
            if (fn:starts-with($target, "#"))
            then
                $target
            else
                if ($parts[1] = "dictionary.xml")
                then
                    concat("dictionary.html?entry=", $parts[2])
                else if ($parts[1] = "terminology.xml")
                then
                    concat("index-list.html?entry=", $parts[2])
                else if ($parts[1] = "glossary.xml")
                then
                    concat("index-list.html?entry=", $parts[2])
                else if ($parts[1] = "bibliography.xml")
                then
                    concat("bibliography.html?entry=", $parts[2])
                else if ($parts[1] = "web")
                then
                    $parts[2]
                else
                    concat("grammar-entry.html?section=", substring($target, 2))
};

declare function app:getSecondPartOfTarget ($target as xs:string){
    (fn:tokenize($target, "#"))[2]};



(:============================================EXAMPLES=========================================================:)

declare function app:exampleDatabase($node as node(), $model as map(*))
{
    for $example at $counter in $app:examples//body/cit
    let $id := $example/@xml:id
    order by $id
    return
    <div>
        <h6 id="{data($id)}">{data($id)}</h6>
        <div class="w3-padding-16 w3-container w3-white w3-margin-bottom" >
        <div style="overflow-x:auto;">
            
                {app:singleExample($example)}
               {app:ex-more($example, data($id), xs:string($counter))}
        </div>       
    </div>
    </div>
};
       

declare function app:ex-more($example as node(), $id as xs:string, $counter as xs:string)
{
    <div>
    <hr style="margin:5px 0 5px 0"></hr>
        <a class="w3-button w3-small" onclick="myAccFunc('more{$counter}')">more ...</a>
        <div id="more{$counter}" class="w3-hide">
            <div class="w3-half w3-small">
                <nav class="w3-bar-block w3-white">
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('audio{$counter}')">Audio</a>
                    <audio class="w3-bar-item w3-hide" id="audio{$counter}" controls="controls">
                        <source src="resources/recordings/ibe120-00m.wav" type="video/wav"/>
                        Your browser does not support the audio tag.
                    </audio>
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('video{$counter}')">Video</a>
                    <video class="w3-bar-item w3-hide" id="video{$counter}" controls="controls">
                        <source src="resources/recordings/ibe120-00m.mp4#t=20,50" type="video/mp4"/>
                        Your browser does not support the video tag.
                    </video>
                    <a class="w3-button w3-bar-item">Text Context</a>
                </nav>
            </div>
            <div class="w3-half w3-small">
                <nav class="w3-bar-block w3-white">
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('metadata-ex{$counter}')">Metadata</a>
                    <div class="w3-hide" id="metadata-ex{$counter}">
                    </div>
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('keywords-ex{$counter}')">Keywords</a>
                    <div class="w3-hide" id="keywords-ex{$counter}">
                        {for $term in $example/index/term
                    let $target := app:getSecondPartOfTarget($term/@ref)
                    order by $target
                    return app:keyword($target)}
                    </div>
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('usedInSection{$counter}')">Used in Section</a>
                    <div class="w3-hide" id="usedInSection{$counter}">
                        {let $textExamples := $app:doc/TEI/text/body//joinGrp/ptr[fn:ends-with(data(@target),$id)] 
                         for $usedExample in $textExamples
                         let $section := $usedExample/../..
                         let $joinGrp-ID := $usedExample/../@xml:id
                         return
                            <a class="w3-bar-item w3-button" style="padding-left:35px;" href="grammar-entry.html?section={data($section/@xml:id)}#{data($joinGrp-ID)}">{data($section/@n)}</a>
                    }
                    </div>
                </nav>
              </div>
           </div>
        </div>
};

declare function app:ex-more-ge($example as node(), $id as xs:string, $counter as xs:string)
{
    <div>
    <hr style="margin:5px 0 5px 0"></hr>
        <a class="w3-button w3-small" onclick="myAccFunc('more{$counter}')">more ...</a>
        <div id="more{$counter}" class="w3-hide">
            <div class="w3-half w3-small">
                <nav class="w3-bar-block w3-white">
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('audio{$counter}')">Audio</a>
                    <audio class="w3-bar-item w3-hide" id="audio{$counter}" controls="controls">
                        <source src="resources/recordings/ibe120-00m.wav" type="video/wav"/>
                        Your browser does not support the audio tag.
                    </audio>
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('video{$counter}')">Video</a>
                    <video class="w3-bar-item w3-hide" id="video{$counter}" controls="controls">
                        <source src="resources/recordings/ibe120-00m.mp4#t=20,50" type="video/mp4"/>
                        Your browser does not support the video tag.
                    </video>
                    <a class="w3-button w3-bar-item">Text Context</a>
                </nav>
            </div>
            <div class="w3-half w3-small">
                <nav class="w3-bar-block w3-white">
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('metadata-ex{$counter}')">Metadata</a>
                    <div class="w3-hide" id="metadata-ex{$counter}">
                    </div>
                    <a class="w3-button w3-bar-item" onclick="myAccFunc('keywords-ex{$counter}')">Keywords</a>
                    <div class="w3-hide" id="keywords-ex{$counter}">
                        {for $term in $example/index/term
                    let $target := app:getSecondPartOfTarget($term/@ref)
                    order by $target
                    return app:keyword($target)}
                    </div>
                </nav>
              </div>
           </div>
        </div>
};

(:

<a class="w3-bar-item w3-button w3-margin-left"></a>


 
:)
declare function app:singleExample($example as node())
{
     let $id := $example/@xml:id 
     return
        <table class="w3-table" style="width:auto">
             <tr class="jl-txt">
                {for $word in $example//w
                
                return
                if ($word/@lemmaRef)
                then 
                <td>
                <a href="dictionary.html?entry={data(app:getSecondPartOfTarget($word/@lemmaRef))}">
                {data($word/note[@ana = "#txt"])}
                </a></td>
                else
                <td>{data($word/note[@ana = "#txt"])}</td>
                }
            </tr>
            <tr class="jl-gloss"> 
                {for $word in $example//w
                return
                <td>{app:exGloss($word/note[@ana='#gls'])}</td>}
            </tr>
            <tr>
                <td colspan="19">'{data($example/quote/s/note)}'</td>
            </tr>
        </table>
};



declare function app:examples($exGroup as node())
{
    let $examples-body := $app:examples//body
    return
        <div class="w3-padding-16 w3-container w3-white w3-margin-bottom" >
        <div style="overflow-x:auto;">
            <table class="w3-table" style="width:auto" id="{data($exGroup/@xml:id)}" >
                {    
                    for $example in $exGroup/ptr
                    let $id := substring(data($example/@target), 14)
                    let $n := fn:concat(data($exGroup/@n), data($example/@n))
                    return
                        <tr>
                          {
                            if ($example is $exGroup/ptr[1])
                            then
                                <tr><td>{data($exGroup/@n)}</td><td>{data($example/@n)}</td>{app:example($id, $n)}</tr>

                                
                            else
                                <tr><td></td><td>{data($example/@n)}</td>{app:example($id,$n)}</tr>

                            }
                        </tr>
                                
                }
            </table> 
            </div>
            <button class="w3-button" style="float:right; color:#aaa" onclick="openMod('modCite', '')">Cite</button>
        </div>
};

declare function app:example($id as xs:string, $n as xs:string){
        let $example := $app:examples/TEI/text/body/cit[@xml:id=$id] 
        return
        <tr>
             <tr class="jl-txt">
                <td></td>
                <td></td>
                {for $word in $example//w
                return
                    if ($word/@lemmaRef)
                    then 
                    <td>
                    <a href="dictionary.html?entry={data(app:getSecondPartOfTarget($word/@lemmaRef))}">
                    {data($word/note[@ana = "#txt"])}
                    </a></td>
                    else
                    <td>{data($word/note[@ana = "#txt"])}</td>
                }
            </tr>
            <tr class="jl-gloss"> 
                <td/>
                <td/>
                {for $word in $example//w
                return
                <td>{app:exGloss($word/note[@ana = "#gls"])}</td>}
            </tr>
            <tr>
                <td/>
                <td/>
                <td colspan="19">'{data($example/quote/s/note[@ana="#gls"])}' ({$id})</td>
            </tr>
            <tr>
            <td> </td><td></td><td colspan="17">
            {app:ex-more-ge($example, $id, $n)}
            </td>
            </tr>
        </tr>
};

declare function app:exGloss($gloss as node()){
    for $element in $gloss/node()
    return
        if (name($element) ='abbr')
        then
            let $target := app:getSecondPartOfTarget($element/@corresp)
            let $item:= $app:abbreviations/TEI/text/body//item[data(@xml:id) eq $target]
            let $expan := $item/expan
            return
            <a style="font-variant-caps: all-small-caps;" title="{data($expan)}" href="glossary.html">{data($item/abbr)}</a>
      else
            data($element)
           
};

(:====================================================================ENTRY=================================================:)

declare function app:entry($entry as node()){
    let $subtype-div := data($entry/../@subtype)
    let $subtype := if ($subtype-div) then $subtype-div else app:find-subtype($entry)
    return
       <div class="w3-container w3-padding-16 w3-white w3-margin-bottom">
            <div class="jl-bar">
                {app:get-entry-header($entry, $subtype)}
            </div>
            <hr/>
            <table class="w3-table">
                {app:get-entry-middle($entry, $subtype)}
                <tr style="border-bottom:1px solid #eee; margin:20px 0">
                    <td colspan="100%"></td>
                </tr>
              {app:get-entry-footer($entry)}
            </table>
        </div>
};

declare function app:find-subtype($node as node()){
    if ($node/form/form[@type ='allomorph'])
    then
        (:for simple forms:)
        "form"
    else if ($node/form/form[@type = 'formula'])
    then
        (:for constructions:)
        "construction"
    else
        (:for simple functions:)
        "function"
};

declare function app:get-entry-header($entry as node(), $subtype as xs:string){
    if ($subtype = "form")
    then
        app:form-header($entry)
    else if ($subtype = "construction")
    then
        app:construction-header($entry)
    else if ($subtype = "function")
    then
        app:function-header($entry)
    else
        app:default-header($entry)
};

declare function app:get-entry-middle($entry as node(), $subtype as xs:string){
    if ($subtype = "form")
    then
        app:form-middle($entry)
    else if ($subtype = "construction")
    then
        app:construction-middle($entry)
    else if ($subtype = "function")
    then
        app:function-middle($entry)
    else
        app:default-middle($entry)
};

declare function app:get-entry-footer($entry as node()){
    if ($entry/xr[@type = "construction"])
    then
        for $construction in $entry/xr[@type = "construction"]
        let $location := substring(data($construction/ptr/@target), 2)
        return
            if ($construction = ($entry/xr[@type = "construction"][1]))
            then
                <tr><td><b>Component of</b></td>
                <td><a class="intext-button" href="grammar-entry.html?section={$location}">{app:section-head($location)}</a></td></tr>
            else
                <tr><td></td><td><a class="intext-button" href="grammar-entry.html?section={$location}">{app:section-head($location)}</a></td></tr>
    else if ($entry/xr[@type = "component"])
    then
        for $construction in $entry/xr[@type = "component"]
        let $location := substring(data($construction/ptr/@target), 2)
        return
            if ($construction = $entry/xr[@type = "component"][1])
            then
                <tr><td><b>Components</b></td>
                <td><a class="intext-button" href="grammar-entry.html?section={$location}">{app:section-head($location)}</a></td></tr>
            else
                <tr><td></td><td><a class="intext-button" href="grammar-entry.html?section={$location}">{app:section-head($location)}</a></td></tr>
    else
        ()
    
};

declare function app:form-header($entry as node()){
    <span>
        {
            for $form in $entry/form/form[@type='allomorph']
            let $allomorph := 
                 if ($form is $entry/form/form[@type='allomorph'][1])
                then
                    data($form/orth)
                else
                    concat(" | ", data($form/orth))
            return 
                if ($form/pron) 
                then 
                    <span class="jl-bar" title="Allomorphs">
                        <h1 class="jl-dict-entry">{$allomorph}</h1>
                        <h5 class="jl-dict-entry" title="IPA"> [{data($form/pron)}] </h5>        
                    </span>
                else data($allomorph)
            }
        {app:get-morphological-info($entry)}
    </span>
};

declare function app:get-morphological-info($entry as node()){
    if ($entry/form/gramGrp/gram[@type = "pos"])
    then
        <i class="jl-dict-entry" title="POS">{data($entry/form/gramGrp/gram[@type = "pos"])}</i>
    else
        ()
};

declare function app:construction-header($entry as node()){
      for $formula in $entry/form/form[@type='formula']
      return
          <h1 class="jl-dict-entry">
          {app:text($formula)}</h1>,
          <i class="jl-dict-entry">construction</i>
};

declare function app:function-header($entry as node()){
          <h1 class="jl-dict-entry">
          {data($entry/../head)}</h1>,
          <i class="jl-dict-entry">function</i>
};

declare function app:default-header($entry as node()){
          <h1 class="jl-dict-entry">
          {data($entry/parent::node/head)}</h1>,
          app:get-morphological-info($entry)
};


declare function app:form-middle($entry as node()){
    <tr>
        <th>Functions</th>
        <th>Glosses</th>
    </tr>,
    
    for $sense in $entry/sense
    let $location := substring(data($sense/@location), 2)
    return 
        <tr>
            <td><a class="intext-button" href="grammar-entry.html?section={$location}">{app:section-head($location)}</a></td>
            {if ($sense/gloss)
            then
                let $gloss-target := data($sense/gloss/@target)
                return
                    <td style="font-variant:small-caps" title="{app:get-item($gloss-target)}">
                        {app:get-label($gloss-target)}
                    </td>
            else
                ()
            }
        </tr>
};

declare function app:construction-middle($entry as node()){
      for $sense in $entry/sense
      let $location := substring(data($sense/@location), 2)
        return
            if ($sense = $entry/sense[1])
            then
                <tr>
                    <td><b>Functions</b></td>
                    <td><a class="intext-button" href="grammar-entry.html?section={$location}">{app:section-head($location)}</a></td>
                </tr>
            else
                <tr><td></td><td><a class="intext-button" href="grammar-entry.html?section={$location}">{app:section-head($location)}</a></td></tr>
};

declare function app:function-middle($entry as node()){
    <tr>
        <th>Forms</th>
        <th>Glosses</th>
    </tr>,
    
    for $form in $entry/form
    let $location := substring(data($form/@location), 2)
    return 
        <tr>
            <td><a class="intext-button" href="grammar-entry.html?section={$location}">{app:section-head($location)}</a></td>
            {if ($form/gloss)
            then
                let $gloss-target := data($form/gloss/@target)
                return
                    <td style="font-variant:small-caps" title="{app:get-item($gloss-target)}">
                        {app:get-label($gloss-target)}
                    </td>
            else
                <td> - </td>
            }
        </tr>
};

declare function app:default-middle($entry as node()){
    if ($entry/form/gloss)
    then
        app:function-middle($entry)
    else if ($entry/sense/gloss)
    then
        app:form-middle($entry)
    else
        ()
        
};

declare function app:resolve-pointer($target as xs:string)
{
    let $parts := fn:tokenize($target, "#")
    return
        if (fn:count($parts) = 2)
        then
            let $doc-name := data($parts[1])
            let $doc-uri := concat("/db/apps/Abesabesi/resources/data/" , $doc-name)
            let $id := data($parts[2])
            return doc($doc-uri)/TEI/text/body/list//item[@xml:id = $id]
        else
            ()
};

declare function app:get-label($target as xs:string){
    let $item := app:resolve-pointer($target)
    return
        data($item/abbr)
};

declare function app:get-item($target as xs:string){
    let $item := app:resolve-pointer($target)
    return
        data($item/expan)
};


(:===============================================================FIGURE AND TABLE===========================================================:)

declare function app:list($list as node())
{
let $id := data($list/@xml:id)
return
 <div id="{$id}">
        {if ($list/head)
        then
            <h5>{concat("List ", data($list/@n), ": ", data($list/head))}</h5>
        else
            ()
        }
    <div class="w3-padding-16 w3-container w3-white w3-margin-bottom" >
    <ul>
        {       
        for $item in $list/item
        return
           app:list-child($item)
        }   
    </ul>
    <button class="w3-button" style="float:right; color:#aaa" onclick="openMod('modCite', '')">Cite</button>
        </div>
    </div>
};

declare function app:list-child($item as node())
{
    <li>
        {app:text($item)}
        {
            if ($item/list)
            then
                <ul>
                    {
                        for $child-item in $item/list/item
                        return
                            app:list-child($child-item)
                    }
                </ul>
            else
                ()
        }
    </li>
};

declare function app:figure($node as node()){
    let $id := data($node/@xml:id)
    return
    <div id="{$id}">
        {if ($node/head)
        then
            <h5>{concat("Figure ", data($node/@n), ": ", data($node/head))}</h5>
        else
            ()
        }
        
        <div class="w3-container w3-white w3-padding w3-margin-bottom">
            <img src="{data($node/graphic/@url)}" alt="" title="" style="width:100%"/>
            <button class="w3-button" style="float:right; color:#aaa; margin:16px 16px 0 0" onclick="openMod('modCite', '{$id}')">Cite</button>
        </div>
    </div>
};

declare function app:table($node as node())
{
    let $id := data($node/@xml:id)
    return
        if ($node/head)
        then
            <div id="{$id}">
                <h5>{concat("Table ", data($node/@n), ": ", data($node/head))}</h5>
                
                <div class="w3-container w3-padding-16 w3-white w3-margin-bottom">
                <table class="w3-table">
                    {app:rows($node)}
                </table>
                 <button class="w3-button" style="float:right; color:#aaa" onclick="openMod('modCite', '{$id}')">Cite</button>
                </div>
            </div>
        else
            <div id="{$id}" class="w3-container w3-padding-16 w3-white w3-margin-bottom">
                <table class="w3-table">
                    {app:rows($node)}
                    </table>
                    <button class="w3-button" style="float:right; color:#aaa" onclick="openMod('modCite', '{$id}')">Cite</button>
            </div>
};


declare function app:rows($node as node())
{
    for $row in $node/row
    return
        <tr>{
            for $cell in $row/cell
            return 
                <td>{app:text($cell)}</td>
        }
        </tr>
        
    
};

declare function app:subsections($node as node(), $model as map(*))
{
        let $page-id:= request:get-parameter('section', $app:default)
        let $section:= $app:doc/TEI/text/body//div[@xml:id = $page-id]

    return
        if (exists($section/div))
        then
            <div>
                <h4>Subsections</h4>
                <div class="w3-padding-16 w3-bar-block w3-white w3-margin-bottom">
                        {for $div in $section/div
                        return
                            if ($div/@xml:id)
                            then
                                <a class="w3-button w3-bar-item" href="grammar-entry.html?section={$div/@xml:id}"><i class="fa fa-caret-right fa-fw"/> {app:section-head($div/@xml:id)}</a>
                            else
                                <a class="w3-button w3-bar-item" href="grammar-entry.html?section={$div/@xml:id}"><i class="fa fa-caret-right fa-fw"/> {data($div/head)}</a>
                        }
                </div>
            </div>
        else
            ()
};

declare function app:keywords($node as node(), $model as map(*))
{
    let $page-id:= request:get-parameter('section', $app:default)
    let $section:= $app:doc/TEI/text/body//div[@xml:id = $page-id]
    return
    <div class="w3-bar-block w3-white">
        {if ($section/index/term)
        then
            for $term in $section/index/term
            let $target := app:getSecondPartOfTarget($term/@ref)
            order by $target
            return app:keyword($target)
        else
            <a class="w3-button w3-bar-item" style="padding-left:35px;">No keywords</a>
                            
        }
    </div>
};

declare function app:keyword($target as xs:string)
{
    let $indices:= $app:terms/TEI/text/body//item
    let $label:= $indices[@xml:id = $target]
    return
        if ($label)
            then
                let $ancestors := $label/ancestor::item
                return
                <a title="{data($label/gloss)}" class="w3-button w3-bar-item" style="padding-left:35px;" href="index-list.html?entry={$target}">{
                    for $ancestor in $ancestors
                    return
                        <span>{data($ancestor/term)}, </span> 
                }{data($label/term)}</a>
            else 
                <a class="w3-button w3-bar-item" style="padding-left:35px;" href="index-list.html">Empty Term!</a>     
};

declare function app:glossary($node as node(), $model as map(*))
{
    let $items := $app:abbreviations/TEI/text/body/list/item
    return
    <div class="w3-padding-16 w3-bar-block w3-white w3-margin-bottom">
    <table>
        {for $item in $items
        let $abbr := $item/abbr
        let $expan := $item/expan
        order by $abbr
        return
        <tr>
        <td class="w3-padding">{data($abbr)}</td><td>-</td>
         <td class="w3-padding">{data($expan)}</td>
        </tr>
        }
        </table>
    </div>
};

declare function app:index($node as node(), $model as map(*)) 
{
   let $entry-id:= request:get-parameter('entry', 'full')
   return
        if ($entry-id = 'full')
        then
           app:indexFull()
          
        else
           app:indexEntry($entry-id)
};

declare function app:indexEntry($index-id as xs:string)
{
    let $entry:= $app:terms/TEI/text/body//item[@xml:id=$index-id]
    let $term:= $entry/term
    let $gloss:= $entry/gloss
    let $ancestors := $entry/ancestor::item
    let $id := $entry/@xml:id
    let $textIndices := $app:doc/TEI/text/body//index/term[fn:ends-with(data(@ref),$id)] 
    let $exampleIndices := $app:examples/TEI/text/body//index/term[fn:ends-with(data(@ref),$id)] 
    return
        <div>
            <table class="w3-table">
                      
                      {if ($ancestors)
                        then
                            <tr>
                                <td>Term</td><td>{$term} ({
                                for $ancestor in $ancestors
                                return data($ancestor/term)
                                })</td>
                            </tr>
                        else
                        <tr>
                            <td>Term</td><td>{$term}</td>
                        </tr>
                      }
                        
                        <tr>
                        <td>Gloss</td><td>{$gloss}</td>
                        </tr>   
                        {
                        if ($textIndices)
                        then
                        <tr> <td>Appears in Section</td> <td> {
                         for $usedIndex in $textIndices 
                         let $div := $usedIndex/../..
                         return 
                            <a class="w3-button" href="grammar-entry.html?section={$div/@xml:id}">{data($div/@n)}
                            </a>
                            }</td></tr>
                         else()
                        }
                        {
                        if ($exampleIndices)
                        then
                        <tr> <td>Appears in Example</td> <td> {
                         for $usedIndex in $exampleIndices 
                         let $cit := $usedIndex/../..
                         return 
                            <a class="w3-button" href="examples.html#{data($cit/@xml:id)}">{data($cit/@xml:id)}
                            </a>
                            }</td></tr>
                         else()
                         }
            </table>
            <a class="w3-button" style="float:right; color:#aaa" href="index-list.html">All Indices</a>
        </div>
};

declare function app:indexFull()
{
    let $indices := $app:terms/TEI/text/body/list/item
    return 
    
    <ul class="toc">
        {for $term in $indices
        order by $term
        return
        app:index-child($term)
        }
        </ul>
};

declare function app:index-child($term as node()){
    let $item := $term/gloss
    let $list := $term/list
    let $id := $term/@xml:id
    let $textIndices := $app:doc/TEI/text/body//term[fn:ends-with(data(@ref),$id)] 
    let $exampleIndices := $app:examples/TEI/text/body//index/term[fn:ends-with(data(@ref),$id)] 
    return
    
     <li>
         <a href="index-list.html?entry={data($id)}" class="w3-button" title="{$item/text()}">{data($term/term)}</a>
            {  
                for $usedIndex in $textIndices 
                let $div := $usedIndex/ancestor::div[1]
                return 
                <a class="w3-button" href="grammar-entry.html?section={$div/@xml:id}">{
                if ($usedIndex/parent::index)
                then
                    <b>{data($div/@n)}</b>
                else
                    data($div/@n)
                }
                </a>
            }
            {  
                if ($exampleIndices)
                then
                    <span>Examples: {
                 for $usedIndex in $exampleIndices 
                 let $cit := $usedIndex/../..
                 return 
                    <a class="w3-button" href="examples.html#{data($cit/@xml:id)}">{data($cit/@xml:id)}
                    </a>}
                   </span> 
                 else()
           }
           {
                if ($list)
                then
                  <ul class="toc">
                      {for $label in $list/item
                         order by $label
                         return
                         app:index-child($label)
                         }
                  </ul>
                 else ()
           }
     </li>
     
};

(:[@target = $id]concat('terminology.xml#', $term/@xml:id):)
declare function app:breadcrumb($node as node(), $model as map(*))
{
    let $page-id:= request:get-parameter('section', $app:default)
    let $section := $app:doc/TEI/text/body//div[@xml:id = $page-id]
    return <ul class="w3-bar-item breadcrumb-jl">
                <li>
                        <a href="toc.html">Content</a>
                    </li>
                {for $element in $section/ancestor::div
                return
                    if ($element/@xml:id)
                    then
                            <li>
                                <a href="grammar-entry.html?section={$element/@xml:id}">
                                {app:section-head($element/@xml:id)}
                                </a>
                            </li>
                    else
                        <li>?</li>
                }
                <li>
                    {app:section-head($page-id)}
                    </li>
    </ul> 
};

declare function app:nextPage($node as node(), $model as map(*))
{
    <div class="w3-container w3-padding-16 w3-text-grey " style="cursor:pointer">
    {
    let $page-id:= request:get-parameter('section', $app:default)
    let $section := $app:doc/TEI/text/body//div[@xml:id = $page-id]
    
    let $nextPage:= app:tryDown($section)
    return
        if ($nextPage)
        then
            <a class= "jl-hover-opacity w3-left" href="grammar-entry.html?section={$nextPage/@xml:id}" title="next page">
                                <i class="fa fa-chevron-right w3-jumbo"/>
            </a>
        else
            ()
 
    }
    </div>
};

declare function app:tryDown($section){
    if ($section/div)
    then $section/div[1]
    else
        app:tryRight($section)
 
};

declare function app:tryRight($section){
    if ($section/following-sibling::*) 
    then ($section/following-sibling::*)[1] 
    else 
            app:tryUp($section)
};

declare function app:tryUp($section){
    if ($section/parent::div)
    then app:tryRight($section/parent::div)
    else ()
};

declare function app:previousPage($node as node(), $model as map(*))
{
     <div class="w3-container w3-padding-16 w3-text-grey " style="cursor:pointer">
    {
    let $page-id:= request:get-parameter('section', $app:default)
    let $section := $app:doc/TEI/text/body//div[@xml:id = $page-id]
    let $previousPage:= app:findPreviousPage($section)
    return
        
        if ($previousPage)
        then
            <a class= "jl-hover-opacity w3-right" href="grammar-entry.html?section={$previousPage/@xml:id}" title="previous page">
                                <i class="fa fa-chevron-left w3-jumbo"/>
            </a>
        else
            ()
 
    }
    </div>
};

declare function app:findPreviousPage($section){
    let $left := $section/preceding-sibling::div[1]
    return
        if ($left) 
        then 
            if ($left/descendant::div)
            then $left/descendant::div[last()]
            else $left
        else 
            if ($section/parent::div)
            then
                $section/parent::div
            else
                ()
};