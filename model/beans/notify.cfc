<cfscript>
component displayname='notify' name='notify' accessors='true' {
	property type='string' name='GntpHost' default='localhost';
	property type='string' name='GntpPassword' default='';
	property type='string' name='GntpPort' default='23053';
	property type='string' name='GntpIcon' default='https://raw.githubusercontent.com/fraxen/cfcgntp/master/gntp.png';
	VARIABLES.gntp = '';

	public any function init(GntpHost=getGntpHost(), GntpPassword=getGntpPassword(), GntpPort=getGntpPort(), GntpIcon=getGntpIcon()) {
		setGntpHost(ARGUMENTS.GntpHost);
		setGntpPassword(ARGUMENTS.GntpPassword);
		setGntpPort(ARGUMENTS.GntpPort);
		setGntpIcon(ARGUMENTS.GntpIcon);
		return THIS;
	}

	public any function setup() {
		VARIABLES.gntp = new com.nordpil.cfcgntp.gntp(host=getGntpHost(), password=getGntpPassword(), port=getGntpPort(), icon=getGntpIcon(), app='Mura500');
	}

	public void function notify(required string title, required string message, string icon=getGntpIcon()) {
		if (!isObject(VARIABLES.gntp)) {
			VARIABLES.gntp = new com.nordpil.cfcgntp.gntp(host=getGntpHost(), password=getGntpPassword(), port=getGntpPort(), icon=getGntpIcon());
		}
		VARIABLES.gntp.notify(ARGUMENTS.title, ARGUMENTS.message, ARGUMENTS.icon);
	}
}
</cfscript>

