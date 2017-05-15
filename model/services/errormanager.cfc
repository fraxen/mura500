<cfcomponent output="false" accessors="true" extends="mura.cfobject">
	<cfproperty name="settingsService" />
	<cfproperty name="basic404" />
	<cfproperty name="basic500" />

	<cffunction name="add500headers" output="false" returnType="void" access="private">
		<cfcontent reset="true" />
		<cfheader statuscode="500" statustext="Internal Server Error" />
	</cffunction>

	<cfscript>

	private string function dumpString(d) {
		var out = '';
		savecontent variable='out' {
			WriteDump(var=ARGUMENTS.d, expand=true, format='simple', showUDFs=false);
		}
		return out;
	}

	private void function toast(site, message) {
		if (isObject(ARGUMENTS.site.gntp)) {
			ARGUMENTS.site.gntp.notify(ARGUMENTS.site.getSiteID(), ARGUMENTS.message);
		}
	}

	private void function sendmail(site, subject, body) {
		if (ARGUMENTS.site.getEmailEnabled()) {
			getBean('mailer').sendHTML(
				siteid = ARGUMENTS.site.getSiteID(),
				sendto = ARGUMENTS.site.getEmail(),
				subject = '[#ARGUMENTS.site.getSiteID()#] #ARGUMENTS.Subject#',
				html = '<h1>#ARGUMENTS.Subject#</h1>#ARGUMENTS.Body#'
			);
		}
	}

	public any function init(settingsService) {
		setSettingsService(ARGUMENTS.settingsService);
		return THIS;
	}

	public any function setup() {
		setBasic404('<html><head><title>#getSettingsService().getDefault404().Title#</title></head><body><h1>#getSettingsService().getDefault404().Title#</h1><p>#getSettingsService().getDefault404().Summary#</p></body></html>');
		setBasic500('<html><head><title>#getSettingsService().getDefault500().Title#</title></head><body><h1>#getSettingsService().getDefault500().Title#</h1><p>#getSettingsService().getDefault500().Summary#</p></body></html>');
		return THIS;
	}

	public any function forceGenerateAll() {
		for (var SiteID in getSettingsService().getSiteSettings()) {
			downloadTemplates(getSettingsService().getSiteSettings()[SiteId]);
		}
		return THIS;
	}

	public any function onSiteMonitor(SiteID) {
		if (
			getSettingsService().getSiteSettings()[ARGUMENTS.SiteId].getFrequency()
			AND
			DateDiff('d', getSettingsService().getSiteSettings()[ARGUMENTS.SiteId].getLastUpdate(), Now()) > getSettingsService().getSiteSettings()[ARGUMENTS.SiteId].getFrequency()
		) {
			downloadTemplates(getSettingsService().getSiteSettings()[ARGUMENTS.SiteId]);
		}
		return THIS;
	}

	public any function onGlobalError(required $) {
		if (!StructKeyExists(getSettingsService().getSiteSettings(), ARGUMENTS.$.event('SiteId'))) {
			return;
		}
		try{
		param name='URL.Debug' default=false;
		var site = '';
		var ex = ARGUMENTS.$.event('exception');
		WriteLog(type='ERROR', file='muraGlobalError', text='#ex.Message#');
		add500headers();
		if ( !URL.Debug && $.currentUser().isSuperUser() == 0 ) {
			if (StructKeyExists(getSettingsService().getSiteSettings(), ARGUMENTS.$.event('SiteId'))) {
				site = getSettingsService().getSiteSettings()[ARGUMENTS.$.event('SiteId')];
				toast(site, 'ERROR - MESSAGE: #ex.Message#  DETAIL: #ex.Detail#');
				include '/#Replace('#getSettingsService().getTemplateCache()##Site.getSiteID()#_500.html', ExpandPath('/'), '')#';
				if (Site.getEmailEnabled()) {
					lock name='mura500' type='exclusive' timeout=60 {
						if (
							site.getEmailFrequency()
							AND
							StructKeyExists(site.mailerCache, ex.Message)
							AND
							DateDiff('h', site.mailerCache[ex.Message].Last, Now()) < site.getEmailFrequency()
							)
						{
							site.mailerCache[ex.Message].Count = site.mailerCache[ex.Message].Count + 1;
							abort;
						}
						var sinceLast = StructKeyExists(site.mailerCache, ex.Message) ? '<p>#site.mailerCache[ex.Message].Count# since last report (#site.mailerCache[ex.Message].Last#)</p>' : '';
						sendmail(site, 'Error #ex.Message#', Evaluate(DE(site.getEmailBody())));
						if (site.getEmailFrequency()) {
							site.mailerCache[ex.Message].Count = 0;
							site.mailerCache[ex.Message].Last = Now();
						}
					}
				}
				abort;
			}
			writeOutput(getBasic500());
			abort;
		}
		}
		catch (any e) {
			// It wouldn't be good if the error handler errors out, right? 
		}
	}

	public void function downloadTemplates(required any Site, array PagesToDo=['404', '500']) {
		var request = '';
		var pages = {
			'404': {url: ARGUMENTS.Site.Url404, file: '#getSettingsService().getTemplateCache()##ARGUMENTS.Site.getSiteID()#_404.html', basic: getBasic404()},
			'500': {url: ARGUMENTS.Site.Url500, file: '#getSettingsService().getTemplateCache()##ARGUMENTS.Site.getSiteID()#_500.html', basic: getBasic500()}
		};
		lock name='mura500' type='exclusive' timeout=200 {
			for (var code in ARGUMENTS.PagesToDo) {
				try {
					pageRequest = new http()
						.setCharset('utf-8')
						.setUrl(pages[code].url)
						.send()
						.getPrefix();
					if (
						(StructKeyExists(pageRequest, 'status_code') && (pageRequest.status_code == 200 || pageRequest.status_code == code))
						||
						(StructKeyExists(pageRequest.Responseheader, 'status_code') && (pageRequest.Responseheader.status_code == 200 || pageRequest.Responseheader.status_code == code))
					) {
						fileWrite(pages[code].file, pageRequest.filecontent);
						ARGUMENTS.Site.setLastUpdate(Now());
						ARGUMENTS.Site.Save();
						sendmail(ARGUMENTS.Site, 'Downloaded #code# page', '<p><em>#pages[code].url#</em></p>');
						toast(ARGUMENTS.Site, 'Downloaded #code# page#Chr(10)##pages[code].url#');
					} else {
						throw('Error in template retrieval');
					}
				}
				catch (any e) {
					if (!fileExists(pages[code].file)) {
						fileWrite(pages[code].file, pages[code].basic);
					}
					sendmail(ARGUMENTS.Site, 'Error downloading #code# page', '#dumpString(e)#');
					toast(ARGUMENTS.Site, 'Error downloading #code# page#Chr(10)##pages[code].url#');
				}
			}
		}
	}

	private void function exportSiteInfo() {
		var SiteInfo = {};
		lock name='mura500' type='exclusive' timeout=200 {
			for (var SiteID in getSettingsService().getSiteSettings()) {
				SiteInfo[SiteId] = {
					file404 = '#SiteId#_404.html',
					file500 = '#SiteId#_500.html',
					domains = Duplicate(getSettingsService().getSiteSettings()[SiteId].domainAlias).Append(getSettingsService().getSiteSettings()[SiteId].domain)
				};
			}
			fileWrite('#getSettingsService().getTemplateCache()#siteinfo.json', SerializeJSON(SiteInfo));
			fileWrite('#getSettingsService().getTemplateCache()#basic404.html', getBasic404());
			fileWrite('#getSettingsService().getTemplateCache()#basic500.html', getBasic500());
		}
	}
</cfscript>
</cfcomponent>
