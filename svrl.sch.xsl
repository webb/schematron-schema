<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                version="1.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


   <!--PROLOG-->
   <xsl:output method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


   <!--KEYS AND FUNCTIONS-->


   <!--DEFAULT RULES-->


   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
            <xsl:variable name="p_1"
                          select="1+    count(preceding-sibling::*[name()=name(current())])"/>
            <xsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<xsl:value-of select="$p_1"/>]</xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>']</xsl:text>
            <xsl:variable name="p_2"
                          select="1+   count(preceding-sibling::*[local-name()=local-name(current())])"/>
            <xsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<xsl:value-of select="$p_2"/>]</xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output title="Schema for Schematron Validation Report Language"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:text>The Schematron Validation Report Language is a simple language
          for implementations to use to compare their conformance. It is
          basically a list of all the assertions that fail when validating
          a document, in any order, together with other information such as
          which rules fire. </svrl:text>
         <svrl:text>This schema can be used to validate SVRL documents, and provides examples
          of the use of abstract rules and abstract patterns.</svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="http://purl.oclc.org/dsdl/svrl" prefix="svrl"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Elements</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M4"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Unique Ids</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">N100CFrequiredAttribute</xsl:attribute>
            <xsl:attribute name="name">Required Attributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">N100CFrequiredAttribute</xsl:attribute>
            <xsl:attribute name="name">Required Attributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">N100CFrequiredAttribute</xsl:attribute>
            <xsl:attribute name="name">Required Attributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">N100CFrequiredAttribute</xsl:attribute>
            <xsl:attribute name="name">Required Attributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">N100CFrequiredAttribute</xsl:attribute>
            <xsl:attribute name="name">Required Attributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <svrl:text>Schema for Schematron Validation Report Language</svrl:text>

   <!--PATTERN Elements-->
   <svrl:text>Elements</svrl:text>

	  <!--RULE -->
   <xsl:template match="svrl:schematron-output" priority="1007" mode="M4">
      <svrl:fired-rule context="svrl:schematron-output"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(../*)"/>
         <xsl:otherwise>
            <svrl:failed-assert test="not(../*)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element is the root element.
                 </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(svrl:text) + count(svrl:ns-prefix-in-attribute-values) +count(svrl:fired-rule) + count(svrl:failed-assert) +         count(svrl:successful-report) = count(*)"/>
         <xsl:otherwise>
            <svrl:failed-assert test="count(svrl:text) + count(svrl:ns-prefix-in-attribute-values) +count(svrl:fired-rule) + count(svrl:failed-assert) + count(svrl:successful-report) = count(*)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                 <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> may only contain the following elements: text,
                 ns-prefix-in-attribute-values, active-pattern, fired-rule, failed-assert and
                 successful-report. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="svrl:active-pattern"/>
         <xsl:otherwise>
            <svrl:failed-assert test="svrl:active-pattern">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                 <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> should have at least one active pattern. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="svrl:text" priority="1006" mode="M4">
      <svrl:fired-rule context="svrl:text"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="count(*)=0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element should not contain
                 any elements.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="svrl:diagnostic-reference" priority="1005" mode="M4">
      <svrl:fired-rule context="svrl:diagnostic-reference"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="count(*)=0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element should not contain
                 any elements.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(@diagnostic) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length(@diagnostic) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                 <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> should have a diagnostic attribute, giving the id of
                     the diagnostic.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="svrl:ns-prefix-in-attribute-values"
                 priority="1004"
                 mode="M4">
      <svrl:fired-rule context="svrl:ns-prefix-in-attribute-values"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../svrl:schematron-output"/>
         <xsl:otherwise>
            <svrl:failed-assert test="../svrl:schematron-output">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element is a
                 child of schematron-output. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="count(*)=0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element should not contain
                 any elements.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length(normalize-space(.)) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>
                 element should be empty. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="following-sibling::svrl:active-pattern             or following-sibling::svrl:ns-prefix-in-attribute-value"/>
         <xsl:otherwise>
            <svrl:failed-assert test="following-sibling::svrl:active-pattern or following-sibling::svrl:ns-prefix-in-attribute-value">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> A <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> comes before an active-pattern or another
                 ns-prefix-in-attribute-values element. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="svrl:active-pattern" priority="1003" mode="M4">
      <svrl:fired-rule context="svrl:active-pattern"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../svrl:schematron-output"/>
         <xsl:otherwise>
            <svrl:failed-assert test="../svrl:schematron-output">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element is a
                 child of schematron-output. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="count(*)=0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element should not contain
                 any elements.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length(normalize-space(.)) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>
                 element should be empty. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="svrl:fired-rule" priority="1002" mode="M4">
      <svrl:fired-rule context="svrl:fired-rule"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../svrl:schematron-output"/>
         <xsl:otherwise>
            <svrl:failed-assert test="../svrl:schematron-output">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element is a
                 child of schematron-output. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="count(*)=0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element should not contain
                 any elements.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length(normalize-space(.)) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>
                 element should be empty. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="preceding-sibling::active-pattern |             preceding-sibling::svrl:fired-rule |             preceding-sibling::svrl:failed-assert |             preceding-sibling::svrl:successful-report"/>
         <xsl:otherwise>
            <svrl:failed-assert test="preceding-sibling::active-pattern | preceding-sibling::svrl:fired-rule | preceding-sibling::svrl:failed-assert | preceding-sibling::svrl:successful-report">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> A <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> comes after an active-pattern, an empty fired-rule,
                 a failed-assert or a successful report. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(@context) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length(@context) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element
                 should have a context attribute giving the current
                 context, in simple XPath format. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="svrl:failed-assert | svrl:successful-report"
                 priority="1001"
                 mode="M4">
      <svrl:fired-rule context="svrl:failed-assert | svrl:successful-report"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../svrl:schematron-output"/>
         <xsl:otherwise>
            <svrl:failed-assert test="../svrl:schematron-output">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element is a
                 child of schematron-output. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(svrl:diagnostic-reference) + count(svrl:text) =                  count(*)"/>
         <xsl:otherwise>
            <svrl:failed-assert test="count(svrl:diagnostic-reference) + count(svrl:text) = count(*)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element should only contain a
                 text element and diagnostic reference elements. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(svrl:text) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert test="count(svrl:text) = 1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element should only
                      contain a text element. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="preceding-sibling::svrl:fired-rule |                preceding-sibling::svrl:failed-assert |preceding-sibling::svrl:successful-report"/>
         <xsl:otherwise>
            <svrl:failed-assert test="preceding-sibling::svrl:fired-rule | preceding-sibling::svrl:failed-assert |preceding-sibling::svrl:successful-report">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> A <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> comes after a fired-rule, a failed-assert or a successful-report.
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="*" priority="1000" mode="M4">
      <svrl:fired-rule context="*"/>

		    <!--REPORT -->
      <xsl:if test="true()">
         <svrl:successful-report test="true()">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text> An unknown <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element has been used.
                      </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M4"/>
   <xsl:template match="@*|node()" priority="-2" mode="M4">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

   <!--PATTERN Unique Ids-->
   <svrl:text>Unique Ids</svrl:text>

	  <!--RULE -->
   <xsl:template match="*[@id]" priority="1000" mode="M5">
      <svrl:fired-rule context="*[@id]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(preceding::*[@id=current()/@id][1])"/>
         <xsl:otherwise>
            <svrl:failed-assert test="not(preceding::*[@id=current()/@id][1])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> Id attributes
                      should be unique in a document. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

   <!--PATTERN N100CFrequiredAttributeRequired Attributes-->
   <svrl:text>Required Attributes</svrl:text>

	  <!--RULE -->
   <xsl:template match=" $context " priority="1000" mode="M6">
      <svrl:fired-rule context=" $context "/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( $attribute ) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length( $attribute ) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element
                      should have a <xsl:text/>
                  <xsl:value-of select="$attribute /name()"/>
                  <xsl:text/> attribute.
                      </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

   <!--PATTERN N100CFrequiredAttributeRequired Attributes-->
   <svrl:text>Required Attributes</svrl:text>

	  <!--RULE -->
   <xsl:template match=" $context " priority="1000" mode="M7">
      <svrl:fired-rule context=" $context "/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( $attribute ) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length( $attribute ) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element
                      should have a <xsl:text/>
                  <xsl:value-of select="$attribute /name()"/>
                  <xsl:text/> attribute.
                      </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

   <!--PATTERN N100CFrequiredAttributeRequired Attributes-->
   <svrl:text>Required Attributes</svrl:text>

	  <!--RULE -->
   <xsl:template match=" $context " priority="1000" mode="M8">
      <svrl:fired-rule context=" $context "/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( $attribute ) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length( $attribute ) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element
                      should have a <xsl:text/>
                  <xsl:value-of select="$attribute /name()"/>
                  <xsl:text/> attribute.
                      </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>

   <!--PATTERN N100CFrequiredAttributeRequired Attributes-->
   <svrl:text>Required Attributes</svrl:text>

	  <!--RULE -->
   <xsl:template match=" $context " priority="1000" mode="M9">
      <svrl:fired-rule context=" $context "/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( $attribute ) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length( $attribute ) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element
                      should have a <xsl:text/>
                  <xsl:value-of select="$attribute /name()"/>
                  <xsl:text/> attribute.
                      </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

   <!--PATTERN N100CFrequiredAttributeRequired Attributes-->
   <svrl:text>Required Attributes</svrl:text>

	  <!--RULE -->
   <xsl:template match=" $context " priority="1000" mode="M10">
      <svrl:fired-rule context=" $context "/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length( $attribute ) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert test="string-length( $attribute ) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> The <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element
                      should have a <xsl:text/>
                  <xsl:value-of select="$attribute /name()"/>
                  <xsl:text/> attribute.
                      </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>
</xsl:stylesheet>
