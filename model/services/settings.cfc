<cfscript>
component persistent="false" accessors="true" output="false" extends='mura.cfobject' {
	property name='sites' type='array';
	property name='siteSettings' type='struct';
	property name='settingsDefault' type='struct';
	property name='default404' type='struct';
	property name='default500' type='struct';
	property name='templateCache' type='string';
	property name='hasGNTP' type='boolean';
	property name='errorManagerService';

	private array function arrayUnique(inArray) {
		return StructKeyArray(
			ARGUMENTS.inArray.reduce(function(carry,i) {
				return carry.insert(i,1);
			}, {})
		);
	}

	public any function init(required sites, required settingsDefault, required default404, required default500, required templateCache, required hasGNTP) {
		setSites(ARGUMENTS.sites);
		setSettingsDefault(ARGUMENTS.settingsDefault);
		setDefault404(ARGUMENTS.default404);
		setDefault500(ARGUMENTS.default500);
		setTemplateCache(ARGUMENTS.templateCache);
		setHasGntp(ARGUMENTS.hasGNTP);
		return THIS;
	}

	public any function setup() {
		var ss = {};
		var adminEmail = [];
		getErrorManagerService().setup();
		var thisEmail = [];
		for (var a in new Query(sql="SELECT * FROM tusers WHERE s2 = 1").execute().getResult()) {
			ArrayAppend(adminEmail, a.Email);
		}
		for (var SiteID in getSiteS()) {
			var settings = new mura.extend.extendObject().loadBy(
				type: 'Custom',
				subtype: 'Mura500',
				SiteId: SiteId,
				id: SiteId
			);
			var siteConfig = APPLICATION.serviceFactory.getBean('muraScope').init(siteId).siteConfig();
			settings.setIsNew(!isDate(settings.getLastUpdate()));
			if (settings.getIsNew()) {
				thisEmail = Duplicate(adminEmail);
				if (siteConfig.getContactEmail() != '') {
					ArrayAppend(thisEmail, siteConfig.getContactEmail());
				}
				if (getSettingsDefault().Email != '') {
					ArrayAppend(thisEmail, getSettingsDefault().Email);
				}
				settings.set({
					SiteId: SiteId,
					id: SiteId,
					Frequency: getSettingsDefault().Frequency,
					EmailEnabled: getSettingsDefault().EmailEnabled,
					Email: ArrayToList(thisEmail),
					EmailFrequency: getSettingsDefault().EmailFrequency,
					EmailBody: getSettingsDefault().EmailBody,
					GntpEnabled: getSettingsDefault().GntpEnabled && getHasGntp(),
					GntpHost: getSettingsDefault().GntpHost,
					GntpPort: getSettingsDefault().GntpPort,
					GntpPassword: getSettingsDefault().GntpPassword,
					GntpIcon: getSettingsDefault().GntpIcon,
					LastUpdate: getSettingsDefault().LastUpdate
				});
				settings.save();
			}
			settings.domain = siteConfig.getDomain();
			settings.domainAlias = ListToArray(siteConfig.getDomainAlias(), '#Chr(13)##Chr(10)#');
			settings.fromAddress = siteConfig.getContact();
			settings.gntp = {};
			if (settings.getGntpEnabled() && getHasGntp()) {
				settings.gntp = new mura500.model.beans.notify(
					GntpHost: settings.getGntpHost(),
					GntpPort: settings.getGntpPort(),
					GntpPassword: settings.getGntpPassword(),
					GntpIcon: settings.getGntpIcon()
				);
			}
			settings.mailerCache = {};
			var page404 = getBean('content').loadBy(filename='404', siteid=SiteId);
			if (page404.getIsNew()) {
				page404.set(VARIABLES.default404).save();
			}
			var page500 = getBean('content').loadBy(filename='500', siteid=SiteId);
			if (page500.getIsNew()) {
				page500.set(VARIABLES.default500).save();
			}
			settings.Url404 = siteConfig.getContentRenderer().$.CreateHref(filename=page404.getFilename(), siteid=SiteId, complete=true);
			settings.Url500 = siteConfig.getContentRenderer().$.CreateHref(filename=page500.getFilename(), siteid=SiteId, complete=true);
			if (!FileExists('#getTemplateCache()##settings.getSiteID()#_404.html')) {
				getErrorManagerService().downloadTemplates(settings, ['404']);
			}
			if (!FileExists('#getTemplateCache()##settings.getSiteID()#_500.html')) {
				getErrorManagerService().downloadTemplates(settings, ['500']);
			}
			StructInsert(ss, SiteId, settings);
		}
		setSiteSettings(ss);
		return THIS;
	}

	public any function updateSite(required string SiteId, required struct settingValues) {
		var thisSite = VARIABLES.SiteSettings[ARGUMENTS.SiteID];
		thisSite.set(ARGUMENTS.settingValues);
		thisSite.save();
	}
}
</cfscript>
