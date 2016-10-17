<cfscript>
component persistent="false" accessors="true" output="false" extends='mura.cfobject' {
	property name='sites' type='array';
	property name='beanFactory';
	property name='siteSettings' type='struct';
	property name='settingsDefault' type='struct';
	property name='default404' type='struct';
	property name='default500' type='struct';
	property name='templateCache' type='string';
	property name='hasGNTP' type='boolean';

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
		var adminEmail = ValueArray(queryExecute("SELECT * FROM tusers WHERE s2 = 1").Email);
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
					Frequency: getsettingsDefault().Frequency,
					EmailEnabled: getsettingsDefault().EmailEnabled,
					Email: ArrayToList(
						Duplicate(adminEmail)
							.Append(siteConfig.getContactEmail())
							.Append(getsettingsDefault().Email)
					),
					EmailFrequency: getsettingsDefault().EmailFrequency,
					EmailBody: getsettingsDefault().EmailBody,
					GntpEnabled: getsettingsDefault().GntpEnabled,
					GntpHost: getsettingsDefault().GntpHost,
					GntpPort: getsettingsDefault().GntpPort,
					GntpPassword: getsettingsDefault().GntpPassword,
					GntpIcon: getsettingsDefault().GntpIcon,
					LastUpdate: getsettingsDefault().LastUpdate,
				});
				settings.save();
			}
			settings.domain = siteConfig.getDomain();
			settings.domainAlias = ListToArray(siteConfig.getDomainAlias(), '#Chr(13)##Chr(10)#');
			settings.fromAddress = siteConfig.getContact();
			settings.gntp = {};
			if (settings.getGntpEnabled() && getHasGntp()) {
				settings.gntp = getBeanFactory().getBean('notify', {
					GntpHost: settings.getGntpHost(),
					GntpPort: settings.getGntpPort(),
					GntpPassword: settings.getGntpPassword(),
					GntpIcon: settings.getGntpIcon()
				});
			}
			settings.notify = function(message, siteId=settings.getSiteID(), gntp=settings.gntp) {
				if (isObject(ARGUMENTS.gntp)) {
					ARGUMENTS.gntp.notify(ARGUMENTS.siteid, ARGUMENTS.message);
				}
			}
			settings.mailer = function(subject, body, SiteId=settings.getSiteID(), sendto=settings.getEmail(), emailenabled=settings.getEmailEnabled()) {
				if (ARGUMENTS.EmailEnabled) {
					getBean('mailer').sendHTML(
						siteid = ARGUMENTS.SiteId,
						sendto = ARGUMENTS.sendto,
						subject = '[#ARGUMENTS.SiteId#] #ARGUMENTS.Subject#',
						html = '<h1>#ARGUMENTS.Subject#</h1>#ARGUMENTS.Body#'
					);
				}
			}
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
