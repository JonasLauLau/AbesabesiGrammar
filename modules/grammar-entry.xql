xquery version "3.1";

module namespace gram="http://www.example.org/abesabesi/grammarEntry";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.example.org/abesabesi/config" at "config.xqm";
import module namespace term="http://www.example.org/abesabesi/terms" at "terms.xql";
import module namespace igt="http://www.example.org/abesabesi/igt" at "igt.xql";


declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $gram:doc := doc("/db/apps/Abesabesi/resources/data/ekirom.xml");
declare variable $gram:default-entry := "ch1";

(:~
 : This module helps to render grammatical entries in grammar-entry.html. It is the only one to access the main grammar document (e.g., exirom.xml)
:)


(:-----------------------------------GET-FUNCTIONS-----------------------------------------------
    these are auxiliary functions that return the grammar entry or particular parts of it
    as XML nodes. They never return strings.
:)

declare function gram:get-entry($id as xs:string)
{
    $gram:doc/TEI/text/body//div[@xml:id = $id]
};

declare function gram:get-head($id as xs:string)
{
    gram:get-entry($id)/head
};

declare function gram:get-number($id as xs:string)
{
    gram:get-entry($id)/@n
};


declare function gram:get-index($id as xs:string)
{
    gram:get-entry($id)/index
};

declare function gram:get-term($termID as xs:string)
{
    $gram:doc/TEI/text/body//term[fn:ends-with(string(@ref),$termID)] 
};

declare function gram:get-tag($id as xs:string, $tag as xs:string)
{
    gram:get-entry($id)/note[@ana = $tag]
};

declare function gram:get-element($id as xs:string)
{
    $gram:doc//fn:id($id)
};

declare function gram:get-dictEntries ($target as xs:string)
{
    $gram:doc//div//ref[data(@target) = $target]
};

declare function gram:get-exemplars($exampleID as xs:string)
{
    $gram:doc/TEI/text/body//joinGrp/ptr[fn:ends-with(data(@target),$exampleID)] 
};

   
(:-----------------------------------PRINT-FUNCTIONS-----------------------------------------------
    these are auxiliary functions are equivalents of the GET-FUNCTIONS but always return 
    the string value of particular parts of a grammatical entry. 
:)

declare function gram:print-head($id as xs:string) as xs:string 
{
    gram:text(gram:get-head($id))
};

declare function gram:print-number($id as xs:string) as xs:string
{
    data(gram:get-number($id))
};

declare function gram:requestID () as xs:string 
{
    request:get-parameter('section', $gram:default-entry)
};

declare function gram:getSecondPartOfTarget ($target as xs:string)
{
    (fn:tokenize($target, "#"))[2]
};

(:-----------------------------------METADATA-FUNCTIONS-----------------------------------------------
    these template functions are directly called within grammar-entry.html and render the 
    metadata of a grammar entry: the heading, keywords, and tags.
:)
(:~
 : Displays the title of an entry with a tooltip containing information about correct citing
:)
declare function gram:title($node as node(), $model as map(*))
{
    let $id:= gram:requestID()
    let $no := gram:print-number($id)
    let $title := gram:print-head($id)
    return 
        <div title="Please cite this section as follows: Lau, J. (2021) {$title}. Abesabesi Grammar. http://abesabesi.cceh.uni-koeln.de/">
            <h2 class="w3-center">
            {concat($no, " ")} {$title}
            </h2>
        </div>
};

(:~
 : Displays a list of keywords attributed to a grammar entry
:)
declare function gram:keywords($node as node(), $model as map(*))
{
    let $id := gram:requestID()
    let $index := gram:get-index($id)
        return
        <div class="w3-bar-block w3-white">
            {if ($index/term)
            then
                for $term in $index/term
                let $target := gram:getSecondPartOfTarget($term/@ref)
                order by $target
                return gram:keyword($target)
            else
                <a class="w3-button w3-bar-item" style="padding-left:35px;">No keywords</a>
                                
            }
        </div>
};

(:~
 : Displays a single keyword
:)
declare function gram:keyword($id as xs:string)
{
    let $term:= term:get-term($id)
    return
        if ($term)
            then
                <a title="{term:print-gloss($term)}" class="w3-button w3-bar-item" style="padding-left:35px;" href="index-list.html?entry={$id}">
                {
                    for $ancestor in term:get-ancestors($term)
                    return
                        <span>{term:print-label($ancestor)}, </span> 
                }{term:print-label($term)}</a>
            else 
                <a class="w3-button w3-bar-item" style="padding-left:35px;" href="index-list.html">Empty Term!</a>     
};

(:~
 : Displays one tag of a grammar entry. 
 : @param $tag contains the tag label that is equivalent with the @ana attribute of notes in the TEI document
 : @param $color contains a w3.css class indicating a color.
:)
declare function gram:tag($node as node(), $model as map(*), $tag as xs:string, $color as xs:string)
{

    let $id:= gram:requestID()
    let $note := gram:get-tag($id, $tag)
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

(:-----------------------------------NAVIGATION-FUNCTIONS-----------------------------------------------
    these template functions are directly called within grammar-entry.html and render 
    internal navigation tools: buttons for subsections, breadcrumb navigation, and links to adjacent entries.
:)


(:~
 : Displays a list of an entry's subsections
:)
declare function gram:subsections($node as node(), $model as map(*))
{
        let $id:= gram:requestID()
        let $entry:= gram:get-entry($id)

    return
        if ($entry/div)
        then
            <div>
                <h4>Subsections</h4>
                <div class="w3-padding-16 w3-bar-block w3-white w3-margin-bottom">
                        {
                        for $div in $entry/div
                            return
                                if ($div/@xml:id)
                                then
                                    <a class="w3-button w3-bar-item" href="grammar-entry.html?section={$div/@xml:id}">
                                        <i class="fa fa-caret-right fa-fw"/> {gram:print-head($div/@xml:id)}
                                    </a>
                                else
                                    <a class="w3-button w3-bar-item"><i class="fa fa-caret-right fa-fw"/> {data($div/head)}</a>
                        }
                </div>
            </div>
        else
            ()
};

(:~
 : Produces the breadcrumb navigation for a particular grammar entry
:)
declare function gram:breadcrumb($node as node(), $model as map(*))
{
    let $id:= gram:requestID()
    let $entry:= gram:get-entry($id)
    return <ul class="w3-bar-item breadcrumb-jl">
        <li>
            <a href="toc.html">Content</a>
        </li>
        {
        for $div in $entry/ancestor::div
        let $divID := $div/@xml:id
        return
            if ($divID)
            then
                <li>
                    <a href="grammar-entry.html?section={$divID}">
                    {gram:print-head($divID)}
                    </a>
                </li>
            else
                <li>{data($div/head)}</li>
        }
        <li>
            {gram:print-head($id)}
        </li>
    </ul> 
};

(:~
 : Produces a clickable arrow to access the next grammar entry.
:)
declare function gram:nextEntry($node as node(), $model as map(*))
{
    <div class="w3-container w3-padding-16 w3-text-grey " style="cursor:pointer">
    {
        let $id:= gram:requestID()
        let $entry:= gram:get-entry($id)
        let $nextEntry:= gram:tryFirstDown($entry)
        return
            if ($nextEntry)
            then
                <a class= "jl-hover-opacity w3-left" href="grammar-entry.html?section={$nextEntry/@xml:id}" title="next entry">
                    <i class="fa fa-chevron-right w3-jumbo"/>
                </a>
            else
                ()
    }
    </div>
};

declare function gram:tryFirstDown($entry as node()){
    if ($entry/div)
    then $entry/div[1]
    else gram:tryRight($entry)
 
};

declare function gram:tryRight($entry as node()){
    if ($entry/following-sibling::div) 
    then ($entry/following-sibling::div)[1] 
    else gram:tryUp($entry)
};

declare function gram:tryUp($entry as node()){
    if ($entry/parent::div)
    then gram:tryRight($entry/parent::div)
    else ()
};


(:~
 : Produces a clickable arrow to access the previous grammar entry.
:)
declare function gram:previousEntry($node as node(), $model as map(*))
{
     <div class="w3-container w3-padding-16 w3-text-grey " style="cursor:pointer">
    {
    let $id:= gram:requestID()
    let $entry:= gram:get-entry($id)
    let $previousEntry:= gram:tryLeft($entry)
    return
        if ($previousEntry)
        then
            <a class= "jl-hover-opacity w3-right" href="grammar-entry.html?section={$previousEntry/@xml:id}" title="previous entry">
                <i class="fa fa-chevron-left w3-jumbo"/>
            </a>
        else
            ()
 
    }
    </div>
};

declare function gram:tryLeft($entry as node())
{
    if ($entry/preceding-sibling::div[1]) 
    then 
        gram:tryLastDown($entry/preceding-sibling::div[1])
    else
        gram:tryFirstUp($entry)
};  

declare function gram:tryLastDown($entry as node())
{
    if ($entry/descendant::div) 
    then 
        $entry/descendant::div[last()]
    else
        $entry
};  

declare function gram:tryFirstUp($entry as node())
{
    if ($entry/parent::div)
    then
        $entry/parent::div
    else
        ()
};  
            
(:-----------------------------------CONTENT-FUNCTIONS-----------------------------------------------
    These functions render the content of a grammar entry: prose, examples, tables, etc.
    The function gram:content is directly called within grammar-entry.html and calls
    various other functions of this module to render particular elements ("grammar bricks") of a grammar entry.
    Each grammar brick is contained by a white container.
:)


declare function gram:content($node as node(), $model as map(*))
{
    let $id:= gram:requestID()
    let $entry:= gram:get-entry($id)
    return
        <div>
            {
                if ($entry/p or $entry/joinGrp or $entry/table or $entry/list or $entry/figure or $entry/entry)
                then
                    for $element in $entry/* 
                    return
                            if (name($element) = 'p')
                            then
                                gram:paragraph($element) 
                            else if (name($element) = 'joinGrp')
                            then 
                                gram:examples($element)
                            else if (name($element) = 'table')
                            then
                                gram:table($element)
                            else if (name($element) ='list')
                            then
                                gram:list($element)
                            else if (name($element) = 'figure')
                            then
                                gram:figure($element)
                            (:else if (name($element) ='entry')
                            then
                                app:entry($element):)
                            else()
                else
                    <div class="w3-padding-16 w3-container w3-white w3-margin-bottom">
                    No content available at the moment.
                    </div>
            }
        </div>
};

(:~
 : Creates the content of the modal box that indicates how to cite the resource.
:)
declare function gram:citeMod($node as node(), $model as map(*), $id as xs:string){
    let $id:= gram:requestID()
    let $entry:= gram:get-entry($id)
    return
        <p class="" id="modCite-inner">Lau, J. (2021) {gram:print-head($id)}. <i>Abesabesi Grammar</i>. http://abesabesi.cceh.uni-koeln.de/grammar-entry.html?section={$id}</p>

};

declare function gram:citeButton($id as xs:string){
     <button class="w3-button" style="float:right; color:#aaa" onclick="openMod('modCite', '{$id}')">Cite</button>
};

declare function gram:paragraph($node as node())
{
    let $id := string($node/@xml:id)
    return
        <div class="w3-padding-16 w3-container w3-white w3-margin-bottom">
            {gram:text($node)}
            {gram:citeButton($id)}
        </div> 
};

declare function gram:examples($exGroup as node())
{
     <div class="w3-padding-16 w3-container w3-white w3-margin-bottom" >
     {
        for $ptr in $exGroup/ptr
        let $id := gram:getSecondPartOfTarget(data($ptr/@target))
        let $n := fn:concat(data($exGroup/@n), data($ptr/@n))
        return
            <div class="w3-row" id="{data($exGroup/@xml:id)}"> 
                <div class="w3-col w3-padding" style="width:auto">
                    <table>
                        <tr>
                            {
                                if ($ptr is $exGroup/ptr[1])
                                then
                                    <td style="width:25px">{data($exGroup/@n)}</td>
                                else
                                    <td style="width:25px"></td>
                             }
                            <td>{data($ptr/@n)}</td>
                        </tr>
                    </table>
                </div>
                <div class="w3-rest" style="">
                    {igt:example($id, $n, false())}
                </div>
            </div>
       }                 
       {gram:citeButton(data($exGroup/@xml:id))}
    </div>
};

declare function gram:list($list as node())
{
    let $id := string($list/@xml:id)
    return
     <div id="{$id}">
        {
            if ($list/head)
            then
                <h5>{concat("List ", data($list/@n), ": ", gram:text($list/head))}</h5>
            else()
        }
        <div class="w3-padding-16 w3-container w3-white w3-margin-bottom" >
            <ul>
                {       
                for $item in $list/item
                return
                   gram:list-child($item)
                }   
            </ul>
            {gram:citeButton($id)}
        </div>
    </div>
};

declare function gram:list-child($item as node())
{
    <li>
        {gram:text($item)}
        {
            if ($item/list)
            then
                <ul>
                    {
                        for $child-item in $item/list/item
                        return
                            gram:list-child($child-item)
                    }
                </ul>
            else()
        }
    </li>
};

declare function gram:figure($node as node()){
    let $id := data($node/@xml:id)
    return
    <div id="{$id}">
        {if ($node/head)
        then
            <h5>{concat("Figure ", data($node/@n), ": ")}{gram:text($node/head)}</h5>
        else
            ()
        }
        <div class="w3-container w3-white w3-padding w3-margin-bottom">
            <img src="{data($node/graphic/@url)}" alt="" title="" style="width:100%"/>
            {gram:citeButton($id)}
        </div>
    </div>
};

declare function gram:table($node as node())
{
    let $id := string($node/@xml:id)
    return
        <div id="{$id}">
        {
            if ($node/head)
            then
                <h5>{concat("Table ", data($node/@n), ": ")}{gram:text($node/head)}</h5>
             else ()
        }
            <div class="w3-container w3-padding-16 w3-white w3-margin-bottom">
                <table class="w3-table">
                    {gram:rows($node)}
                </table>
                {gram:citeButton($id)}
            </div>
        </div>
};

declare function gram:rows($node as node())
{
    for $row in $node/row
    return
        <tr>
        {
            for $cell in $row/cell
            return 
                <td>{gram:text($cell)}</td>
        }
        </tr>
};

(:-----------------------------------NANOSTRUCTURE-FUNCTIONS-----------------------------------------------
    These functions render the content of the grammar-parts. This includes texts, terms, abbreviations, references, etc.
:)


(:~
 : Goes trough all elements within one grammar-brick (paragraph, table, list, etc.) and calls different functions
 : depending on the nano-element (term, abbreviation, gloss, etc.)
 :
:)
declare function gram:text($node as node()){
    for $element in $node/node()
            return
                if (name($element) ='term')
                then
                    gram:term($element)
                else if (name($element) = 'abbr')
                then
                    gram:abbr($element)
                else if (name($element) = 'foreign')
                then
                    gram:foreign($element)
                else if (name($element) ='gloss')
                then
                    <span>'{gram:gloss($element)}'</span>
                else if (name($element) = 'name')
                then
                    gram:name($element)
                else if (name($element) = 'note')
                then
                    gram:note($element)
                else if (name($element) = 'unclear')
                then
                    gram:unclear($element)
                else if (name($element) ='list')
                then ()
                else if (name($element) = 'ref')
                then
                    gram:ref($element)
                else
                    string($element)
};

declare function gram:term($term as node())
{
    if ($term/@ref)
        then
         <a href="{gram:resolve-target-uri($term/@ref)}">{string($term)}</a>
        else
            <a>{data($term)}</a>
};

declare function gram:abbr($node as node()){
    let $target := gram:getSecondPartOfTarget($node/@corresp)
    let $abbr := term:get-abbr($target)
    let $expan := $abbr/expan
    return
        <abbr style="text-decoration:none" title="{string($expan)}" href="glossary.html">{string($abbr/abbr)}</abbr>
    
};

declare function gram:foreign($node as node())
{
    <span class="jl-txt">{data($node)}</span>
};

declare function gram:gloss($gloss as node())
{
    for $element in $gloss/node()
    return
        if (name($element) ='abbr')
        then
            let $target := gram:getSecondPartOfTarget($element/@corresp)
            let $item:= term:get-abbr($target)
            let $expan := $item/expan
            return
                <a class="jl-glossEx" title="{data($expan)}" href="glossary.html">{data($item/abbr)}</a>
      else
           string($element)
};

declare function gram:name($node as node())
{
    <span>"{data($node)}"</span>
};

declare function gram:note($node as node())
{
    <sup class="w3-text-teal" style="cursor:pointer" title="{data($node)}">{data($node/@n)}</sup>
};

declare function gram:unclear($node as node())
{
    <span class="jl-unclear">{string($node)}</span>
};

declare function gram:ref($ref as node()){
    if (data($ref))
    then
        <a href="{gram:resolve-target-uri($ref/@target)}">{gram:text($ref)}</a>
    else
        gram:emptyRef($ref)
};
        
declare function gram:emptyRef($ref as node())
{    
    let $id := fn:substring(string($ref/@target),2)
    let $element := gram:get-element($id)
    return
        <a class="intext-button" href="{gram:resolve-target-uri($ref/@target)}">
            {data($element/@n)}
        </a>
   
};

(:~
 : Takes the links used in the grammar document and creates a URL to be used as a href value in HTML
:)
declare function gram:resolve-target-uri($target as xs:string)
{
     if (fn:starts-with($target, "#"))
        then
            if (fn:starts-with($target, "#ch"))
            then
                concat("grammar-entry.html?section=", substring($target, 2))
            else 
                $target
        else 
            let $parts := fn:tokenize($target, "#")
            return
                if ($parts[1] = "dictionary.xml")
                then
                    concat("dictionary.html?entry=", $parts[2])
                else if ($parts[1] = "terminology.xml")
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

(:-----------------------------------NANOSTRUCTURE-FUNCTIONS-----------------------------------------------
    These functions render the table of contents.
:)

declare function gram:toc($node as node(), $model as map(*)) 
{
    let $body:= $gram:doc/TEI/text/body
    return
         <ol class="toc">
             {for $div in $body/div
                return
                    gram:toc-child($div)}
        </ol>
};

declare function gram:toc-child($node as node())
{
    <li>
        <span class="w3-padding">{data($node/@n)}</span>
        <a href="grammar-entry.html?section={$node/@xml:id}" class="w3-button">
            {data($node/head)}
        </a>
        {
            if ($node/div)
            then
                <div class="w3-button w3-text-teal" style="cursor:pointer" onClick="showLevelBeneath(this)" title="Show subsections">
                    <i class="fa fa-caret-right"/>
                </div>
            else ()
        }{
            if ($node/div)
            then
                    <ol class="toc" style="display:none">
                        {
                        for $div in $node/div
                        return
                            gram:toc-child($div)
                        }
                    </ol>
             else                                   (: this part is necessary for the form-function approach :)
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



