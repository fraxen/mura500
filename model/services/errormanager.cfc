<cfscript>
component persistent="false" accessors="true" output="false" extends='mura.cfobject' {
	property name='beanFactory';
	property name='settingsService';
	property name='basic404';
	property name='basic500';

	private string function dumpString(d) {
		var out = '';
		savecontent variable='out' {
			WriteDump(ARGUMENTS.d, true);
		}
		return out;
	}

	public any function setup() {
		setBasic404('<html><head><title>#getSettingsService().getDefault404().Title#</title></head><body><h1>#getSettingsService().getDefault404().Title#</h1><p>#getSettingsService().getDefault404().Summary#</p></body></html>');
		setBasic500('<html><head><title>#getSettingsService().getDefault500().Title#</title></head><body><h1>#getSettingsService().getDefault500().Title#</h1><p>#getSettingsService().getDefault500().Summary#</p></body></html>');
	}

	public any function forceGenerateAll() {
		for (var SiteID in getSettingsService().getSiteSettings()) {
			downloadTemplates(getSettingsService().getSiteSettings()[SiteId]);
		}
		return THIS;
	}

	public any function onSiteMonitor() {
		for (var SiteId in getSettingsService().getSiteSettings()) {
			if (
				getSettingsService().getSiteSettings()[SiteId].getFrequency()
				AND
				DateDiff('d', getSettingsService().getSiteSettings()[SiteId].getLastUpdate(), Now()) > getSettingsService().getSiteSettings()[SiteId].getFrequency()
			) {
				downloadTemplates(getSettingsService().getSiteSettings()[SiteId]);
			}
		}
		return THIS;
	}

	private void function downloadTemplates(Site) {
		var request = '';
		var pages = {
			'404': {url: ARGUMENTS.Site.Url404, file: '#getSettingsService().getTemplateCache()##ARGUMENTS.Site.getSiteID()#_404.html', basic: getBasic404()},
			'500': {url: ARGUMENTS.Site.Url500, file: '#getSettingsService().getTemplateCache()##ARGUMENTS.Site.getSiteID()#_500.html', basic: getBasic500()}
		};
		lock scope='application' type='exclusive' timeout=200 {
			for (var code in pages) {
				try {
					pageRequest = new http()
						.setCharset('utf-8')
						.setUrl(pages[code].url)
						.send()
						.getPrefix();
					if (pageRequest.status_code == 200) {
						fileWrite(pages[code].file, pageRequest.filecontent);
						ARGUMENTS.Site.setLastUpdate(Now());
						ARGUMENTS.Site.Save();
						ARGUMENTS.Site.mailer('Downloaded #code# page', '<p><em>#pages[code].url#</em></p>');
						ARGUMENTS.Site.notify('Downloaded #code# page#Chr(10)##pages[code].url#');
					} else {
						throw('Error in template retrieval');
					}
				}
				catch (any e) {
					if (!fileExists(pages[code].file)) {
						fileWrite(pages[code].file, pages[code].basic);
					}
					ARGUMENTS.Site.mailer('Error downloading #code# page', '#dumpString(e)#');
					ARGUMENTS.Site.notify('Error downloading #code# page#Chr(10)##pages[code].url#');
				}
			}
		}
	}

	private void function exportSiteInfo() {
		var SiteInfo = {};
		lock scope='application' type='exclusive' timeout=200 {
			for (var SiteID in getSettingsService().getSiteSettings()) {
				SiteInfo[SiteId] = {
					file404 = '#SiteId#_404.html',
					file500 = '#SiteId#_500.html',
					domains = Duplicate(getSettingsService().getSiteSettings()[SiteId].domainAlias).Append(getSettingsService().getSiteSettings()[SiteId].domain)
				}
			}
			fileWrite('#getSettingsService().getTemplateCache()#/siteinfo.json', SerializeJSON(SiteInfo));
			fileWrite('#getSettingsService().getTemplateCache()#/basic404.html', getBasic404());
			fileWrite('#getSettingsService().getTemplateCache()#/basic500.html', getBasic500());
		}
	}

}
</cfscript>
