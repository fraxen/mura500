<cfparam name="URL.debug" default="false" />
<cfif URL.debug>
	<cftry>
		<cfdump var="#arguments#" />
	</cftry>
	<cfcatch></cfcatch>
	<cfabort />
	<cfdump var="#CGI#" />
<cfelse>
	<cfheader statusCode="500" statusText="Internal Server Error">
	<cfcontent reset="true" />
	<cfinclude template="#REQUEST.Site.File500#" />
	<cfabort />
</cfif>
