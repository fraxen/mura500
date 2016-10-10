<cfscript>
	VARIABLES.package = 'mura500';
	VARIABLES.packageVersion = '0.1';
	VARIABLES.settingsDefault = {
		Frequency: 7,
		EmailEnabled: 0,
		Email: '',
		EmailFrequency: 4,
		EmailBody: '<h1>Internal Server Error on ##CGI.SERVERNAME##</h1><cfdump var="##cgi##"><cfdump var="##url##" />',
		GntpEnabled: 0,
		GntpHost: 'localhost',
		GntpPort: 23053,
		GntpPassword: '',
		GntpIcon: 'https://github.com/fraxen/mura500/blob/master/defaulticon.png',
		LastUpdate: CreateODBCDateTime(Now() - CreateTimeSpan(365,0,0,0))
	};
	VARIABLES.default404 = {
		type: 'Page',
		active: 1,
		searchexclude: 1,
		isnav: 0,
		display: 1,
		approved: 1,
		parentid: '00000000000000000000000000000000001',
		urltitle: '404',
		summary: 'The page you are looking for might have been removed, had its name changed or is temporarily unavailable.',
		menutitle: '404',
		htmltitle: 'Page not found (404)',
		title: 'Page not found (404)',
		body: '<p><i style="float:right; font-size: 10em;" class="fa fa-exclamation-circle" aria-hidden="true"></i>The page you are looking for might have been removed, had its name changed or is temporarily unavailable.</p><ul><li>Try the navigation on this page to find the information you are looking for.</li><li>If you typed the address, make sure it is spelled correctly.</li><li>Go to the <a href="/">home page</a> of this site for more information.</li><li>Please do not hesitate to contact the webmaster if you believe there is an error that can be corrected.</li></ul>'
	}
	VARIABLES.default500 = {
		type: 'Page',
		active: 1,
		searchexclude: 1,
		isnav: 0,
		display: 1,
		urltitle: '500',
		approved: 1,
		parentid: '00000000000000000000000000000000001',
		summary: 'The link you are requesting have caused an internal server error. This might be an issue with the specific link, or there might be issues witht the server.',
		menutitle: '500',
		htmltitle: 'Server error (500)',
		title: 'Server error (500)',
		body: '<p><i style="float:right; font-size: 10em;" class="fa fa-exclamation-circle" aria-hidden="true"></i>The link you are requesting have caused an internal server error. This might be an issue with the specific link, or there might be issues witht the server.</p><p>Please try again shortly, or try any of the links below:</p><ul><li>Try the navigation on this page to find the information you are looking for.</li><li>If you typed the address, make sure it is spelled correctly.</li><li>Go to the <a href="/">home page</a> of this site for more information.</li><li>If this error continues, do not hesitate to contact the webmaster if you believe there is an error that can be corrected.</li></ul>'
	}
</cfscript>
