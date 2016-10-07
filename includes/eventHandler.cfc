<cfscript>
/*

This file was modified from MuraFW1
Copyright 2010-2014 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
https://github.com/stevewithington/MuraFW1

*/
component persistent="false" accessors="true" output="false" extends="mura.plugin.pluginGenericEventHandler" {

	public void function onSiteMonitor(required struct $) {
	}

	public void function onApplicationLoad(required struct $) {
		lock scope='application' type='exclusive' timeout=30 {
			new mura500.Application.onApplicationStart();
		};

		// register this file as a Mura eventHandler
		variables.pluginConfig.addEventHandler(this);
	}
	
}
</cfscript>
