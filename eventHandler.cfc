<cfscript>
component persistent="false" accessors="true" output="false" extends="mura.plugin.pluginGenericEventHandler" {
	property name='notifyService';
	property name='settingsService';

	include 'config.cfm'

	public void function onSiteMonitor(required struct $) {
	}

	public void function onApplicationLoad(required struct $) {
		// register this file as a Mura eventHandler
		VARIABLES.pluginConfig.addEventHandler(this);
		setNotifyService(new model.services.notify());
		setSettingsService(new model.services.settings(ValueArray(pluginConfig.getAssignedSites().SiteID)));
		getNotifyService().notify(CGI.SERVER_NAME, ValueList(pluginConfig.getAssignedSites().SiteID))
	}
	
}
</cfscript>
