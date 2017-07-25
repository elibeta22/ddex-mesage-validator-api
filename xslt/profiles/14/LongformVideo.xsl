<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
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
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
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
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="Schematron Release Profile for Longform Video (version 1.4) for the&#xA;      NewReleaseMessage."
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:text>© 2006-2017 Digital Data Exchange, LLC (DDEX)</svrl:text>
         <svrl:text>This ISO Schematron file is, together with all DDEX standards, subject to two licences: If
      you wish to evaluate whether the standard meets your needs please have a look at the
      Evaluation Licence at https://kb.ddex.net/display/HBK/Evaluation+Licence+for+DDEX+Standards.
      If you want to implement and use this DDEX standard, please take out an Implementation
      Licence. For details please go to http://ddex.net/apply-ddex-implementation-licence.</svrl:text>
         <svrl:text>Failing a rule with a role of 'Fatal Error' means that the Conformance Tester must recommend
      to not award a Conformance Certificate or to retract a Conformance Certificate if one has
      already been issued. Failing a rule with a role of 'Conditional Fatal Error' is the same as a
      'Fatal Error', however, the rule may be ignored if the Conformance Tester has no means of
      asserting whether the condition expressed in the rule has been met.</svrl:text>
         <svrl:text>Failing a rule a rule with a role of 'Error' means that the Conformance Tester must
      recommend to award a Partial Conformance Certificate or to downgrade a Conformance Certificate
      that has already been issued. However, if more than 11 rules (representing 50% of all rules
      with a role of 'Error' or 'Conditional Error') have been failed at least once, the Conformance
      Tester must recommend to not award a Conformance Certificate or to retract a Conformance
      Certificate if one has already been issued. Failing a rule with a role of 'Conditional Error'
      is the same as an 'Error', however, the rule may be ignored if the Conformance Tester has no
      means of asserting whether the condition expressed in the rule has been met.</svrl:text>
         <svrl:text>The following Clauses from the Release Profile standard are NOT checked by this ISO
      Schematron file: 3.3.1(1), 3.3.1(7)-(8), 3.4, 4.1, 4.2, 4.3(11), 4.3(14), 4.3(15a), 4.3(16b),
      4.3(17), 4.3(19), 4.3(27)-(29), 4.3(37), 4.16(11)-(12), 4.7(11)-(12), 4.8(8), 4.8(9d),
      4.8(10f), 4.8(11)-(12), 4.10(9) and similar clauses, 4.10(10) and similar clauses, 4.14(8) and
      4.15(11).</svrl:text>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DeprecatedDatesMustNotBeUsed</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DeprecatedDatesMustNotBeUsed</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MessageSchemaVersionId</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MessageSchemaVersionId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustNotContainSixResourceGroups</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustNotContainSixResourceGroups</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SoundRecordingMustNotHaveDeprecatedFlags</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SoundRecordingMustNotHaveDeprecatedFlags</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainComponentRelease</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainComponentRelease</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MainReleaseMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MainReleaseMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PrimaryResourcesMustBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PrimaryResourcesMustBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ResourceGroupsMustBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ResourceGroupsMustBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PrimaryResourcesMustBeSequencedWithinTheirGroup</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PrimaryResourcesMustBeSequencedWithinTheirGroup</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ResourceGroupContentItemsMustBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ResourceGroupContentItemsMustBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SecondaryResourcesMustNotBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SecondaryResourcesMustNotBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PrimarySoundRecordingMustHaveIndirectSoundRecordingId</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PrimarySoundRecordingMustHaveIndirectSoundRecordingId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ReleaseResourceTypeMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ReleaseResourceTypeMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainResource</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainResource</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SoundRecordingMustHaveReferenceTitle</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SoundRecordingMustHaveReferenceTitle</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SingleFormalTitlePerTerritory</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SingleFormalTitlePerTerritory</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SingleDisplayTitlePerTerritory</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SingleDisplayTitlePerTerritory</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PLineMustBeProvidedAtTerritorialLevel1</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PLineMustBeProvidedAtTerritorialLevel1</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PLineMustBeProvidedAtTerritorialLevel2</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PLineMustBeProvidedAtTerritorialLevel2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_CLineMustBeProvidedAtTerritorialLevel1</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_CLineMustBeProvidedAtTerritorialLevel1</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_CLineMustBeProvidedAtTerritorialLevel2</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_CLineMustBeProvidedAtTerritorialLevel2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DisplayLabelMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DisplayLabelMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_LabelNameMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_LabelNameMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_UserDefinedLabelNameType</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_UserDefinedLabelNameType</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_GenreMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_GenreMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ParentalWarningTypeMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ParentalWarningTypeMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ReleaseDateMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ReleaseDateMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ResourceReleaseDateMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ResourceReleaseDateMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M33"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MusicalWorkContributorRole</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MusicalWorkContributorRole</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M34"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ShouldContainIndirectResourceContributor</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ShouldContainIndirectResourceContributor</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M35"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ResourceContributorDuplicate</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ResourceContributorDuplicate</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M36"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DisplayArtistNameDuplicate</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DisplayArtistNameDuplicate</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M37"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_IndirectResourceContributorDuplicate</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_IndirectResourceContributorDuplicate</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M38"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_RightSharePercentage</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_RightSharePercentage</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M39"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_RightSharePercentageValue</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_RightSharePercentageValue</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M40"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_CatalogTransfer</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_CatalogTransfer</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M41"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_FlagsOnlyOnContentItems</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_FlagsOnlyOnContentItems</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M42"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_Territory</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_Territory</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M43"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_TerritoryTIS</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_TerritoryTIS</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M44"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISNI</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISNI</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M45"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISRC</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISRC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M46"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_GRid</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_GRid</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M47"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SICI</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SICI</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M48"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISSN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISSN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M49"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISBN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISBN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M50"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_VISAN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_VISAN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M51"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISAN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISAN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M52"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISMN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISMN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M53"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISWC</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISWC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M54"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ICPN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ICPN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M55"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_UserDefinedValue</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_UserDefinedValue</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M56"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_CommentMustNotBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_CommentMustNotBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DisplayArtistsMustBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DisplayArtistsMustBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M58"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SequenceNumberAsElement</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SequenceNumberAsElement</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SequenceNumberAsAttribute</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SequenceNumberAsAttribute</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M60"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PercentageValue</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PercentageValue</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PercentageValue2</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PercentageValue2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M62"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_RightSharePercentageValue2</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_RightSharePercentageValue2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_ReleaseProfileVersionId</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_ReleaseProfileVersionId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M64"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainVideo</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainVideo</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainOneFrontCoverImageAsSecondaryResource</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainOneFrontCoverImageAsSecondaryResource</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M66"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainOneImage</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainOneImage</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M67"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_TrackReleaseMustNotContainManyResources</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_TrackReleaseMustNotContainManyResources</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M68"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PrimaryVideoMustHaveISRC</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PrimaryVideoMustHaveISRC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M69"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_MustContainVideoType</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_MustContainVideoType</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M70"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_MustContainLongFormMusicalWorkVideoRelease</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_MustContainLongFormMusicalWorkVideoRelease</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M71"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_MustContainOneRelease</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_MustContainOneRelease</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M72"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DisplayArtistMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DisplayArtistMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M73"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DisplayArtistNamesMustBeDifferent</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DisplayArtistNamesMustBeDifferent</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M74"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MainReleaseMustHaveGridOrICPN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MainReleaseMustHaveGridOrICPN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M75"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PrimarySoundRecordingMustHaveISRC</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PrimarySoundRecordingMustHaveISRC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M76"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SecondaryResourceMustHaveProprietaryId</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SecondaryResourceMustHaveProprietaryId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M77"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_PrimaryResourcesMustHaveCorrespondingCueSheet</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_PrimaryResourcesMustHaveCorrespondingCueSheet</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M78"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueSheetMustContainCue</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueSheetMustContainCue</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M79"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueMustHaveStartTimeAndDuration</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueMustHaveStartTimeAndDuration</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M80"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueMustHaveIsrcOrISWC</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueMustHaveIsrcOrISWC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M81"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueMustHaveOneFormalTitle</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueMustHaveOneFormalTitle</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M82"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueMustHaveDisplayTitle</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueMustHaveDisplayTitle</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M83"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueMustHaveContributor</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueMustHaveContributor</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M84"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueMustHavePLine</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueMustHavePLine</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M85"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueMustHaveMusicalContent</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueMustHaveMusicalContent</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M86"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CueMustHaveCLine</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CueMustHaveCLine</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M87"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CollectionItemMustBeVideoChapter</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CollectionItemMustBeVideoChapter</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M88"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CollectionItemMustHaveProprietaryId</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CollectionItemMustHaveProprietaryId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M89"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CollectionItemMustHaveTitle</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CollectionItemMustHaveTitle</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M90"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CollectionItemMustBeComplete</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CollectionItemMustBeComplete</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M91"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_CollectionItemMustReferencePrimaryVideo</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_CollectionItemMustReferencePrimaryVideo</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M92"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_PrimaryVideoResourceMustHaveSoundRecordingCollectionReference</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_PrimaryVideoResourceMustHaveSoundRecordingCollectionReference</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M93"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LongformVideo_SoundRecordingCollectionReferenceMustHaveStartTime</xsl:attribute>
            <xsl:attribute name="name">LongformVideo_SoundRecordingCollectionReferenceMustHaveStartTime</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M94"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_LabelNameMustBeProvided2</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_LabelNameMustBeProvided2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M95"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Schematron Release Profile for Longform Video (version 1.4) for the
      NewReleaseMessage.</svrl:text>

   <!--PATTERN MultiProfile_DeprecatedDatesMustNotBeUsed-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage" priority="1000" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*:NewReleaseMessage"/>

		    <!--REPORT Information-->
      <xsl:if test="MidiDetailsByTerritory/RemasteredDate">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="MidiDetailsByTerritory/RemasteredDate">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information:
            #Longform Video) No deprecated date elements should be used.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Information-->
      <xsl:if test="MIDI/MasteredDate">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="MIDI/MasteredDate">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video) No
            deprecated date elements should be used.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Information-->
      <xsl:if test="ReleaseDetailsByTerritory/OriginalDigitalReleaseDate">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ReleaseDetailsByTerritory/OriginalDigitalReleaseDate">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video) No deprecated date elements should be used.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Information-->
      <xsl:if test="Release/GlobalReleaseDate">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="Release/GlobalReleaseDate">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video)
            No deprecated date elements should be used.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Information-->
      <xsl:if test="Release/GlobalOriginalReleaseDate">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="Release/GlobalOriginalReleaseDate">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information:
            #Longform Video) No deprecated date elements should be used.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Information-->
      <xsl:if test="SoundRecordingDetailsByTerritory/RemasteredDate">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="SoundRecordingDetailsByTerritory/RemasteredDate">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video) No deprecated date elements should be used.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Information-->
      <xsl:if test="MIDI/RemasteredDate">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="MIDI/RemasteredDate">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video) No
            deprecated date elements should be used.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MessageSchemaVersionId-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*:NewReleaseMessage"/>

		    <!--ASSERT Information-->
      <xsl:choose>
         <xsl:when test="substring(@MessageSchemaVersionId, 1, 4) = 'ern/' and number(substring(@MessageSchemaVersionId, 5,2)) &gt;= 39"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="substring(@MessageSchemaVersionId, 1, 4) = 'ern/' and number(substring(@MessageSchemaVersionId, 5,2)) &gt;= 39">
               <xsl:attribute name="role">Information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Information: #Longform Video) The MessageSchemaVersionId should be at
            least 3.9.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT Information-->
      <xsl:choose>
         <xsl:when test="@MessageSchemaVersionId = 'ern/39Draft'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@MessageSchemaVersionId = 'ern/39Draft'">
               <xsl:attribute name="role">Information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Information:
            #Longform Video) You are not using the latest XSD supported by this Schematron
            file.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustNotContainSixResourceGroups-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup"
                 priority="1000"
                 mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup"/>

		    <!--REPORT Information-->
      <xsl:if test="ResourceGroup">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ResourceGroup">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video) There
            should not be more than 5 nested ResourceGroups.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SoundRecordingMustNotHaveDeprecatedFlags-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording"
                 priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording"/>

		    <!--REPORT Information-->
      <xsl:if test="IsHiddenResource">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="IsHiddenResource">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video) No
            deprecated Flags (IsHiddenResource) must be provided for SoundRecordings.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Information-->
      <xsl:if test="IsBonusResource">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="IsBonusResource">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video) No
            deprecated Flags (IsBonusResource) must be provided for SoundRecordings.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainComponentRelease-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']]"
                 priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']] | *:NewReleaseMessage/ReleaseList/Release[1]/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="//Release[ReleaseType[(text() = 'TrackRelease') or (text() = 'VideoTrackRelease')]]/ReleaseResourceReferenceList/ReleaseResourceReference = ./ReleaseResourceReference"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//Release[ReleaseType[(text() = 'TrackRelease') or (text() = 'VideoTrackRelease')]]/ReleaseResourceReferenceList/ReleaseResourceReference = ./ReleaseResourceReference">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) One component release should be
            supplied per primary resource referenced on the Main release, regardless of whether
            there are any deals available for the component release (Release Profile 1.4, Clause
            3.1, Rule 1379-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MainReleaseMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList" priority="1000" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="count(Release[@IsMainRelease = 'true']) &lt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(Release[@IsMainRelease = 'true']) &lt; 1">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal
            Error: #Longform Video) At least one Release shall have IsMainRelease flag = True
            (Release Profile 1.4, Clause 3.3.1(1), Rule 1380-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="count(Release) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(Release) &gt; 1">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal
            Error: #Longform Video) More than one Release with IsMainRelease has been specified
            (Release Profile 1.4, Clause 3.3.1(1), Rule 1380-2).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PrimaryResourcesMustBeSequenced-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release/*/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']]"
                 priority="1000"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release/*/ResourceGroup/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="SequenceNumber"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="SequenceNumber">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Track
            bundle resource groups should be sequenced (Release Profile 1.4, Clause
            3.3.1(2)+3.3.1(3)+3.3.1(5), Rule 1381-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ResourceGroupsMustBeSequenced-->


	  <!--RULE -->
   <xsl:template match="//Release[@IsMainRelease = 'true']/ReleaseDetailsByTerritory/ResourceGroup/ResourceGroup"
                 priority="1000"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//Release[@IsMainRelease = 'true']/ReleaseDetailsByTerritory/ResourceGroup/ResourceGroup"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="SequenceNumber"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="SequenceNumber">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) All
            ResourceGroups should be sequenced (Release Profile 1.4, Clause 3.3.1(2), Rule
            1382-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PrimaryResourcesMustBeSequencedWithinTheirGroup-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[@IsMainRelease = 'true']/ReleaseDetailsByTerritory/ResourceGroup/ResourceGroup"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[@IsMainRelease = 'true']/ReleaseDetailsByTerritory/ResourceGroup/ResourceGroup"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="descendant::ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource'] and SequenceNumber &gt; '1'] and not(descendant::ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource'] and SequenceNumber = '1'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="descendant::ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource'] and SequenceNumber &gt; '1'] and not(descendant::ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource'] and SequenceNumber = '1'])">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) All Primary Resources should be
            sequenced in the context of their track bundle ResourceGroup (i.e. the sequence restarts
            with the next track bundle) (Release Profile 1.4, Clause 3.3.1(3), Rule
            1383-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ResourceGroupContentItemsMustBeSequenced-->


	  <!--RULE -->
   <xsl:template match="//Release[@IsMainRelease = 'true']/ReleaseDetailsByTerritory/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference/@ReleaseResourceType='PrimaryResource']"
                 priority="1000"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//Release[@IsMainRelease = 'true']/ReleaseDetailsByTerritory/ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference/@ReleaseResourceType='PrimaryResource']"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="SequenceNumber"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="SequenceNumber">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) All
            ResourceGroupContentItems should be sequenced (Release Profile 1.4, Clause 3.3.1(3),
            Rule 1384-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SecondaryResourcesMustNotBeSequenced-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'SecondaryResource']]"
                 priority="1000"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroup/ResourceGroupContentItem[ReleaseResourceReference[@ReleaseResourceType = 'SecondaryResource']]"/>

		    <!--REPORT Error-->
      <xsl:if test="SequenceNumber">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="SequenceNumber">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error: #Longform Video) Secondary Resources
            (e.g. cover images) content items shall not be sequenced (Release Profile 1.4, Clause
            3.3.1(4), Rule 1385-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PrimarySoundRecordingMustHaveIndirectSoundRecordingId-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroupContentItem[ResourceType = 'SoundRecording']/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"
                 priority="1000"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroupContentItem[ResourceType = 'SoundRecording']/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"/>

		    <!--ASSERT Conditional Fatal Error-->
      <xsl:choose>
         <xsl:when test="//ResourceReference[text() = current()]/../IndirectSoundRecordingId"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceReference[text() = current()]/../IndirectSoundRecordingId">
               <xsl:attribute name="role">Conditional Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Fatal Error: #Longform Video) Primary
            SoundRecording Resources shall have an IndirectSoundRecordingId (Release Profile 1.4,
            Clause 3.3.1(6), Rule 1386-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ReleaseResourceTypeMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:ResourceGroupContentItem/ReleaseResourceReference"
                 priority="1000"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:ResourceGroupContentItem/ReleaseResourceReference"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@ReleaseResourceType"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ReleaseResourceType">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) For
            each ReleaseResourceReference a ReleaseResourceType shall be provided (Release Profile
            1.4, Clause 4.3(1)+4.3(2), Rule 1387-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainResource-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList" priority="1000" mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(*) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(*) &gt; 0">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A
            ResourceList must contain at least one Resource (Release Profile 1.4, Clause 4.3(3),
            Rule 1388-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SoundRecordingMustHaveReferenceTitle-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording"
                 priority="1000"
                 mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(ReferenceTitle[string-length(normalize-space(TitleText)) &gt; 0]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(ReferenceTitle[string-length(normalize-space(TitleText)) &gt; 0]) = 1">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A Single ReferenceTitle must be
            provided for each SoundRecording (Release Profile 1.4, Clause 4.3(4), Rule
            1389-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SingleFormalTitlePerTerritory-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release/ReleaseDetailsByTerritory[1]"
                 priority="1000"
                 mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release/ReleaseDetailsByTerritory[1]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Title[@TitleType='FormalTitle'][string-length(normalize-space(TitleText)) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="Title[@TitleType='FormalTitle'][string-length(normalize-space(TitleText)) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) At least one Title of type FormalTitle
            shall be provided for the default Worldwide ReleaseDetailsByTerritory section (Release
            Profile 1.4, Clause 4.3(4), Rule 1390-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SingleDisplayTitlePerTerritory-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release/ReleaseDetailsByTerritory[1]"
                 priority="1000"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release/ReleaseDetailsByTerritory[1]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Title[@TitleType='DisplayTitle'][string-length(normalize-space(TitleText)) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="Title[@TitleType='DisplayTitle'][string-length(normalize-space(TitleText)) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) At least one Title of type DisplayTitle
            shall be provided for the default Worldwide ReleaseDetailsByTerritory section (Release
            Profile 1.4, Clause 4.3(4), Rule 1391-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PLineMustBeProvidedAtTerritorialLevel1-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[PLine]"
                 priority="1000"
                 mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[PLine]"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="count(ReleaseDetailsByTerritory)=count(ReleaseDetailsByTerritory/PLine)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ReleaseDetailsByTerritory)=count(ReleaseDetailsByTerritory/PLine)">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: A PLine shall not be provided in all
            ReleaseDetailsByTerritory (Release Profile 1.4, Clause 4.3(5a), Rule 1017-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PLineMustBeProvidedAtTerritorialLevel2-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[not(PLine)]"
                 priority="1000"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[not(PLine)]"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="ReleaseDetailsByTerritory[not(PLine)]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ReleaseDetailsByTerritory[not(PLine)]">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: A
            PLine shall be provided in all ReleaseDetailsByTerritory composites if no PLine is
            provided for Release (Release Profile 1.4, Clause 4.3(5a), Rule 1017-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN MultiProfile_CLineMustBeProvidedAtTerritorialLevel1-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[CLine]"
                 priority="1000"
                 mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[CLine]"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="count(ReleaseDetailsByTerritory)=count(ReleaseDetailsByTerritory/CLine)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ReleaseDetailsByTerritory)=count(ReleaseDetailsByTerritory/CLine)">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: A CLine shall not be provided in all
            ReleaseDetailsByTerritory (Release Profile 1.4, 1017-1NR).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

   <!--PATTERN MultiProfile_CLineMustBeProvidedAtTerritorialLevel2-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[not(CLine)]"
                 priority="1000"
                 mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[not(CLine)]"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="ReleaseDetailsByTerritory[not(CLine)]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ReleaseDetailsByTerritory[not(CLine)]">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: A
            CLine shall be provided in all ReleaseDetailsByTerritory composites if no CLine is
            provided for Release (Release Profile 1.4, 1017-1NR).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>

   <!--PATTERN MultiProfile_DisplayLabelMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release/ReleaseDetailsByTerritory[count(LabelName) &gt; 1]"
                 priority="1000"
                 mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release/ReleaseDetailsByTerritory[count(LabelName) &gt; 1]"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="count(LabelName[@LabelNameType='DisplayLabelName']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(LabelName[@LabelNameType='DisplayLabelName']) = 1">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) If more than one LabelName is provided, exactly one shall be a
            DisplayLabelName (Release Profile 1.4, Clause 4.3(6), Rule 1394-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

   <!--PATTERN MultiProfile_LabelNameMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--REPORT Error-->
      <xsl:if test="ReleaseDetailsByTerritory[position() = 1 and not(LabelName[string-length(normalize-space(text())) &gt; 0])] and ReleaseDetailsByTerritory[position() &gt; 1 and not(LabelName[string-length(normalize-space(text())) &gt; 0])]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ReleaseDetailsByTerritory[position() = 1 and not(LabelName[string-length(normalize-space(text())) &gt; 0])] and ReleaseDetailsByTerritory[position() &gt; 1 and not(LabelName[string-length(normalize-space(text())) &gt; 0])]">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error: #Longform Video) If a LabelName is not specified for the Worldwide
            ReleaseDetailsByTerritory, it needs to be specified in all the other
            ReleaseDetailsByTerritory composites (Release Profile 1.4, Clause 4.3(6a)+4.3(6b), Rule
            1395-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>

   <!--PATTERN MultiProfile_UserDefinedLabelNameType-->


	  <!--RULE -->
   <xsl:template match="//LabelName[@UserDefinedValue]" priority="1000" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//LabelName[@UserDefinedValue]"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="@LabelNameType='UserDefined'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@LabelNameType='UserDefined'">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) The
            LabelNameType shall be 'UserDefined' if a user-defined value is supplied for a LabelName
            (Release Profile 1.4, Clause 4.3(6b), Rule 1396-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="@Namespace"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@Namespace">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) The appropriate Namespace
            for the user-defined value shall be provided (Release Profile 1.4, Clause 4.3(6b), Rule
            1396-2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>

   <!--PATTERN MultiProfile_GenreMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="ReleaseDetailsByTerritory[position = 1 and not(Genre/GenreText[string-length(normalize-space(text())) &gt; 0])] and ReleaseDetailsByTerritory[position() &gt; 1 and not(Genre/GenreText[string-length(normalize-space(text())) &gt; 0])]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ReleaseDetailsByTerritory[position = 1 and not(Genre/GenreText[string-length(normalize-space(text())) &gt; 0])] and ReleaseDetailsByTerritory[position() &gt; 1 and not(Genre/GenreText[string-length(normalize-space(text())) &gt; 0])]">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) If a Genre is not specified for the
            Worldwide ReleaseDetailsByTerritory, it needs to be specified in all the other
            ReleaseDetailsByTerritory composites. (Release Profile 1.4, Clause 4.3(7), Rule
            1397-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ParentalWarningTypeMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage" priority="1000" mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*:NewReleaseMessage"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="//ParentalWarningType[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ParentalWarningType[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) The appropriate ParentalWarningType shall be
            provided (Release Profile 1.4, Clause 4.3(8), Rule 1398-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ReleaseDateMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M32">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--ASSERT Conditional Error-->
      <xsl:choose>
         <xsl:when test="ReleaseDetailsByTerritory/ReleaseDate | GlobalReleaseDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReleaseDetailsByTerritory/ReleaseDate | GlobalReleaseDate">
               <xsl:attribute name="role">Conditional Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Error: #Longform Video) A GlobalReleaseDate or a
            ReleaseDate shall be provided for each Release (Release Profile 1.4, Clause 4.3(9), Rule
            1399-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ResourceReleaseDateMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroupContentItem/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"
                 priority="1000"
                 mode="M33">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroupContentItem/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"/>

		    <!--ASSERT Conditional Error-->
      <xsl:choose>
         <xsl:when test="//ResourceReference[text() = current()]/../SoundRecordingDetailsByTerritory/ResourceReleaseDate | //ResourceReference[text() = current()]/../SoundRecordingDetailsByTerritory/OriginalResourceReleaseDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceReference[text() = current()]/../SoundRecordingDetailsByTerritory/ResourceReleaseDate | //ResourceReference[text() = current()]/../SoundRecordingDetailsByTerritory/OriginalResourceReleaseDate">
               <xsl:attribute name="role">Conditional Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Error: #Longform Video) A ResourceReleaseDate or an
            OriginalResourceReleaseDate shall be provided for each primary Resource if available to
            the Message Sender (Release Profile 1.4, Clause 4.3(10), Rule 1400-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MusicalWorkContributorRole-->


	  <!--RULE -->
   <xsl:template match="//MusicalWork" priority="1000" mode="M34">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//MusicalWork"/>

		    <!--ASSERT Conditional Error-->
      <xsl:choose>
         <xsl:when test="MusicalWorkContributor/MusicalWorkContributorRole[text() = 'Adapter' or text() = 'Arranger' or text() = 'AssociatedPerformer' or text() = 'Author' or text() = 'Composer' or text() = 'ComposerLyricist' or text() = 'Librettist' or text() = 'Lyricist' or text() = 'NonLyricAuthor' or text() = 'SubArranger' or text() = 'Translator']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="MusicalWorkContributor/MusicalWorkContributorRole[text() = 'Adapter' or text() = 'Arranger' or text() = 'AssociatedPerformer' or text() = 'Author' or text() = 'Composer' or text() = 'ComposerLyricist' or text() = 'Librettist' or text() = 'Lyricist' or text() = 'NonLyricAuthor' or text() = 'SubArranger' or text() = 'Translator']">
               <xsl:attribute name="role">Conditional Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Error: #Longform Video) If there is a MusicalWork,
            there has to be a creative contributor (Release Profile 1.4, Clause 4.3(12a), Rule
            1401-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ShouldContainIndirectResourceContributor-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording/SoundRecordingDetailsByTerritory"
                 priority="1000"
                 mode="M35">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording/SoundRecordingDetailsByTerritory"/>

		    <!--ASSERT Conditional Error-->
      <xsl:choose>
         <xsl:when test="IndirectResourceContributor"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="IndirectResourceContributor">
               <xsl:attribute name="role">Conditional Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Error:
            #Longform Video) No MusicalWorkContributor was found; information of at least one
            MusicalWorkContributor should be provided if available (Release Profile 1.4, Clause
            4.3(12a), Rule 1402-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ResourceContributorDuplicate-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/*/*"
                 priority="1000"
                 mode="M36">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/*/*"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(ResourceContributor)=count(ResourceContributor[not(PartyId=preceding-sibling::ResourceContributor/PartyId)])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(ResourceContributor)=count(ResourceContributor[not(PartyId=preceding-sibling::ResourceContributor/PartyId)])">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) ResourceContributors shall be provided
            only once (with multiple roles) (Release Profile 1.4, Clause 4.3(13)+4.3(20), Rule
            1403-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>

   <!--PATTERN MultiProfile_DisplayArtistNameDuplicate-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList" priority="1000" mode="M37">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList"/>

		    <!--REPORT Error-->
      <xsl:if test="*/*/DisplayArtistName">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*/*/DisplayArtistName">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error: #Longform Video) The
            DisplayArtistNames of a Resource shall not be the same as the DisplayArtistName of the
            Album it belongs to (Release Profile 1.4, Clause 4.3(18), Rule 1404-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M37"/>
   <xsl:template match="@*|node()" priority="-2" mode="M37">
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>

   <!--PATTERN MultiProfile_IndirectResourceContributorDuplicate-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/*/*"
                 priority="1000"
                 mode="M38">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/*/*"/>

		    <!--ASSERT Conditional Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(IndirectResourceContributor)=count(IndirectResourceContributor[not(PartyId=preceding-sibling::IndirectResourceContributor/PartyId)])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(IndirectResourceContributor)=count(IndirectResourceContributor[not(PartyId=preceding-sibling::IndirectResourceContributor/PartyId)])">
               <xsl:attribute name="role">Conditional Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Fatal Error: #Longform Video)
            IndirectResourceContributors shall be provided only once (with multiple roles) (Release
            Profile 1.4, Clause 4.3(21), Rule 1405-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M38"/>
   <xsl:template match="@*|node()" priority="-2" mode="M38">
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>

   <!--PATTERN MultiProfile_RightSharePercentage-->


	  <!--RULE -->
   <xsl:template match="//MusicalWork" priority="1000" mode="M39">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//MusicalWork"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="sum(//RightShare/RightSharePercentage) &gt; 100">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="sum(//RightShare/RightSharePercentage) &gt; 100">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal
            Error: #Longform Video) The total of all RightSharePercentages for each MusicalWork must
            not exceed 100% (Release Profile 1.4, Clause 4.3(22), Rule 1406-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M39"/>
   <xsl:template match="@*|node()" priority="-2" mode="M39">
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>

   <!--PATTERN MultiProfile_RightSharePercentageValue-->


	  <!--RULE -->
   <xsl:template match="//RightSharePercentage" priority="1000" mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//RightSharePercentage"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="//RightSharePercentage &gt; 0 and //RightSharePercentage &lt; 100"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//RightSharePercentage &gt; 0 and //RightSharePercentage &lt; 100">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A RightSharePercentage has a value
            between 0 and 100 (Release Profile 1.4, Clause 4.3(22), Rule 1407-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>

   <!--PATTERN MultiProfile_CatalogTransfer-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage" priority="1000" mode="M41">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*:NewReleaseMessage"/>

		    <!--REPORT Conditional Fatal Error-->
      <xsl:if test="CatalogTransfer">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="CatalogTransfer">
            <xsl:attribute name="role">Conditional Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Conditional Fatal Error:
            #Longform Video) The CatalogTransfer element has been used. This is only to be used when
            communicating a catalogue transfer (Release Profile 1.4, Clause 4.3(23), Rule
            1408-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>

   <!--PATTERN MultiProfile_FlagsOnlyOnContentItems-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage" priority="1000" mode="M42">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*:NewReleaseMessage"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="SoundRecording/IsHiddenResource | MIDI/IsHiddenResource | Video/IsHiddenResource">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="SoundRecording/IsHiddenResource | MIDI/IsHiddenResource | Video/IsHiddenResource">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) IsHiddenResource must not be used on a
            Resource (Release Profile 1.4, Clause 4.3(24)+4.10(7g)+4.10(7h), Rule
            1409-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="SoundRecording/IsBonusResource | MIDI/IsBonusResource | Video/IsBonusResource">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="SoundRecording/IsBonusResource | MIDI/IsBonusResource | Video/IsBonusResource">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) IsBonusResource must not be used on a
            Resource (Release Profile 1.4, Clause 4.3(24)+4.10(7g)+4.10(7h), Rule
            1409-2).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>

   <!--PATTERN MultiProfile_Territory-->


	  <!--RULE -->
   <xsl:template match="//TerritoryCode | //ExcludedTerritoryCode"
                 priority="1000"
                 mode="M43">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//TerritoryCode | //ExcludedTerritoryCode"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="(substring(@IdentifierType, 1, 3) = 'ISO' or not(@IdentifierType)) and string-length(normalize-space(text())) != 2 and text() != 'Worldwide' and translate(text(), 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '') != ''">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(substring(@IdentifierType, 1, 3) = 'ISO' or not(@IdentifierType)) and string-length(normalize-space(text())) != 2 and text() != 'Worldwide' and translate(text(), 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '') != ''">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) A TerritoryCode of type 'ISO' must be a
            two-letter code or 'Worldwide' (Release Profile 1.4, Clause 4.3(25), Rule
            1410-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="substring(@IdentifierType, 1, 3) = 'TIS' and number() != .">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="substring(@IdentifierType, 1, 3) = 'TIS' and number() != .">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) A TerritoryCode of type 'TIS' must be a
            numeric code (Release Profile 1.4, Clause 4.3(25), Rule 1410-2).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="substring(@IdentifierType, 1, 3) = 'Dep' and (string-length(normalize-space(text())) != 4 or number() = .)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="substring(@IdentifierType, 1, 3) = 'Dep' and (string-length(normalize-space(text())) != 4 or number() = .)">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) A deprecated TerritoryCode must be a
            four-letter code (Release Profile 1.4, Clause 4.3(25), Rule 1410-3).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>

   <!--PATTERN MultiProfile_TerritoryTIS-->


	  <!--RULE -->
   <xsl:template match="//TerritoryCode | //ExcludedTerritoryCode"
                 priority="1000"
                 mode="M44">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//TerritoryCode | //ExcludedTerritoryCode"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="substring(@IdentifierType, 1, 3) = 'TIS'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="substring(@IdentifierType, 1, 3) = 'TIS'">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error:
            #Longform Video) A TerritoryCode of type 'TIS' must not be used (Release Profile 1.4,
            Clause 4.3(25), Rule 1411-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISNI-->


	  <!--RULE -->
   <xsl:template match="//PartyId[@IsISNI = 'true']" priority="1000" mode="M45">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//PartyId[@IsISNI = 'true']"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[0-9]{15}[X0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[0-9]{15}[X0-9]$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform
            Video) A PartyId of type 'ISNI' must be a string conforming to the pattern
            [0-9]{15}[X0-9] (Release Profile 1.4, Clause 4.3(30), Rule 1412-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISRC-->


	  <!--RULE -->
   <xsl:template match="//ISRC" priority="1000" mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISRC"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[a-zA-Z]{2}[a-zA-Z0-9]{3}[0-9]{7}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[a-zA-Z]{2}[a-zA-Z0-9]{3}[0-9]{7}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal
            Error: #Longform Video) An ISRC must be a string conforming to the pattern
            [a-zA-Z]{2}[a-zA-Z0-9]{3}[0-9]{7} (Release Profile 1.4, Clause 4.3(30), Rule
            1413-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(substring(.,1,2), '(FX|QM|UK|CP|DG|ZZ|AD|AE|AF|AG|AI|AL|AM|AN|AO|AQ|AR|AS|AT|AU|AW|AX|AZ|BA|BB|BD|BE|BF|BG|BH|BI|BJ|BL|BM|BN|BO|BQ|BR|BS|BT|BV|BW|BY|BZ|CA|CC|CD|CF|CG|CH|CI|CK|CL|CM|CN|CO|CR|CS|CU|CV|CW|CX|CY|CZ|DE|DJ|DK|DM|DO|DZ|EC|EE|EG|EH|ER|ES|ET|FI|FJ|FK|FM|FO|FR|GA|GB|GD|GE|GF|GG|GH|GI|GL|GM|GN|GP|GQ|GR|GS|GT|GU|GW|GY|HK|HM|HN|HR|HT|HU|ID|IE|IL|IM|IN|IO|IQ|IR|IS|IT|JE|JM|JO|JP|KE|KG|KH|KI|KM|KN|KP|KR|KW|KY|KZ|LA|LB|LC|LI|LK|LR|LS|LT|LU|LV|LY|MA|MC|MD|ME|MF|MG|MH|MK|ML|MM|MN|MO|MP|MQ|MR|MS|MT|MU|MV|MW|MX|MY|MZ|NA|NC|NE|NF|NG|NI|NL|NO|NP|NR|NU|NZ|OM|PA|PE|PF|PG|PH|PK|PL|PM|PN|PR|PS|PT|PW|PY|QA|RE|RO|RS|RU|RW|SA|SB|SC|SD|SE|SG|SH|SI|SJ|SK|SL|SM|SN|SO|SR|SS|ST|SV|SX|SY|SZ|TC|TD|TF|TG|TH|TJ|TK|TL|TM|TN|TO|TR|TT|TV|TW|TZ|UA|UG|UM|US|UY|UZ|VA|VC|VE|VG|VI|VN|VU|WF|WS|YE|YT|ZA|ZM|ZW)')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(substring(.,1,2), '(FX|QM|UK|CP|DG|ZZ|AD|AE|AF|AG|AI|AL|AM|AN|AO|AQ|AR|AS|AT|AU|AW|AX|AZ|BA|BB|BD|BE|BF|BG|BH|BI|BJ|BL|BM|BN|BO|BQ|BR|BS|BT|BV|BW|BY|BZ|CA|CC|CD|CF|CG|CH|CI|CK|CL|CM|CN|CO|CR|CS|CU|CV|CW|CX|CY|CZ|DE|DJ|DK|DM|DO|DZ|EC|EE|EG|EH|ER|ES|ET|FI|FJ|FK|FM|FO|FR|GA|GB|GD|GE|GF|GG|GH|GI|GL|GM|GN|GP|GQ|GR|GS|GT|GU|GW|GY|HK|HM|HN|HR|HT|HU|ID|IE|IL|IM|IN|IO|IQ|IR|IS|IT|JE|JM|JO|JP|KE|KG|KH|KI|KM|KN|KP|KR|KW|KY|KZ|LA|LB|LC|LI|LK|LR|LS|LT|LU|LV|LY|MA|MC|MD|ME|MF|MG|MH|MK|ML|MM|MN|MO|MP|MQ|MR|MS|MT|MU|MV|MW|MX|MY|MZ|NA|NC|NE|NF|NG|NI|NL|NO|NP|NR|NU|NZ|OM|PA|PE|PF|PG|PH|PK|PL|PM|PN|PR|PS|PT|PW|PY|QA|RE|RO|RS|RU|RW|SA|SB|SC|SD|SE|SG|SH|SI|SJ|SK|SL|SM|SN|SO|SR|SS|ST|SV|SX|SY|SZ|TC|TD|TF|TG|TH|TJ|TK|TL|TM|TN|TO|TR|TT|TV|TW|TZ|UA|UG|UM|US|UY|UZ|VA|VC|VE|VG|VI|VN|VU|WF|WS|YE|YT|ZA|ZM|ZW)')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) An ISRC must be a string starting with
            an ISO 3166 code or FX, QM, UK, CP, DG or ZZ (Release Profile 1.4, Clause 4.3(30), Rule
            1413-2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>

   <!--PATTERN MultiProfile_GRid-->


	  <!--RULE -->
   <xsl:template match="//GRid" priority="1000" mode="M47">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//GRid"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[a-zA-Z0-9]{18}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[a-zA-Z0-9]{18}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform
            Video) A GRid must be a string conforming to the pattern [a-zA-Z0-9]{18} (Release
            Profile 1.4, Clause 4.3(30), Rule 1414-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SICI-->


	  <!--RULE -->
   <xsl:template match="//SICI" priority="1000" mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//SICI"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[0-9]{4}-[0-9]{3}[X0-9].+')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[0-9]{4}-[0-9]{3}[X0-9].+')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) A SICI must be a string conforming to the pattern
            [0-9]{4}-[0-9]{3}[X0-9].+ (Release Profile 1.4, Clause 4.3(30), Rule 1415-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M48"/>
   <xsl:template match="@*|node()" priority="-2" mode="M48">
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISSN-->


	  <!--RULE -->
   <xsl:template match="//ISSN" priority="1000" mode="M49">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISSN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[0-9]{4}-[0-9]{3}[X0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[0-9]{4}-[0-9]{3}[X0-9]$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) An ISSN must be a string conforming to the pattern
            [0-9]{4}-[0-9]{3}[X0-9] (Release Profile 1.4, Clause 4.3(30), Rule 1416-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISBN-->


	  <!--RULE -->
   <xsl:template match="//ISBN" priority="1000" mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISBN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^97[8-9][0-9]{9}[X0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^97[8-9][0-9]{9}[X0-9]$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) An ISBN must be a string conforming to the pattern
            97[8-9][0-9]{9}[X0-9] (Release Profile 1.4, Clause 4.3(30), Rule 1417-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>

   <!--PATTERN MultiProfile_VISAN-->


	  <!--RULE -->
   <xsl:template match="//VISAN" priority="1000" mode="M51">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//VISAN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-F0-9]{24}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[A-F0-9]{24}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform
            Video) A VISAN must be a string conforming to the pattern [A-F0-9]{24} (Release Profile
            1.4, Clause 4.3(30), Rule 1418-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISAN-->


	  <!--RULE -->
   <xsl:template match="//ISAN" priority="1000" mode="M52">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISAN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-F0-9]{12}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[A-F0-9]{12}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform
            Video) An ISAN must be a string conforming to the pattern [A-F0-9]{12} (Release Profile
            1.4, Clause 4.3(30), Rule 1419-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISMN-->


	  <!--RULE -->
   <xsl:template match="//ISMN" priority="1000" mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISMN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^979[0-9]{9}[X0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^979[0-9]{9}[X0-9]$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) An ISMN must be a string conforming to the pattern 979[0-9]{9}[X0-9]
            (Release Profile 1.4, Clause 4.3(30), Rule 1420-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISWC-->


	  <!--RULE -->
   <xsl:template match="//ISWC" priority="1000" mode="M54">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISWC"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[a-zA-Z][0-9]{10}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[a-zA-Z][0-9]{10}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) An ISWC must be a string conforming to the pattern [a-zA-Z][0-9]{10}
            (Release Profile 1.4, Clause 4.3(30), Rule 1421-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ICPN-->


	  <!--RULE -->
   <xsl:template match="//ICPN" priority="1000" mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ICPN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[0-9]{8}$|^[0-9]{12,14}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[0-9]{8}$|^[0-9]{12,14}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) An ICPN must be a string conforming to the pattern [0-9]{8} or
            [0-9]{12,14} (Release Profile 1.4, Clause 4.3(30), Rule 1422-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>

   <!--PATTERN MultiProfile_UserDefinedValue-->


	  <!--RULE -->
   <xsl:template match="//*[(name() != 'LabelName') and @UserDefinedValue]"
                 priority="1000"
                 mode="M56">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//*[(name() != 'LabelName') and @UserDefinedValue]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test=".='UserDefined'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".='UserDefined'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) The value
            shall be 'UserDefined' if a user-defined value is supplied (Release Profile 1.4, Clause
            4.3(31), Rule 1423-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@Namespace"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@Namespace">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) The
            appropriate Namespace for the user-defined value shall be provided (Release Profile 1.4,
            Clause 4.3(31), Rule 1423-2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>

   <!--PATTERN MultiProfile_CommentMustNotBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage" priority="1000" mode="M57">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*:NewReleaseMessage"/>

		    <!--REPORT Error-->
      <xsl:if test="//Comment">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//Comment">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error: #Longform Video) No Comment shall be
            provided (Release Profile 1.4, Clause 4.3(32), Rule 1424-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>

   <!--PATTERN MultiProfile_DisplayArtistsMustBeSequenced-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release/ReleaseDetailsByTerritory/DisplayArtist"
                 priority="1000"
                 mode="M58">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release/ReleaseDetailsByTerritory/DisplayArtist"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@SequenceNumber"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@SequenceNumber">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) All
            DisplayArtists should be sequenced (Release Profile 1.4, Clause 4.3(34), Rule
            1425-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SequenceNumberAsElement-->


	  <!--RULE -->
   <xsl:template match="//*[SequenceNumber]" priority="1000" mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//*[SequenceNumber]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="number(SequenceNumber) &gt; 0 and number(SequenceNumber) &lt; count(preceding-sibling::*[SequenceNumber])+count(following-sibling::*[SequenceNumber])+2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="number(SequenceNumber) &gt; 0 and number(SequenceNumber) &lt; count(preceding-sibling::*[SequenceNumber])+count(following-sibling::*[SequenceNumber])+2">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: SequenceNumbers must run from 1 to the number of
            sequenced elements (Release Profile 1.4, Clause 4.3(35), Rule 1669-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT Fatal Error-->
      <xsl:if test="preceding-sibling::*/SequenceNumber = SequenceNumber">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="preceding-sibling::*/SequenceNumber = SequenceNumber">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: SequenceNumbers must all be different (Release Profile 1.3, Clause
            4.3(35), Rule 1129-2).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SequenceNumberAsAttribute-->


	  <!--RULE -->
   <xsl:template match="//*[@SequenceNumber]" priority="1000" mode="M60">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//*[@SequenceNumber]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@SequenceNumber &gt; 0 and @SequenceNumber &lt; 1+count(../*[name()=name(current())])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@SequenceNumber &gt; 0 and @SequenceNumber &lt; 1+count(../*[name()=name(current())])">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) SequenceNumbers must run from 1 to the
            number of sequenced elements (Release Profile 1.4, Clause 4.3(35), Rule
            1427-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT Fatal Error-->
      <xsl:if test="@SequenceNumber=following-sibling::*[name()=name(current())]/@SequenceNumber">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@SequenceNumber=following-sibling::*[name()=name(current())]/@SequenceNumber">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) SequenceNumbers must all be different
            (Release Profile 1.4, Clause 4.3(35), Rule 1427-2).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PercentageValue-->


	  <!--RULE -->
   <xsl:template match="//*[@HasMaxValueOfOne = 'true']" priority="1000" mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//*[@HasMaxValueOfOne = 'true']"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="number(.) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="number(.) &gt; 1">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error: #Longform Video) A
            Percentage with HasMaxValueOfOne set to true has a value between 0 and 1 (Release
            Profile 1.4, Clause 4.3(36a), Rule 1428-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PercentageValue2-->


	  <!--RULE -->
   <xsl:template match="//*[@HasMaxValueOfOne = 'false']" priority="1000" mode="M62">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//*[@HasMaxValueOfOne = 'false']"/>

		    <!--REPORT Information-->
      <xsl:if test="number(.) &lt;= 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="number(.) &lt;= 1">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video)
            Percentages are typically provided in the interval between 0 and 100. The value provided
            seems to indicate a value equal to, or less than, 1% (Release Profile 1.4, Clause
            4.3(36b), Rule 1429-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>

   <!--PATTERN MultiProfile_RightSharePercentageValue2-->


	  <!--RULE -->
   <xsl:template match="//RightSharePercentage[not(@HasMaxValueOfOne)]"
                 priority="1000"
                 mode="M63">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//RightSharePercentage[not(@HasMaxValueOfOne)]"/>

		    <!--REPORT Information-->
      <xsl:if test="number(.) &lt;= 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="number(.) &lt;= 1">
            <xsl:attribute name="role">Information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Information: #Longform Video)
            Percentages are typically provided in the interval between 0 and 100. The value provided
            seems to indicate a value equal to, or less than, 1% (Release Profile 1.4, Clause
            4.3(36b), Rule 1430-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>

   <!--PATTERN LongformVideo_ReleaseProfileVersionId-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage" priority="1000" mode="M64">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*:NewReleaseMessage"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@ReleaseProfileVersionId = 'CommonReleaseTypes/14/LongformMusicVideo'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ReleaseProfileVersionId = 'CommonReleaseTypes/14/LongformMusicVideo'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) The ReleaseProfileVersionId should be
            'CommonReleaseTypes/14/LongformMusicVideo' (Release Profile 1.4, Clause 3.2, Rule
            1431-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainVideo-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList" priority="1000" mode="M65">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Video"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="Video">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A Release of this
            type must contain at least one Video (Release Profile 1.4, Clause 3.1, Rule
            1432-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainOneFrontCoverImageAsSecondaryResource-->


	  <!--RULE -->
   <xsl:template match="//Release[@IsMainRelease='true']/ReleaseDetailsByTerritory/ResourceGroup/ResourceGroupContentItem"
                 priority="1000"
                 mode="M66">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//Release[@IsMainRelease='true']/ReleaseDetailsByTerritory/ResourceGroup/ResourceGroupContentItem"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(//ResourceList/Image[ImageType/text() = 'FrontCoverImage' and ResourceReference=current()/ReleaseResourceReference[@ReleaseResourceType = 'SecondaryResource']]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(//ResourceList/Image[ImageType/text() = 'FrontCoverImage' and ResourceReference=current()/ReleaseResourceReference[@ReleaseResourceType = 'SecondaryResource']]) = 1">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A Release of this type must contain
            exactly one Image of type FrontCoverImage as a secondary Resource (Release Profile 1.4,
            Clause 3.1, Rule 1433-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainOneImage-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList" priority="1000" mode="M67">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(Image) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(Image) &gt; 0">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A
            Release of this type must contain one Image (Release Profile 1.4, Clause
            3.1, Rule 1434-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M67"/>
   <xsl:template match="@*|node()" priority="-2" mode="M67">
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>

   <!--PATTERN MultiProfile_TrackReleaseMustNotContainManyResources-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[ReleaseType[text() = 'TrackRelease']]/ReleaseResourceReferenceList"
                 priority="1000"
                 mode="M68">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[ReleaseType[text() = 'TrackRelease']]/ReleaseResourceReferenceList"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="count(ReleaseResourceReference) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ReleaseResourceReference) &gt; 1">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error:
            #Longform Video) A Track Release must not contain more than one Resource (Release
            Profile 1.4, Clause 3.1, Rule 1435-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M68"/>
   <xsl:template match="@*|node()" priority="-2" mode="M68">
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PrimaryVideoMustHaveISRC-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroupContentItem[ResourceType = 'Video']/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"
                 priority="1000"
                 mode="M69">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroupContentItem[ResourceType = 'Video']/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="//ResourceReference[text() = current()]/../*/ISRC[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceReference[text() = current()]/../*/ISRC[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) Primary Video Resources should be identified with
            an ISRC (Release Profile 1.4, Clause 3.1, Rule 1436-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M69"/>
   <xsl:template match="@*|node()" priority="-2" mode="M69">
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>

   <!--PATTERN LongformVideo_MustContainVideoType-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList" priority="1000" mode="M70">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Video/VideoType[text() = 'LongFormMusicalWorkVideo' or text() = 'ConcertVideo' or text() = 'Documentary']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="Video/VideoType[text() = 'LongFormMusicalWorkVideo' or text() = 'ConcertVideo' or text() = 'Documentary']">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A Longform Video must contain at least
            one Video of type LongFormMusicalWorkVideo or ConcertVideo or Documentary (Release
            Profile 1.4, Clause 3.1, Rule 1437-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M70"/>
   <xsl:template match="@*|node()" priority="-2" mode="M70">
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>

   <!--PATTERN LongformVideo_MustContainLongFormMusicalWorkVideoRelease-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList" priority="1000" mode="M71">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Release/ReleaseType[text() = 'LongFormMusicalWorkVideoRelease']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="Release/ReleaseType[text() = 'LongFormMusicalWorkVideoRelease']">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A Longform Video must contain one
            LongFormMusicalWorkVideoRelease (Release Profile 1.4, Clause 3.1, Rule
            1438-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M71"/>
   <xsl:template match="@*|node()" priority="-2" mode="M71">
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>

   <!--PATTERN LongformVideo_MustContainOneRelease-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList" priority="1000" mode="M72">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(Release) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(Release) = 1">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) A
            Longform Video must only contain one Release (Release Profile 1.4, Clause 3.1, Rule
            1439-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M72"/>
   <xsl:template match="@*|node()" priority="-2" mode="M72">
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>

   <!--PATTERN MultiProfile_DisplayArtistMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="ReleaseDetailsByTerritory/DisplayArtist"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReleaseDetailsByTerritory/DisplayArtist">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) At least one DisplayArtist shall be provided (Release Profile 1.4,
            Clause 4.3(12c)+4.3(15b), Rule 1440-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M73"/>
   <xsl:template match="@*|node()" priority="-2" mode="M73">
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>

   <!--PATTERN MultiProfile_DisplayArtistNamesMustBeDifferent-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--REPORT Error-->
      <xsl:if test="ReleaseDetailsByTerritory/DisplayArtistName = ReleaseResourceReferenceList/descendant::DisplayArtistName">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ReleaseDetailsByTerritory/DisplayArtistName = ReleaseResourceReferenceList/descendant::DisplayArtistName">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error: #Longform Video) DisplayArtistNames for Release and Resource must be
            different (Release Profile 1.4, Clause 4.3(16a), Rule 1441-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M74"/>
   <xsl:template match="@*|node()" priority="-2" mode="M74">
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MainReleaseMustHaveGridOrICPN-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList" priority="1000" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Release[@IsMainRelease = 'true']/ReleaseId/GRid[string-length(normalize-space(text())) &gt; 0] | Release[@IsMainRelease = 'true']/ReleaseId/ICPN[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="Release[@IsMainRelease = 'true']/ReleaseId/GRid[string-length(normalize-space(text())) &gt; 0] | Release[@IsMainRelease = 'true']/ReleaseId/ICPN[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) The MainRelease shall be identified by
            either a GRid or by an ICPN (Release Profile 1.4, Clause 4.8(4), Rule
            1442-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M75"/>
   <xsl:template match="@*|node()" priority="-2" mode="M75">
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PrimarySoundRecordingMustHaveISRC-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroupContentItem[ResourceType = 'SoundRecording']/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"
                 priority="1000"
                 mode="M76">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroupContentItem[ResourceType = 'SoundRecording']/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="//ResourceReference[text() = current()]/../*/ISRC[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceReference[text() = current()]/../*/ISRC[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Primary SoundRecording Resources shall
            be identified with an ISRC (Release Profile 1.4, Clause 4.8(5), Rule 1443-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M76"/>
   <xsl:template match="@*|node()" priority="-2" mode="M76">
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SecondaryResourceMustHaveProprietaryId-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroupContentItem/ReleaseResourceReference[@ReleaseResourceType = 'SecondaryResource']"
                 priority="1000"
                 mode="M77">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroupContentItem/ReleaseResourceReference[@ReleaseResourceType = 'SecondaryResource']"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="//ResourceReference[text() = current()]/../*/ProprietaryId[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceReference[text() = current()]/../*/ProprietaryId[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Secondary Resources shall be identified
            by a ProprietaryId (Release Profile 1.4, Clause 4.8(6), Rule 1444-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M77"/>
   <xsl:template match="@*|node()" priority="-2" mode="M77">
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>

   <!--PATTERN LongformVideo_PrimaryResourcesMustHaveCorrespondingCueSheet-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroupContentItem/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"
                 priority="1000"
                 mode="M78">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroupContentItem/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="//ResourceReference[text() = current()]/../*/VideoCueSheetReference[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceReference[text() = current()]/../*/VideoCueSheetReference[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) Each primary Longform video resource should have a
            corresponding CueSheet referenced using the VideoCueSheetReference on the resource
            (Release Profile 1.4, Clause 4.8(9a), Rule 1445-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M78"/>
   <xsl:template match="@*|node()" priority="-2" mode="M78">
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueSheetMustContainCue-->


	  <!--RULE -->
   <xsl:template match="//CueSheet" priority="1000" mode="M79">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//CueSheet"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Cue"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="Cue">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Each CueSheet will
            consist of 1 to many Cues (Release Profile 1.4, Clause 4.8(9b), Rule 1446-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M79"/>
   <xsl:template match="@*|node()" priority="-2" mode="M79">
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueMustHaveStartTimeAndDuration-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="StartTime[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="StartTime[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Each Cue should have a StartTime
            (Release Profile 1.4, Clause 4.8(9c), Rule 1447-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Duration[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="Duration[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Each Cue should have a Duration (Release Profile 1.4,
            Clause 4.8(9c), Rule 1447-2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueMustHaveIsrcOrISWC-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M81">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="ReferencedCreationId/ISRC[string-length(normalize-space(text())) &gt; 0] | ReferencedCreationId/ISWC[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReferencedCreationId/ISRC[string-length(normalize-space(text())) &gt; 0] | ReferencedCreationId/ISWC[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Each Cue should have an ISRC or an ISWC
            (Release Profile 1.4, Clause 4.8(9e1), Rule 1448-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M81"/>
   <xsl:template match="@*|node()" priority="-2" mode="M81">
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueMustHaveOneFormalTitle-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M82">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="count(ReferencedCreationTitle[@TitleType='FormalTitle']/TitleText[string-length(normalize-space(text())) &gt; 0]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(ReferencedCreationTitle[@TitleType='FormalTitle']/TitleText[string-length(normalize-space(text())) &gt; 0]) = 1">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) Each Cue should have one and only one
            ReferencedCreationTitle of type FormalTitle (Release Profile 1.4, Clause 4.8(9e2), Rule
            1449-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M82"/>
   <xsl:template match="@*|node()" priority="-2" mode="M82">
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueMustHaveDisplayTitle-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M83">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="ReferencedCreationTitle[@TitleType='DisplayTitle']/TitleText[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReferencedCreationTitle[@TitleType='DisplayTitle']/TitleText[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) Each Cue should have a ReferencedCreationTitle of
            type DisplayTitle (Release Profile 1.4, Clause 4.8(9e2), Rule 1450-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M83"/>
   <xsl:template match="@*|node()" priority="-2" mode="M83">
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueMustHaveContributor-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M84">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="ReferencedCreationContributor"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReferencedCreationContributor">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) Each
            Cue should have a ReferencedCreationContributor (Release Profile 1.4, Clause 4.8(9e3),
            Rule 1451-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M84"/>
   <xsl:template match="@*|node()" priority="-2" mode="M84">
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueMustHavePLine-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M85">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="PLine"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="PLine">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) Each Cue should have a PLine
            (Release Profile 1.4, Clause 4.8(9e3), Rule 1452-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M85"/>
   <xsl:template match="@*|node()" priority="-2" mode="M85">
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueMustHaveMusicalContent-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M86">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="HasMusicalContent[lower-case(text()) = 'true']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="HasMusicalContent[lower-case(text()) = 'true']">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error:
            #Longform Video) Each Cue should have a HasMusicalContent flag = True (Release Profile
            1.4, Clause 4.8(9e4), Rule 1453-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M86"/>
   <xsl:template match="@*|node()" priority="-2" mode="M86">
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CueMustHaveCLine-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M87">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="CLine"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="CLine">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform Video) Each Cue should have a CLine
            (Release Profile 1.4, Clause 4.8(9e6), Rule 1454-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M87"/>
   <xsl:template match="@*|node()" priority="-2" mode="M87">
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CollectionItemMustBeVideoChapter-->


	  <!--RULE -->
   <xsl:template match="//Collection" priority="1000" mode="M88">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Collection"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="CollectionType[text() = 'VideoChapter']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="CollectionType[text() = 'VideoChapter']">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) Each Collection item should have the CollectionType VideoChapter
            (Release Profile 1.4, Clause 4.8(10a), Rule 1455-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M88"/>
   <xsl:template match="@*|node()" priority="-2" mode="M88">
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CollectionItemMustHaveProprietaryId-->


	  <!--RULE -->
   <xsl:template match="//Collection" priority="1000" mode="M89">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Collection"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="CollectionId/ProprietaryId[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="CollectionId/ProprietaryId[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Each Collection item should have a
            Proprietary CollectionId (Release Profile 1.4, Clause 4.8(10b), Rule 1456-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M89"/>
   <xsl:template match="@*|node()" priority="-2" mode="M89">
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CollectionItemMustHaveTitle-->


	  <!--RULE -->
   <xsl:template match="//Collection" priority="1000" mode="M90">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Collection"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="Title">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Each Collection
            item should have a Title (Release Profile 1.4, Clause 4.8(10c), Rule 1457-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M90"/>
   <xsl:template match="@*|node()" priority="-2" mode="M90">
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CollectionItemMustBeComplete-->


	  <!--RULE -->
   <xsl:template match="//Collection" priority="1000" mode="M91">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Collection"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="IsComplete[lower-case(text()) = 'true']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="IsComplete[lower-case(text()) = 'true']">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error: #Longform
            Video) Each Collection item should have an IsComplete flag = True (Release Profile 1.4,
            Clause 4.8(10d), Rule 1458-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M91"/>
   <xsl:template match="@*|node()" priority="-2" mode="M91">
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>

   <!--PATTERN LongformVideo_CollectionItemMustReferencePrimaryVideo-->


	  <!--RULE -->
   <xsl:template match="//Collection/CollectionResourceReferenceList/*/CollectionResourceReference"
                 priority="1000"
                 mode="M92">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//Collection/CollectionResourceReferenceList/*/CollectionResourceReference"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="//ResourceGroupContentItem/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource' and text() = current()]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceGroupContentItem/ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource' and text() = current()]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Each Collection item should have a
            CollectionResourceReferenceList containing one reference to the Video representing the
            primary resource on the Longform release (Release Profile 1.4, Clause 4.8(10e), Rule
            1459-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M92"/>
   <xsl:template match="@*|node()" priority="-2" mode="M92">
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>

   <!--PATTERN LongformVideo_PrimaryVideoResourceMustHaveSoundRecordingCollectionReference-->


	  <!--RULE -->
   <xsl:template match="Video[ResourceReference = //ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']]/VideoCollectionReferenceList/SoundRecordingCollectionReference/SoundRecordingCollectionReference"
                 priority="1000"
                 mode="M93">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="Video[ResourceReference = //ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']]/VideoCollectionReferenceList/SoundRecordingCollectionReference/SoundRecordingCollectionReference"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="//Collection[CollectionType='VideoChapter' and CollectionReference[text() = current()]]/CollectionResourceReferenceList/*/CollectionResourceReference[text() = current()/../../../ResourceReference]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//Collection[CollectionType='VideoChapter' and CollectionReference[text() = current()]]/CollectionResourceReferenceList/*/CollectionResourceReference[text() = current()/../../../ResourceReference]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) The primary Video resource should have
            a SoundRecordingCollectionReference for each VideoChapter collection item (Release
            Profile 1.4, Clause 4.8(10g), Rule 1460-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M93"/>
   <xsl:template match="@*|node()" priority="-2" mode="M93">
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>

   <!--PATTERN LongformVideo_SoundRecordingCollectionReferenceMustHaveStartTime-->


	  <!--RULE -->
   <xsl:template match="Video[ResourceReference = //ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']]/VideoCollectionReferenceList/SoundRecordingCollectionReference"
                 priority="1000"
                 mode="M94">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="Video[ResourceReference = //ReleaseResourceReference[@ReleaseResourceType = 'PrimaryResource']]/VideoCollectionReferenceList/SoundRecordingCollectionReference"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="StartTime[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="StartTime[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error: #Longform Video) Each SoundRecordingCollectionReference
            on the primary Video resource should have a StartTime indicating the chapter start time
            on the Video (Release Profile 1.4, Clause 4.8(10h), Rule 1461-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M94"/>
   <xsl:template match="@*|node()" priority="-2" mode="M94">
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>

   <!--PATTERN MultiProfile_LabelNameMustBeProvided2-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M95">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="ReleaseDetailsByTerritory/LabelName"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReleaseDetailsByTerritory/LabelName">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error:
            #Longform Video) A LabelName has to be specified for each Release (Release Profile 1.4,
            Clause 4.13(13), Rule 1462-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M95"/>
   <xsl:template match="@*|node()" priority="-2" mode="M95">
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
</xsl:stylesheet>
