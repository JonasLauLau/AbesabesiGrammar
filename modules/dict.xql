xquery version "3.1";

module namespace dict="http://www.example.org/abesabesi/dict";


import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.example.org/abesabesi/config" at "config.xqm";
import module namespace app="http://www.example.org/abesabesi/templates" at "app.xql";


declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $dict:default-entry:= "odʒíbɛ̀rɛ̀_003a55e8-367f-4910-a2e7-e66b8adbdf76";
declare variable $dict:dictionary := doc("/db/apps/Abesabesi/resources/data/dictionary-ekirom.xml");


declare function dict:entry($node as node(), $model as map(*))
{
    let $searchphrase := request:get-parameter('searchphrase', '')
    let $entry-id := request:get-parameter('entry', $dict:default-entry)
    return
        if ($searchphrase)
        then
            dict:entry-with-id(dict:findEntryID($searchphrase))
        else
            let $entry := $dict:dictionary//entry[@xml:id = $entry-id][1]
            return
                dict:entry-with-id($entry)
};

declare function dict:findEntryID($searchphrase as xs:string)
{
    let $normalizedSP := lower-case(normalize-unicode(fn:normalize-space($searchphrase)))
   let $result-lemmaExact := $dict:dictionary//entry/form/orth[lower-case(normalize-unicode(fn:normalize-space(data(.)))) = $normalizedSP]
   let $result-lemmaContains := $dict:dictionary//entry/form/orth[fn:contains(lower-case(normalize-unicode(fn:normalize-space(data(.)))),$normalizedSP)]
   let $result-lemmaPronExact := $dict:dictionary//entry/form/pron[lower-case(normalize-unicode(fn:normalize-space(data(.)))) = $normalizedSP]
   let $result-lemmaPronContains := $dict:dictionary//entry/form/pron[fn:contains(lower-case(normalize-unicode(fn:normalize-space(data(.)))),$normalizedSP)]
   let $result-glossExact := $dict:dictionary//entry/sense/gloss[lower-case(normalize-unicode(fn:normalize-space(data(.)))) = $normalizedSP]
   let $result-glossContains := $dict:dictionary//entry/sense/gloss[fn:contains(lower-case(normalize-unicode(fn:normalize-space(data(.)))),$normalizedSP)]
   let $result-defExact := $dict:dictionary//entry/sense/cit/quote[lower-case(normalize-unicode(fn:normalize-space(data(.)))) = $normalizedSP]
   let $result-defContains := $dict:dictionary//entry/sense/cit/quote[fn:contains(lower-case(normalize-unicode(fn:normalize-space(data(.)))),$normalizedSP)]
      let $defaultEntry := $dict:dictionary//entry[@xml:id = $dict:default-entry][1]
   return
   
   if ($result-lemmaExact)
   then
        $result-lemmaExact/../..[1][1]
   else if ($result-lemmaPronExact)
   then
        $result-lemmaPronExact/../../..[1][1]
   else if ($result-defExact)
   then
        $result-defExact/../../..[1][1]
   else if ($result-glossExact)
   then
        $result-glossExact/../..[1][1]
   else if ($result-lemmaContains)
   then
        $result-lemmaContains/../..[1][1]
   else   if ($result-defContains)
   then
        $result-defContains/../../..[1][1]
   else   if ($result-glossContains)
   then
        $result-glossContains/../..[1][1]
   else if ($result-lemmaPronContains)
   then
        $result-lemmaPronContains/../..[1][1]
   else
        <empty/> 
           
   
   (:   
  
  
   
   return
        if (empty($OLEntry))
        then
            $OLEntry[1]/../..
        else
            let $TLEntry := $dict:dictionary//entry/sense/gloss[fn:contains(data(.),$searchphrase)]
            return
                if (empty($TLEntry))
                then
                    $TLEntry[1]/../..
                else
                    $defaultEntry
                    :)
};

declare function dict:entry-with-id($entry as node())
{
    if ($entry/name() = 'empty')
    then
        <div class="w3-container w3-white w3-padding-16 w3-margin-bottom">
            No results
        </div>
    else
        <div>
        {
            for $sense in $entry/sense
            return
            <div class="w3-container w3-white w3-padding-16 w3-margin-bottom">
                <div class="jl-bar">
                    <h1 class="jl-dict-entry" style="padding-left:16px">{data($entry/form/orth)}</h1>
                    <i class="jl-dict-entry">{data($sense/cit/gramGrp/gram[@type='pos'])}</i>
                    
                </div>
                <hr/>
                <table class="w3-table">
                    {
                        if ($sense/cit/quote/text())
                        then
                            <tr><td><b>Definition</b></td><td>{data($sense/cit/quote/text())}</td></tr>
                        else 
                            ()
                            }
                    {
                        if ($sense/gloss)
                        then
                            <tr><td><b>Gloss</b></td><td>{data($sense/gloss)}</td></tr>
                        else
                            ()
                    }
                    <tr><td><b>Pronunciation</b></td><td class="jl-txt">{data($entry/form/pron)}</td> </tr>
                     {
                        let $vh := $sense/cit/gramGrp/gram[@type='vh']
                        return
                            if ($vh)
                            then
                                let $vh-cut := fn:substring-before(fn:substring-after($vh,"["),"]")
                                let $parts := fn:tokenize($vh-cut, " ")
                                for $vh-kind in $parts
                                return
                                    if (fn:contains($vh-kind, "+u"))
                                    then
                                        <tr><td><b>Prefix vowel harmony</b></td>
                                        <td class="jl-txt">{fn:substring-after($vh-kind, ":")}</td></tr>
                                    else
                                        <tr><td><b>Suffix vowel harmony</b></td>
                                        <td class="jl-txt">{fn:substring-after($vh-kind, ":")}</td></tr>
                            else
                                ()
                    }
                    {
                        for $etymology in $entry/etym
                            return
                                if ($etymology/foreign)
                                then
                                    <tr><td><b>Possibly derived from </b></td><td><span class="jl-txt">{data($etymology/foreign/text())}</span>
                                    ({data($etymology/lang/text())})</td></tr>
                                else
                            ()
                    }
                    {
                        for $xr in $entry/xr
                        let $ref := fn:normalize-unicode(data($xr/ref/@target))
                        let $ref-entry := $dict:dictionary//entry[@xml:id = $ref]
                        let $ref-form := $ref-entry/form/pron
                            return
                               <tr>
                                <td><b>{data($xr/lbl)}</b></td>
                                <td class="jl-txt"><a href="dictionary.html?entry={$ref}">{data($ref-form)}</a></td></tr>
                    }
                </table>
            </div> 
         }
         {
            let $instances := dict:findInstances(data($entry/@xml:id))
            return $instances
         }
    </div>
};

declare function dict:findInstances($id as xs:string)
{
    let $fullTarget := fn:concat("dictionary.xml#", $id)
    let $refs := $app:doc//div//ref[data(@target) = $fullTarget]
    return
        if ($refs)
        then
            <div class="w3-container w3-white w3-padding-16 w3-margin-bottom">
            <table class="w3-table">
                <tr>
                <td><b>Sections that contain this lexeme </b></td><td>
                {for $ref in $refs
                 let $div := $ref/ancestor::div[1]
                    return
                        <a style="padding:0px 16px;" href="grammar-entry.html?section={data($div/@xml:id)}">{data($div/@n)}</a>
                }
                </td>
                </tr>
                </table>
            </div>
        else ()
 
    
    
    
};
    

declare function dict:list($node as node(), $model as map(*))
{
    <div class="w3-white w3-container w3-margin-bottom jl-scroll-container-outer">
        <div class="jl-header-background"/>
        <div class="jl-scroll-container">
            <table id="dict-table" class="sortable jl-pointer jl-scroll"> 
             <thead>
                <tr class="w3-white">
                 <th id="table-anchor" class="w3-hover-text-teal jl-first" data-autoclick="true"><div class="jl-th-inner">Lemma</div></th>
                 <th class="w3-hover-text-teal sorttable_alpha"><div class="jl-th-inner">Gloss</div></th>
                 <th class="w3-hover-text-teal"><div class="jl-th-inner">POS</div></th>
                 </tr>
                 </thead>
                 <tbody>
                 {
                     for $entry in $dict:dictionary//entry
                     return
                         for $sense in $entry/sense
                         return
                             <tr onclick="window.location='dictionary.html?entry={$entry/@xml:id}';">
                                 
                                 <td class="jl-txt">{data($entry/form/orth)}</td>
                                 <td>{data($sense/gloss)}</td>
                                 <td>{data($sense/cit/gramGrp/gram[@type='pos'])}</td>
                             </tr>
                         
                 }
                 </tbody>
               
                
            </table>
          </div>
     </div>
};