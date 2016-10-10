<cfinclude template="../config.cfm" />
<cfoutput>
	<plugin>

		<!-- Name : the name of the plugin -->
		<name>#variables.package#</name>

		<!-- Package : a unique, variable-safe name for the plugin -->
		<package>#variables.package#</package>

		<!--
			DirectoryFormat : 
			This setting controls the format of the plugin directory.
				* default : /plugins/{packageName}_{autoIncrement}/
				* packageOnly : /plugins/{packageName}/
		-->
		<directoryFormat>packageOnly</directoryFormat>

		<!-- Version : Meta information. May contain any value you wish. -->
		<version>#variables.packageVersion#</version>

		<!--
			LoadPriority : 
			Options are 1 through 10.
			Determines the order that the plugins will fire during the
			onApplicationLoad event. This allows plugins to use other
			plugins as services. This does NOT affect the order in which
			regular events are fired.
		-->
		<loadPriority>5</loadPriority>

		<!--
			Provider : 
			Meta information. The name of the creator/organization that
			developed the plugin.
		-->
		<provider>Nordpil</provider>

		<!--
			ProviderURL : 
			URL of the creator/organization that developed the plugin.
		-->
		<providerURL>https://nordpil.com</providerURL>

		<!-- Category : Usually either 'Application' or 'Utility' -->
		<category>Utility</category>

		<!--
			ORMCFCLocation : 
			May contain a list of paths where Mura should look for 
			custom ORM components.
		-->
		<!-- <ormCFCLocation>/extensions/orm</ormCFCLocation> -->

		<!-- 
			CustomTagPaths : 
			May contain a list of paths where Mura should look for
			custom tags.
		-->
		<!-- <customTagPaths></customTagPaths> -->

		<!--
			Mappings :
			Allows you to define custom mappings for use within your plugin.
		-->
		<mappings>
			<!--
			<mapping
				name="myMapping"
				directory="someDirectory/anotherDirectory" />
			-->
			<!--
				Mappings will automatically be bound to the directory
				your plugin is installed, so the above example would
				refer to: {context}/plugins/{packageName}/someDirectory/anotherDirectory/
			-->
		</mappings>

		<!--
			AutoDeploy :
			Works with Mura's plugin auto-discovery feature. If 1,
			every time Mura loads, it will look in the /plugins directory
			for new plugins and install them. If 0, or not defined,
			Mura will register the plugin with the default setting values,
			but a Super Admin will need to login and manually complete
			the deployment.
		-->
		<!-- <autoDeploy>0|1</autoDeploy> -->

		<!--
			SiteID :
			Works in conjunction with the autoDeploy attribute.
			May contain a comma-delimited list of SiteIDs that you would
			like to assign the plugin to during the autoDeploy process.
		-->
		<!-- <siteID></siteID> -->


		<!-- 
				Plugin Settings :
				The settings contain individual settings that the plugin
				requires to function.
		-->
		<settings></settings>

		<!-- Event Handlers -->
		<eventHandlers>
			<!-- only need to register the eventHandler.cfc via onApplicationLoad() -->
			<eventHandler 
					event="onApplicationLoad" 
					component="eventHandler" 
					persist="0" />
		</eventHandlers>


		<!--
			Display Objects :
			Allows developers to provide widgets that end users can apply to a
			content node's display region(s) when editing a page. They'll be
			listed under the Layout & Objects tab. The 'persist' attribute
			for CFC-based objects determine whether they are cached or instantiated
			on a per-request basis.
		-->
		<displayobjects location="global"></displayobjects>

		<!-- 
			Extensions :
			Allows you to create custom Class Extensions of any type.
			See /default/includes/themes/MuraBootstrap/config.xml.cfm
			for examples.
		-->
		<!-- <extensions></extensions> -->
		<extensions>
			<extension type="Custom" subtype="Mura500">
				<attributeset name="Mura500">
					<attribute name="Frequency" type="TextBox" validation="Numeric" defaultValue="7" />
					<attribute name="EmailEnabled" type="TextBox" validation="Numeric" defaultValue="0" />
					<attribute name="Email" type="TextBox" />
					<attribute name="EmailFrequency" type="TextBox" validation="Numeric" defaultValue="4" />
					<attribute name="EmailBody" type="TextBox" validation="Date" />
					<attribute name="GntpEnabled" type="TextBox" validation="Numeric" defaultValue="0" />
					<attribute name="GntpHost" type="TextBox" defaultValue="localhost" />
					<attribute name="GntpPort" type="TextBox" defaultValue="23053" />
					<attribute name="GntpPassword" type="TextBox" defaultValue="" />
					<attribute name="GntpIcon" type="TextBox" defaultValue="" />
					<attribute name="LastUpdate" type="TextBox" defaultValue="" />
				</attributeset>
			</extension>
		</extensions>


		<!--
			ImageSizes:
			Allows you to create pre-defined image sizes.
		-->
		<!--
		<imagesizes>
			<imagesize name="yourcustomimage" width="1200" height="600" />
		</imagesizes>
		-->
	</plugin>
</cfoutput>
