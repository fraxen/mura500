<cfscript>
component displayname='notify' name='notify' accessors='true' {
	property type='string' name='GntpHost' default='localhost';
	property type='string' name='GntpPassword' default='';
	property type='string' name='GntpPort' default='23053';
	property type='string' name='GntpIcon' default='https://raw.githubusercontent.com/fraxen/cfcgntp/master/gntp.png';
	property type='string' name='Application' default='CFML server';
	VARIABLES.gc = '';
	VARIABLES.app = '';
	VARIABLES.ntype = '';

	public any function init(GntpHost=getGntpHost(), GntpPassword=getGntpPassword(), GntpPort=getGntpPort(), GntpIcon=getGntpIcon(), Application=getApplication()) {
		setGntpHost(ARGUMENTS.GntpHost);
		setGntpPassword(ARGUMENTS.GntpPassword);
		setGntpPort(ARGUMENTS.GntpPort);
		setGntpIcon(ARGUMENTS.GntpIcon);
		setApplication(ARGUMENTS.Application);
		if (ARGUMENTS.Application == '' && (isObject(APPLICATION) || IsStruct(APPLICATION))) {
			setApplication(APPLICATION.applicationname);
		}
		try {
			VARIABLES.gc = createObject('java', 'net.sf.libgrowl.GrowlConnector').init(getGntpHost(), getGntpPort());
			VARIABLES.app = createObject('java', 'net.sf.libgrowl.Application').init(getApplication(), getGntpIcon());
			VARIABLES.ntype = createObject('java', 'net.sf.libgrowl.NotificationType').init('message');
			VARIABLES.gc.setPassword(getGntpPassword());
			VARIABLES.gc.register(VARIABLES.app, [VARIABLES.ntype]);
		}
		catch(any e) {
			// seems like instantiation didn't work...
		}
		return THIS;
	}

	public boolean function notify(string title=getApplication(), string message='', string icon=getGntpIcon(), any priority=0, boolean sticky=false) {
		var note = '';
		if (isObject(VARIABLES.gc)) {
			var note = createObject('java', 'net.sf.libgrowl.Notification').init(VARIABLES.app, VARIABLES.ntype, ARGUMENTS.Title, ARGUMENTS.message);
			note.setPriority(ARGUMENTS.priority);
			note.setSticky(ARGUMENTS.sticky);
			note.setIcon(ARGUMENTS.icon);
			VARIABLES.gc.notify(note);
			return true;
		}
		return false;
	}
}
</cfscript>

