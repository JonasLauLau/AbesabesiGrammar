<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--<xsl:template name="change-number" match="@n">
        <xsl:param name = "number" />
        <xsl:attribute name="n">
            <xsl:value-of select="$number"/>
        </xsl:attribute>
    </xsl:template> -->
    
    <xsl:template match="div">
        
        <xsl:variable name="n">
           <xsl:number count="div" level="multiple"/>
        </xsl:variable>
<!--     <xsl:value-of select="$n"/>-->
    <!-- <xsl:call-template name="change-number">
         <xsl:with-param name="number" select = "$n" />
     </xsl:call-template>-->
        <xsl:copy>
            <xsl:attribute name="n">
                <xsl:number count="div" level="multiple"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
            
        
            
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>