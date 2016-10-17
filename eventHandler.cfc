<cfscript>
component persistent="false" accessors="true" output="false" extends="mura.plugin.pluginGenericEventHandler" {
	property name='settingsService';
	property name='ErrorManagerService';

	include 'config.cfm';

	public void function onSiteMonitor(required struct $) {
		getErrorManagerService().onSiteMonitor($.event('siteid'));
	}
	public void function onGlobalError(required struct $) {
		getErrorManagerService().onGlobalError($);
	}

	public void function onApplicationLoad(required struct $) {
		// register this file as a Mura eventHandler
		VARIABLES.pluginConfig.addEventHandler(this);
		setSettingsService(getBeanFactory().getBean('SettingsService', {sites: VARIABLES.sites}));
	}
	
}
</cfscript>
