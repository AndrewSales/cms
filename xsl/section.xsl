<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xhtml"/>

    <!-- the containing file to process -->
    <xsl:param name="sys-id" as="xs:string" required="yes"/>
    <!-- the ID of the title to process -->
    <xsl:param name="id" as="xs:string" required="yes"/>
    
    <xsl:include href="common.xsl"/>

    <xsl:template match="/tei:TEI">
        <html>
            <head>
                <title><xsl:value-of select="@xml:id"/>&#xA0;- section view</title>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="@xml:id"/>
                </h1>
                <xsl:apply-templates select="key('element-by-id', $id)"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="tei:div/tei:head/tei:title">
        <h2><xsl:apply-templates/></h2>
    </xsl:template>
    
</xsl:stylesheet>
