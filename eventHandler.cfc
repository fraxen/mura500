<cfscript>
component persistent="false" accessors="true" output="false" extends="mura.plugin.pluginGenericEventHandler" {
	property name='notifyService';
	include '../config.cfm'

	public void function onSiteMonitor(required struct $) {
	}

	public void function onApplicationLoad(required struct $) {
		// register this file as a Mura eventHandler
		variables.pluginConfig.addEventHandler(this);
		setNotifyService(new model.services.notify());
		getNotifyService().notify(CGI.SERVER_NAME, 'kukballe')
	}
	
}
</cfscript>
