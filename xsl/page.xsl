<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xhtml"/>
    
    <xsl:include href="common.xsl"/>
    
    <!-- the containing file to process -->
    <xsl:param name="sys-id" as="xs:string" required="yes"/>
    <!-- the ID of the facsimile to process -->
    <xsl:param name="id" as="xs:string" required="yes"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title><xsl:value-of select="$sys-id"/>, page <xsl:value-of select="$id"/></title>
            </head>
            <body>       
                <h1><xsl:value-of select="$sys-id"/></h1>
                <h2><xsl:value-of select="$id"/></h2>
                <h2><a href="toc?url={$sys-id}">Table of contents</a></h2>
                
                <xsl:variable name="page" select="key('element-by-id', $id)"/>
                
                <xsl:variable name="prev" select="$page/preceding-sibling::tei:facsimile[1]"/>
                <xsl:if test="$prev"><a href="page?url={$sys-id}&amp;id={$prev/@xml:id}">Previous page</a></xsl:if>
                
                <xsl:variable name="next" select="$page/following-sibling::tei:facsimile[1]"/>
                <xsl:if test="$next"><a href="page?url={$sys-id}&amp;id={$next/@xml:id}">Next page</a></xsl:if>
                
                <xsl:apply-templates select="$page"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="tei:facsimile">
        <div>
            <a href='https://path/to/images/{tei:graphic/@url}'>
                <xsl:value-of select="tei:graphic/@url"/>
            </a>
        </div>
    </xsl:template>
    
</xsl:stylesheet>