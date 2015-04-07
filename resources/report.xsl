<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
    <style>
        tr>td{
            font-family:Arial   ;
            font-weight:normal;
            font-size:14px;
            padding:4px;
        }
        .cell_error{
            background:#FE3333;
            color:white;
        }
        .cell_info{
            background:#DDEEFF;
            color:#333333;
        }
        .cell_warning{
            background:#FEEC99;
        }
        .cell_default{
            background:#FFFFFF;
        }
    </style>
  <body>
    <table border="1" cellspacing="0">
        <tr style="background-color: green; color: white;">
            <th>File</th>
            <th>Line</th>
            <th>Column</th>
            <th>Severity</th>
            <th>Message</th>
        </tr>
        <xsl:for-each select="checkstyle/file/error">
            
                <xsl:choose>
                      <xsl:when test="@severity = 'error'">
                        <tr class="cell_error">
                            <td>
                                <xsl:value-of select="@source"/>
                            </td>
                            <td>
                                <xsl:value-of select="@line"/>
                            </td>
                            <td>
                                <xsl:value-of select="@column"/>
                            </td>
                            <td>
                                <xsl:value-of select="@severity"/>
                            </td>
                            <td>
                                <xsl:value-of select="@message"/>
                            </td>
                        </tr>
                      </xsl:when>

                      <xsl:when test="@severity = 'info'">
                        <tr class="cell_info">
                            <td>
                                <xsl:value-of select="@source"/>
                            </td>
                            <td>
                                <xsl:value-of select="@line"/>
                            </td>
                            <td>
                                <xsl:value-of select="@column"/>
                            </td>
                            <td>
                                <xsl:value-of select="@severity"/>
                            </td>
                            <td>
                                <xsl:value-of select="@message"/>
                            </td>
                        </tr>
                      </xsl:when>

                      <xsl:when test="@severity = 'warning'">
                        <tr class="cell_warning">
                            <td>
                                <xsl:value-of select="@source"/>
                            </td>
                            <td>
                                <xsl:value-of select="@line"/>
                            </td>
                            <td>
                                <xsl:value-of select="@column"/>
                            </td>
                            <td>
                                <xsl:value-of select="@severity"/>
                            </td>
                            <td>
                                <xsl:value-of select="@message"/>
                            </td>
                        </tr>
                      </xsl:when>

                      <xsl:otherwise>
                        <tr class="cell_default">
                            <td>
                                <xsl:value-of select="@source"/>
                            </td>
                            <td>
                                <xsl:value-of select="@line"/>
                            </td>
                            <td>
                                <xsl:value-of select="@column"/>
                            </td>
                            <td>
                                <xsl:value-of select="@severity"/>
                            </td>
                            <td>
                                <xsl:value-of select="@message"/>
                            </td>
                        </tr>
                      </xsl:otherwise>
                </xsl:choose>

        </xsl:for-each>


<!--         <xsl:for-each select="checkstyle/file/error[@severity='info']">
            <tr>
                <td bgcolor="#FEDEFF">
                    <xsl:value-of select="@source"/>
                </td>

                <td>
                    <xsl:value-of select="@line"/>
                </td>
                <td>
                    <xsl:value-of select="@column"/>
                </td>
                <td>
                    <xsl:value-of select="@severity"/>
                </td>
                <td>
                    <xsl:value-of select="@message"/>
                </td>
            </tr>
        </xsl:for-each>


        <xsl:for-each select="checkstyle/file/error[@severity='warning']">
            <tr>
                <td bgcolor="#FE66FE">
                    <xsl:value-of select="@source"/>
                </td>

                <td>
                    <xsl:value-of select="@line"/>
                </td>
                <td>
                    <xsl:value-of select="@column"/>
                </td>
                <td>
                    <xsl:value-of select="@severity"/>
                </td>
                <td>
                    <xsl:value-of select="@message"/>
                </td>
            </tr>
        </xsl:for-each> -->

    </table>


  </body>
  </html>
</xsl:template>


</xsl:stylesheet>