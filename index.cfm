<cfscript>
	include 'config.cfm'
	// This is a bit ugly, one monolithic file, but oh well!

	// {{{ Initialization
	if ( !IsDefined('$')) {
		$ = application.serviceFactory.getBean('muraScope').init('default');
	}
	if ( !IsDefined('pluginConfig') ) {
		pluginConfig = $.getPlugin('mura500');
	}

	if (!$.currentUser().getS2()) {
		location(
			url='#application.configBean.getContext()#/admin/index.cfm?muraAction=clogin.main&returnURL=#application.configBean.getContext()#/plugins/mura500/',
			addtoken=false
		);
	}

	sites = pluginConfig.getAssignedSites()
		.reduce(function(carry,s) {
			var settings = new mura.extend.extendObject().loadBy(
					type: 'Custom',
					subtype: 'Mura500',
					SiteId: s.SiteId,
					id: s.SiteId
				);
			if (settings.getIsNew()) {
				settings.set({
					SiteId: s.SiteId,
					id: s.SiteId,
					Frequency: 7,
					EmailEnabled: 0,
					Email: '',
					EmailFrequency: 4,
					EmailBody: '',
					GntpEnabled: 0,
					GntpHost: 'localhost',
					GntpPort: 23053,
					GntpPassword: '',
					GntpIcon: ''
				});
			}
			return carry.insert(s.SiteId, settings);
		}, {});
	// }}}
</cfscript>

<!--- {{{ OUTPUT FORM --->

<!--- {{{ STYLE --->
<cfhtmlhead>
	<style type="text/css">
		#configedit legend {FONT-WEIGHT: Bold; WIDTH: auto; BORDER: 0; PADDING: 0.2em; MARGIN: 0;}
		#configedit fieldset {PADDING: 1em;}
		#configedit dl {CLEAR: Both; PADDING: 2%; WIDTH: 100%;}
		#configedit dd {FLOAT: Left; WIDTH: 30%;}
		#configedit dt {FLOAT: Left; WIDTH: 64%;}
		#configedit input[type=text], #configedit textarea {WIDTH: 100%;}
	</style>
</cfhtmlhead>
<!--- }}} --->

<!--- {{{ BODY --->
<cfoutput>
<cfsavecontent variable="body">
	<h2>Mura500 configuration</h2>
	<div>(instructions/intro TODO)</div>
	<cfif !Len(StructKeyArray(sites))>
		<div><em>Plugin is not enabled for any sites yet</em></div>
	<cfelse>
	<br/>
	<input type="submit" class="btn btn-default" value="Generate error templates now" style="WIDTH: 100%;" />
	<br/><br/>
	<form method="post" id="configedit" name="mura500" action="#application.configBean.getContext()#/plugins/mura500/">
		<cfloop index="SiteId" struct="#sites#">
			<fieldset name="site#SiteId#" id="site#SiteId#">
				<legend>#SiteId#</legend>
				<dl>
					<dd><label for="#SiteId#_frequency">Update frequency (days)<br />(creating static error pages)<br/><em>Set to 0 to only do manual</em></label></dd>
					<dt><input type="text" name="#SiteId#_frequency" id="#SiteId#_frequency" value="#sites[SiteId].getFrequency()#" placeholder="Update frequency (days)" /></dt>
				</dl>
				<dl>
					<dd><label for="#SiteId#_emailenabled">Email of error reports</label></dd>
					<dt><input type="checkbox" name="#SiteId#_emailenabled" id="#SiteId#_emailenabled" value="1" <cfif sites[SiteId].getEmailEnabled()>checked="checked"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteId#_emailfrequency">Email frequency (hours)<br />(prevents duplicate reports/emails)<br/><em>Set to 0 to send all</em></label></dd>
					<dt><input type="text" name="#SiteId#_emailfrequency" id="#SiteId#_emailfrequency" value="#sites[SiteId].getEmailFrequency()#" placeholder="Email frequency (hours)" <cfif !sites[SiteId].getEmailEnabled()>disabled="disabled"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteId#_email">Email sendlist<br /><em>Comma-separated for multiple addresses</em></label></dd>
					<dt><input type="text" name="#SiteId#_email" id="#SiteId#_email" value="#sites[SiteId].getEmail()#" placeholder="Email sendlist" <cfif !sites[SiteId].getEmailEnabled()>disabled="disabled"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteId#_emailbody">Email body<br /><em>cfml is ok</em></label></dd>
					<dt>
						<textarea name="#SiteId#_emailbody" id="#SiteId#_emailbody" placeholder="Email body" <cfif !sites[SiteId].getEmailEnabled()>disabled="disabled"</cfif>>#sites[SiteId].getEmailBody()#</textarea>
					</dt>
				</dl>
				<dl>
					<dd><label for="#SiteID#_gntpenabled">GNTP (growl) notifications</label</dd>
					<dt><input type="checkbox" name="#SiteId#_gntpenabled" id="#SiteId#_gntpenabled" value="1" <cfif sites[SiteId].getGntpEnabled()>checked="checked"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteID#_gntphost">GNTP host</label</dd>
					<dt><input type="text" name="#SiteId#_gntphost" id="#SiteId#_gntphost" value="#sites[SiteId].getGntpHost()#" placeholder="hostname for GNTP" <cfif !sites[SiteId].getGntpEnabled()>disabled="disabled"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteID#_gntpport">GNTP port</label</dd>
					<dt><input type="text" name="#SiteId#_gntpport" id="#SiteId#_gntpport" value="#sites[SiteId].getGntpPort()#" placeholder="network port for GNTP" <cfif !sites[SiteId].getGntpEnabled()>disabled="disabled"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteID#_gntppassword">GNTP password</label</dd>
					<dt><input type="text" name="#SiteId#_gntppassword" id="#SiteId#_gntppassword" value="#sites[SiteId].getGntpPassword()#" placeholder="password for GNTP" <cfif !sites[SiteId].getGntpEnabled()>disabled="disabled"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteID#_gntpicon">Icon for notifications<br /><em>A valid full URL</em></label</dd>
					<dt><input type="text" name="#SiteId#_gntpicon" id="#SiteId#_gntpicon" value="#sites[SiteId].getGntpIcon()#" placeholder="Icon url for GNTP" <cfif !sites[SiteId].getGntpEnabled()>disabled="disabled"</cfif>/></dt>
				</dl>
			</fieldset>
		</cfloop>
		<br /><input type="submit" class="btn btn-default" value="Update configuration" style="WIDTH: 100%;" />
	</form>
	</cfif>
</cfsavecontent>
<!--- }}} --->

#$.getBean('pluginManager').renderAdminTemplate(
	body: body,
	pageTitle: pluginConfig.getName(),
	jsLib: 'jquery',
	jsLibLoaded: true
)#
<script type="text/javascript">
	<cfloop index="SiteId" struct="#sites#">
		$('###SiteID#_emailenabled').change(function() {
			$('###SiteID#_email').prop('disabled', !$(this).is(':checked'));
			$('###SiteID#_emailbody').prop('disabled', !$(this).is(':checked'));
			$('###SiteID#_emailfrequency').prop('disabled', !$(this).is(':checked'));
		});
		$('###SiteID#_gntpenabled').change(function() {
			$('###SiteID#_gntphost').prop('disabled', !$(this).is(':checked'));
			$('###SiteID#_gntpport').prop('disabled', !$(this).is(':checked'));
			$('###SiteID#_gntppassword').prop('disabled', !$(this).is(':checked'));
			$('###SiteID#_gntpicon').prop('disabled', !$(this).is(':checked'));
		});
	</cfloop>
</script>
</cfoutput>
<!--- }}} --->