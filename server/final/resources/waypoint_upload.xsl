<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<display_list>
  <xsl:for-each select="//Placemark">
	<xsl:variable name="placemarkname" select="name/text()"/>
	<xsl:choose>
	<xsl:when test="./Point/coordinates">
	  <display>
		<style><xsl:value-of select="styleUrl" /></style>
		<address><xsl:value-of select="name" /></address>
		<description><xsl:value-of select="description" /></description>
		<coordinates><xsl:value-of select="Point/coordinates" /></coordinates>
	  </display>
	</xsl:when>
	<xsl:when test="./Polygon/outerBoundaryIs/LinearRing/coordinates">
	  <polygon>
		<name><xsl:copy-of select="$placemarkname" /></name>
		<coordinates><xsl:value-of select="Polygon/outerBoundaryIs/LinearRing/coordinates" /></coordinates>
	  </polygon>
	</xsl:when>
	</xsl:choose>
  </xsl:for-each>
</display_list>
</xsl:template>
</xsl:stylesheet>
