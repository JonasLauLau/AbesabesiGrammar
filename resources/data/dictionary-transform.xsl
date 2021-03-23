<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.tei-c.org/ns/1.0 document.xsd">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title/>
                    </titleStmt>
                    <publicationStmt>
                        <p/>
                    </publicationStmt>
                    <sourceDesc>
                        <p/>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    <xsl:for-each select="lift/entry">
                        <entry xml:lang="ibe">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <form type="lemma">
                                <pron notation="ipa">
                                    <xsl:value-of select="lexical-unit/form[@lang ='ibe']/text"/>
                                </pron>
                                <orth>
                                    <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace(lexical-unit/form[@lang ='ibe']/text,'ɔ','ọ'), 'ɛ', 'ẹ'), 'ʷ','w'), 'ʃ','ṣ'),'j','y'),'dʒ','j'), 'ŋ', 'ng'), 'ɲ', 'ny')"/>
                                </orth>
                            </form>
                            <xsl:for-each select="variant">
                                <form type="variant">
                                    <pron notation="ipa">
                                        <xsl:value-of select="form[@lang ='ibe']/text"/>
                                    </pron>
                                    <orth>
                                        <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace(form[@lang ='ibe']/text,'ɔ','ọ'), 'ɛ', 'ẹ'), 'ʷ','w'), 'ʃ','ṣ'),'j','y'),'dʒ','j'), 'ŋ', 'ng'), 'ɲ', 'ny')"/>
                                    </orth>
                                </form>
                            </xsl:for-each>
                            <xsl:for-each select="sense">
                                <sense>
                                    <gloss>
                                        <xsl:value-of select="gloss/text"/>
                                    </gloss>
                                    <cit>
                                        <quote xml:lang="en">
                                            <xsl:value-of select="definition/form"/>                                        
                                        </quote>
                                        <gramGrp>
                                            <gram type="pos">
                                                <xsl:value-of select="grammatical-info/@value"/>
                                            </gram>
                                            <gram type="vh">
                                                <xsl:value-of select="grammatical-info/trait/@value"/>
                                            </gram>
                                        </gramGrp>
                                    </cit>
                                </sense>
                            </xsl:for-each>
                            <xsl:for-each select="relation[@type='supplied singular']">
                                <xr>
                                    <lbl>Singular</lbl>
                                    <ref>
                                        <xsl:attribute name="target">
                                            <xsl:value-of select="@ref"/>
                                        </xsl:attribute>
                                    </ref>
                                </xr>
                            </xsl:for-each>
                            <xsl:for-each select="relation[@type='supplied plural']">
                                <xr>
                                    <lbl>Plural</lbl>
                                    <ref>
                                        <xsl:attribute name="target">
                                            <xsl:value-of select="@ref"/>
                                        </xsl:attribute>
                                    </ref>
                                </xr>
                            </xsl:for-each>
                            <xsl:for-each select="relation[@type='Ekirom Equivalent']">
                                <xr>
                                    <lbl>Abesabesi equivalent</lbl>
                                    <ref>
                                        <xsl:attribute name="target">
                                            <xsl:value-of select="@ref"/>
                                        </xsl:attribute>
                                    </ref>
                                </xr>
                            </xsl:for-each>
                            <xsl:for-each select="relation[@type='Yoruba Equivalent']">
                                <xr>
                                    <lbl>Yoruba equivalent</lbl>
                                    <ref>
                                        <xsl:attribute name="target">
                                            <xsl:value-of select="@ref"/>
                                        </xsl:attribute>
                                    </ref>
                                </xr>
                            </xsl:for-each>
                            <xsl:for-each select="etymology">
                                <etym>
                                    <lang>
                                        <xsl:value-of select="trait[@name='languages']/@value"/>
                                    </lang>
                                    <foreign>
                                        <xsl:value-of select="form/text"/>
                                    </foreign>
                                </etym>
                            </xsl:for-each>
                            
                        </entry>
                    </xsl:for-each>
                </body>
            </text>
        </TEI>
    </xsl:template>
</xsl:stylesheet>