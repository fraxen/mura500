<cfparam name="URL.debug" default="false" />
<cftry>
	<!--- Snippet from https://gist.github.com/stevewithington/5396717 --->
	<cfset msg = 'MURA ERROR - MESSAGE: #arguments.exception.Message#  DETAIL: #arguments.exception.Detail# ' />
	<cflog type="ERROR" file="MuraError" text="#msg#" />
	<cfcatch></cfcatch>
</cftry>
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
