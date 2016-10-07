<cfscript>
component persistent="false" accessors="true" output="false" {

	include '../../config/applicationSettings.cfm';
	include '../../config/mappings.cfm';
	include '../mappings.cfm';
	property name='pluginConfig';
	property name='appKey' default='mura500';

	public void function setupApplication() {
		if ( !StructKeyExists(APPLICATION, 'pluginManager') ) {
			location(url='/', addtoken=false);
		}
		setPluginConfig(APPLICATION.pluginManager.getConfig(getAppKey()));

		if (!isDefined('$')) {
			$ = getMuraScope();
		}
	}
	
	// ========================== Helper Methods ==================================

		public any function secureRequest() {
			return (StructKeyExists(SESSION, 'mura') && ListFindNoCase(SESSION.mura.memberships,'S2')) ? true :
					!StructKeyExists(SESSION, 'mura') 
					|| !StructKeyExists(SESSION, 'siteid') 
					|| !application.permUtility.getModulePerm(getFw1App().pluginConfig.getModuleID(), SESSION.siteid) 
						? goToLogin() : true;
		}

		private void function goToLogin() {
			location(url='#application.configBean.getContext()#/admin/index.cfm?muraAction=clogin.main&returnURL=#application.configBean.getContext()#/plugins/#getAppKey()#/', addtoken=false);
		}
}
</cfscript>
