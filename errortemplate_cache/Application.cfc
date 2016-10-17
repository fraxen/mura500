<cfscript>
	component accessors='true' output='false' {

		THIS.name = 'errortemplates';
		THIS.applicationTimeout = CreateTimeSpan(0,0,30,0);
		// THIS.applicationTimeout = CreateTimeSpan(0,0,0,1);
		THIS.sessionManagement = false;
		APPLICATION.SiteInfo = {};

		public void function onApplicationStart() {
			lock scope='application' type='exclusive' timeout=10 {
				if (fileExists('siteinfo.json')) {
					APPLICATION.SiteInfo = DeserializeJSON(fileRead('siteinfo.json'));
				}
				for (var SiteID in APPLICATION.SiteInfo) {
					if(!fileExists(APPLICATION.SiteInfo[SiteID].File404)) {
						APPLICATION.SiteInfo[SiteID].File404 = 'basic404.html';
					}
					if(!fileExists(APPLICATION.SiteInfo[SiteID].File500)) {
						APPLICATION.SiteInfo[SiteID].File500 = 'basic500.html';
					}
				}
			}
		}

		public void function OnRequestStart(REQUEST) {
			REQUEST.host = listFirst(CGI.Http_Host, ":");
			if (!Len(REQUEST.host)) {
				REQUEST.host = CGI.Server_Name;
			}
			REQUEST.site = {file404: 'basic404.html', File500: 'basic500.html'};
			if (Len(StructKeyArray(APPLICATION.SiteInfo))) {
				for (var SiteID in APPLICATION.SiteInfo) {
					if (ArrayFindNoCase(APPLICATION.SiteInfo[SiteId].Domains, REQUEST.Host)) {
						REQUEST.site = APPLICATION.SiteInfo[SiteId];
						break;
					}
				}
			}
		}
	}
</cfscript>

