<cfheader statusCode="404" statusText="Not Found">
<cfcontent reset="true" />
<cfinclude template="#REQUEST.Site.File404#" />
