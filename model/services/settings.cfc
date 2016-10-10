<cfscript>
component persistent="false" accessors="true" output="false" extends='mura.cfobject' {
	property name='sites' type='array';
	property name='siteSettings' type='struct';
	include '../../config.cfm';

	private array function arrayUnique(inArray) {
		return StructKeyArray(
			ARGUMENTS.inArray.reduce(function(carry,i) {
				return carry.insert(i,1);
			}, {})
		);
	}

	public any function init(sites) {
		var ss = {};
		var adminEmail = ValueArray(queryExecute("SELECT * FROM tusers WHERE s2 = 1").Email);
		setSites(ARGUMENTS.sites);
		getSites().each(function(SiteId) {
			var settings = new mura.extend.extendObject().loadBy(
				type: 'Custom',
				subtype: 'Mura500',
				SiteId: SiteId,
				id: SiteId
			);
			var siteConfig = APPLICATION.serviceFactory.getBean('muraScope').init(siteId).siteConfig();
			if (!isDate(settings.getLastUpdate())) {
				settings.set({
					SiteId: SiteId,
					id: SiteId,
					isnew: 0,
					Frequency: VARIABLES.settingsDefault.Frequency,
					EmailEnabled: VARIABLES.settingsDefault.EmailEnabled,
					Email: ArrayToList(
						Duplicate(adminEmail)
							.Append(siteConfig.getContactEmail())
							.Append(VARIABLES.settingsDefault.Email)
					),
					EmailFrequency: VARIABLES.settingsDefault.EmailFrequency,
					EmailBody: VARIABLES.settingsDefault.EmailBody,
					GntpEnabled: VARIABLES.settingsDefault.GntpEnabled,
					GntpHost: VARIABLES.settingsDefault.GntpHost,
					GntpPort: VARIABLES.settingsDefault.GntpPort,
					GntpPassword: VARIABLES.settingsDefault.GntpPassword,
					GntpIcon: VARIABLES.settingsDefault.GntpIcon,
					LastUpdate: VARIABLES.settingsDefault.LastUpdate,
				});
				settings.save();
			}
			settings.domain = siteConfig.getDomain();
			settings.domainAlias = siteConfig.getDomainAlias();
			var page404 = getBean('content').loadBy(filename='404', siteid=SiteId);
			if (page404.getIsNew()) {
				page404.set(VARIABLES.default404).save();
			}
			var page500 = getBean('content').loadBy(filename='500', siteid=SiteId);
			if (page500.getIsNew()) {
				page500.set(VARIABLES.default500).save();
			}
			ss.Insert(SiteId, settings);
		});
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
