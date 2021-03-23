xquery version "3.1";

module namespace igt="http://www.example.org/abesabesi/igt";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.example.org/abesabesi/config" at "config.xqm";
import module namespace gram="http://www.example.org/abesabesi/grammarEntry" at "grammar-entry.xql";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare variable $igt:examples := doc("/db/apps/Abesabesi/resources/data/examples.xml");
declare variable $igt:default-text := "ibe035-00m";
(:~
 : This module accesses the example and text databases (examples.xml and ibe035-00m) and displays them in examples.html and texts.html.
:)

(:-----------------------------------GET-FUNCTIONS-----------------------------------------------
    these are auxiliary functions that return examples or particular parts of it
    as XML nodes. They never return strings.
:)

declare function igt:get-example($id as xs:string)
{
    $igt:examples/TEI/text/body/cit[@xml:id=$id]
};

declare function igt:get-terms($id as xs:string)
{
    igt:get-example($id)/index/term
};

declare function igt:get-term($termID as xs:string)
{
    $igt:examples/TEI/text/body//index/term[fn:ends-with(data(@ref),$termID)] 
};


declare function igt:get-dictEntries ($target as xs:string)
{
    $igt:examples/TEI/text/body//cit//w[@lemmaRef = $target]
};

(:-----------------------------------UTTERANCE-FUNCTIONS-----------------------------------------------
    these are functions to retrieve examples and utterances from the example and text databases and
    to format them as interlinear glossed text (IGT). 
    
:)

declare function igt:example($id as xs:string, $n as xs:string, $db as xs:boolean)
{
    let $example := igt:get-example($id)
    return
        <div>
            <div style="overflow-x:auto;">
                <table class="w3-table" style="width:auto; " >
                    <tr>{igt:word-tier($example)}</tr>
                    <tr>{igt:gloss-tier($example)}</tr>
                    <tr>
                        {
                        if ($db)
                        then
                            igt:trans-tier($example)
                        else
                            igt:trans-tier($example,$id)
                        }        
                    </tr>
                </table>
            </div>
            {igt:exampleContext($id, $n, $db)}
        </div> 
        
};

declare function igt:word-tier($utterance as node()){
    <div>
                {for $word in $utterance//w
                return
                    if ($word/@lemmaRef)
                    then 
                    <td class="jl-txt">
                    <a href="dictionary.html?entry={data(gram:getSecondPartOfTarget($word/@lemmaRef))}">
                    {data($word/note[@ana = "#txt"])}
                    </a></td>
                    else
                    <td class="jl-txt">{data($word/note[@ana = "#txt"])}</td>
                }
    </div>
};

declare function igt:gloss-tier($utterance as node()){
    <div>
                {
                for $word in $utterance//w
                return
                <td>{gram:gloss($word/note[@ana = "#gls"])}</td>
                }
    </div>
};

declare function igt:trans-tier($utterance as node(), $id as xs:string){
    <td colspan="19">'{data($utterance/quote/s/note[@ana="#gls"])}' ({$id})</td>
};

declare function igt:trans-tier($utterance as node()){
    <td colspan="19">'{data($utterance/quote/s/note[@ana="#gls"])}'</td>
};

(:-----------------------------------CONTEXT-FUNCTIONS-----------------------------------------------
    these are functions to retrieve an utterance's context. This includes recordings, metadata, keywords, etc.
:)


(:~ 
 : this is the main context function creating a hidden box with different context buttons (audio, video, metadata, keywords, etc.)
:)
declare function igt:exampleContext($id as xs:string, $counter as xs:string, $db as xs:boolean)
{
    let $video-src := concat('resources/recordings/', fn:replace($id, '\.', '-'), '.mp4')
    let $audio-src := concat('resources/recordings/', fn:replace($id, '\.', '-'), '.wav')
    return
    <div>
    <hr style="margin:5px 0 5px 0;"/>
    <a class="w3-button w3-small" onclick="myAccFunc('more{$counter}')">more ...</a>
    <div id="more{$counter}" class="w3-hide">
        <div class="w3-half w3-small">
            <nav class="w3-bar-block w3-white">
                <a class="w3-button w3-bar-item" onclick="myAccFunc('audio{$counter}')">Audio</a>
                {igt:audio($audio-src, $counter)}
                <a class="w3-button w3-bar-item" onclick="myAccFunc('video{$counter}')">Video</a>
                {igt:video($video-src, $counter)}
                <a class="w3-button w3-bar-item">Text Context</a>
            </nav>
        </div>
        <div class="w3-half w3-small">
            <nav class="w3-bar-block w3-white">
                <a class="w3-button w3-bar-item" onclick="myAccFunc('metadata-ex{$counter}')">Metadata</a>
                <div class="w3-hide" id="metadata-ex{$counter}">
                </div>
                <a class="w3-button w3-bar-item" onclick="myAccFunc('keywords-ex{$counter}')">Keywords</a>
                {igt:keywords($id, $counter)}
                {
                    if ($db)
                    then
                        igt:occurrences($id, $counter)
                    else ()
                }
            </nav>
          </div>
       </div>
    </div>
};

declare function igt:audio($source as xs:string, $counter as xs:string)
{
    <audio class="w3-bar-item w3-hide" id="audio{$counter}" controls="controls">
        <source src="{$source}" type="audio/wav"/>
        Your browser does not support the audio tag.
    </audio>
};

declare function igt:video($source as xs:string, $counter as xs:string)
{
    <video class="w3-bar-item w3-hide" id="video{$counter}" controls="controls">
        <source src="{$source}" type="video/mp4" />
        Your browser does not support the video tag.
    </video>
};

declare function igt:keywords($id as xs:string, $counter as xs:string)
{
    <div class="w3-hide" id="keywords-ex{$counter}">
        {
            for $term in igt:get-terms($id)
            let $target := gram:getSecondPartOfTarget($term/@ref)
            order by $target
            return gram:keyword($target)
        }
    </div>
};

declare function igt:occurrences($id as xs:string, $counter as xs:string){
    <div>
        <a class="w3-button w3-bar-item" onclick="myAccFunc('usedInSection{$counter}')">Used in Section</a>
        <div class="w3-hide" id="usedInSection{$counter}">
            {let $textExamples := gram:get-exemplars($id)
             for $usedExample in $textExamples
             let $section := $usedExample/../..
             let $joinGrp-ID := $usedExample/../@xml:id
             return
                <a class="w3-bar-item w3-button" style="padding-left:35px;" href="grammar-entry.html?section={data($section/@xml:id)}#{data($joinGrp-ID)}">
                    {data($section/@n)}
                </a>
        }
        </div>
    </div>
};

(:-----------------------------------DATABASE-FUNCTIONS-----------------------------------------------
    these are template functions to display the content of the example and text databases
:)


declare function igt:exampleDatabase($node as node(), $model as map(*))
{
    for $example at $counter in $igt:examples//body/cit
    let $id := $example/@xml:id
    order by $id
    return
    <div>
        <h6 id="{data($id)}">{data($id)}</h6>
        <div class="w3-padding-16 w3-container w3-white w3-margin-bottom" >
        {igt:example($id, xs:string($counter), true())}
        </div>
    </div>
};

declare function igt:content-text($node as node(), $model as map(*))
{
    let $text-id:= request:get-parameter('text', $igt:default-text)
    (: let $text:= doc("/db/apps/Abesabesi/resources/data/texts/{$text-id}.xml"):)
    let $text:= doc("/db/apps/Abesabesi/resources/data/texts/ibe035-00m.xml")
    return
        for $example in $text/TEI//u
        return
            <div class="w3-padding-16 w3-container w3-white w3-margin-bottom" >
                <div style="overflow-x:auto;">
                    <table class="w3-table" style="width:auto; " >
                        <tr>{igt:word-tier($example)}</tr>
                        <tr>{igt:gloss-tier($example)}</tr>
                        <tr>
                            <td colspan="19">'{data($example/note[@ana="#gls"])}'</td>
                        </tr>
                    </table>
                </div>
            </div>       
};

declare function igt:texts($node as node(), $model as map(*))
{
    <div class="w3-bar-block w3-white">
            <a class="w3-button w3-bar-item" style="padding-left:35px;">Pear Story Awolami (ibe023-00)</a>
            <a class="w3-button w3-bar-item" style="padding-left:35px;">Planting Yam (ibe035-00)</a>   
            <a class="w3-button w3-bar-item" style="padding-left:35px;">Parents Elegbeleye (ibe065-00)</a>
            <a class="w3-button w3-bar-item" style="padding-left:35px;">Tortoise and the Pond (ibe301-00)</a>
    </div>
};

declare function igt:previousText($node as node(), $model as map(*))
{
    <div class="w3-container w3-padding-16 w3-text-grey " style="cursor:pointer">
        <a class= "jl-hover-opacity w3-right" title="previous text">
            <i class="fa fa-chevron-left w3-jumbo"/>
        </a>
    </div>
};

declare function igt:nextText($node as node(), $model as map(*))
{
    <div class="w3-container w3-padding-16 w3-text-grey " style="cursor:pointer">
        <a class= "jl-hover-opacity w3-left" title="following text">
            <i class="fa fa-chevron-right w3-jumbo"/>
        </a>
    </div>
};

declare function igt:title-text($node as node(), $model as map(*))
{
    <div title="Please cite this section as follows: Haruna, A. (2019). Planting Yam. In J. Lau, Documentation of Abesabesi. Retrieved [date], from https://elar.soas.ac.uk/Collection/MPI1207813">
        <h2 class="w3-center">
            ibe035-00: Planting Yam
        </h2>
    </div>
};

declare function igt:text-audio($node as node(), $model as map(*))
{
    <div>
        <a class="w3-button w3-bar-item" onclick="myAccFunc('audio')" style="padding-left:35px;">
                    Audio </a>
        {igt:audio("resources/recordings/ibe035-00m.wav", "")}
    </div>
   
};

declare function igt:text-video($node as node(), $model as map(*))
{
    <div>
        <a class="w3-button w3-bar-item" onclick="myAccFunc('video')" style="padding-left:35px;">
                        Video </a>
        {igt:video("resources/recordings/ibe035-00m.mp4", "")}
    </div>
};
