<cfscript>
component persistent="false" accessors="true" output="false" extends="mura.plugin.pluginGenericEventHandler" {
	property name='settingsService';
	property name='ErrorManagerService';

	include 'config.cfm'
	include 'config.cfm';

	public void function onSiteMonitor(required struct $) {
		getErrorManagerService().onSiteMonitor();
	}

	public void function onApplicationLoad(required struct $) {
		// register this file as a Mura eventHandler
		VARIABLES.pluginConfig.addEventHandler(this);
		setSettingsService(VARIABLES.beanFactory.getBean('SettingsService', {sites:ValueArray(pluginConfig.getAssignedSites().SiteID)}));
		setErrorManagerService(VARIABLES.beanFactory.getBean('ErrorManagerService'));
	}
	
}
</cfscript>
