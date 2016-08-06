<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xhtml"/>

    <xsl:param name="sys-id" as="xs:string" required="yes"/>

    <xsl:template match="/tei:TEI">
        <html>
            <head>
                <title><xsl:value-of select="@xml:id"/>&#xA0;- Table of contents</title>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="@xml:id"/>
                </h1>
                <div>
                    <a href="collection">My works</a>
                </div>
                
                <!--<xsl:if test="$prev"><a href="toc?url={$prev}">Previous</a></xsl:if>
                <xsl:if test="$next"><a href="toc?url={$next}">Next</a></xsl:if>-->
                
                <!-- TODO: add username -->
                <!-- multiple titles: -->
                <xsl:apply-templates select="tei:text/tei:group/tei:text"/>
            </body>
        </html>
    </xsl:template>

    <!-- multiple titles are captured this way -->
    <xsl:template match="tei:text/tei:group/tei:text">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:front[not(tei:desc/tei:title)]">
        <h3>Front matter</h3>
    </xsl:template>

    <xsl:template match="tei:back[not(tei:desc/tei:title)]">
        <h3>Back matter</h3>
    </xsl:template>

    <xsl:template match="tei:body/tei:desc/tei:title">
        <h2>
            <a href="work?url={$sys-id}&amp;id={../../../@xml:id}">
                <xsl:number select="../../.."/>&#xA0;<xsl:apply-templates/>
            </a>
        </h2>
    </xsl:template>

    <xsl:template match="tei:body/tei:div[@type = 'chapter']">
        <h3>
            <a href="section?url={$sys-id}&amp;id={@xml:id}">Chapter&#xA0;<xsl:number/></a>
        </h3>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:body/tei:div[@type = 'part']">
        <h3>
            <a href="section?url={$sys-id}&amp;id={@xml:id}">Part&#xA0;<xsl:number/></a>
        </h3>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:key name="facsimile-by-id" match="tei:facsimile" use="@xml:id"/>

    <xsl:template match="tei:pb">
        <xsl:variable name="facsId" select="substring-after(@facs, '#')"/>
        <xsl:variable name="href" select="concat('page?url=', $sys-id, '&amp;id=', $facsId)"/>
        <h4>
            <a href="{$href}">Page&#xA0;<xsl:value-of select="@n"/></a>
            <a href="{$href}">
                <img src='images/{key("facsimile-by-id", $facsId)/tei:graphic/@url}'/>
            </a>
        </h4>
    </xsl:template>

</xsl:stylesheet>
