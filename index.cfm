<cfscript>
	include 'config.cfm';
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

	getSettingsService = function() { return VARIABLES.SettingsService;};
	getErrorManagerService = function() { return VARIABLES.ErrorManagerService;};

	siteSettings = getSettingsService().getSiteSettings();

	relErrorCache = '/#Replace(Replace(getSettingsService().getTemplateCache(), ExpandPath('/'), ''), '\', '/', 'ALL')#';

	// }}}

	// {{{ Handle actions
	if (StructKeyExists(URL, 'action') && URL.action == 'update') {
		for (SiteId in siteSettings) {
			SiteVals = {};
			if (!StructKeyExists(FORM, '#SiteID#_EmailEnabled')) {
				FORM['#SiteID#_EmailEnabled'] = 0;
			}
			if (!StructKeyExists(FORM, '#SiteID#_GntpEnabled')) {
				FORM['#SiteID#_GntpEnabled'] = 0;
			}
			for (f in StructKeyArray(FORM)) {
				if (!REFindNoCase('^#SiteID#', f)) { continue; }
				StructInsert(SiteVals, REReplaceNoCase(f, '#SiteID#_', ''), Form[f]);
			}
			getSettingsService().updateSite(SiteID, siteVals);
		}
		location(url='#application.configBean.getContext()#/plugins/mura500/', addtoken=false);
	}
	if (StructKeyExists(URL, 'action') && URL.action == 'generate') {
		getErrorManagerService().forceGenerateAll();
		location(url='#application.configBean.getContext()#/plugins/mura500/', addtoken=false);
	}
	// }}}
</cfscript>

<!--- {{{ OUTPUT FORM --->

<!--- {{{ STYLE --->
<cfsavecontent variable="head">
	<style type="text/css">
		#configedit legend {FONT-WEIGHT: Bold; WIDTH: auto; BORDER: 0; PADDING: 0.2em; MARGIN: 0;}
		#configedit fieldset {PADDING: 1em;}
		#configedit dl {CLEAR: Both; PADDING: 0.2em 2% 0.2em 2%; WIDTH: 98%; MARGIN: 0; DISPLAY: inline-block;}
		#configedit dd {FLOAT: Left; WIDTH: 30%;}
		#configedit dt {FLOAT: Left; WIDTH: 64%;}
		#configedit input[type=text], #configedit textarea {WIDTH: 100%;}
		.filebox {WIDTH: 80%; BACKGROUND: #eee; box-shadow: 2px 2px 2px #888; MARGIN: auto auto 2em auto; PADDING: 0; DISPLAY: Block;}
		.filebox input {CURSOR: auto; PADDING: 0;}
		.filebox h3 {PADDING: 2%;}
	</style>
</cfsavecontent>
<cfhtmlhead text="#head#" />
<!--- }}} --->

<!--- {{{ BODY --->
<cfoutput>
<cfsavecontent variable="body">
	<h2>Mura500 configuration</h2>
	<div>
		<p>This is a simple plugin to (periodically) generate static pages for 404 (Not found) and 500 (Internal server error) messages. Mura has good handling of 404 errors for requests to pages that go through the CMS, but that might not include e.g. css/js resources. For a 500 page, the plugin tries to download the page <em>/500</em> on the site in question. If those pages do not exist, they will be created with sensible defaults, that you can further customize.</p>
		<p>There are multiple places where you can add these as settings: in the webserver (Apache/Nginx/IIS etc), in the servlet engine (Jetty/Tomcat etc) and in the coldfusion/cfml engine (Lucee/ACF). Instructions on how to specify that is outside the scope of this plugin, please refer to the documentation for the piece of software in question.</p>
		<p>For the error pages to work - make sure you have <em>debuggingenabled=false</em> in your <em>settings.ini.cfm</em>.</p>
		<p>As for the default error page <em>errortemplate</em> in <em>settings.ini.cfm</em>, you can set that to <em>#relErrorCache#500.cfm</em> - this is also the path that you would use for the servlet engine error page.</p>
		<p>Note that the email and gntp notifications only apply to errors that are trapped within Mura.</p>
		<p>For optional Growl notifications (GNTP) install the <em>libgrowl.jar</em> library in your servlet/coldfusion engine.</p>
		<p>After any changes to this page, reload the application to make sure that the settings are loaded.</p>
	</div>
	<cfif !ArrayLen(StructKeyArray(siteSettings))>
		<div><em>Plugin is not enabled for any sites yet</em></div>
	<cfelse>
	<br/>
	<input type="submit" class="btn btn-default" value="Generate error templates now" style="WIDTH: 100%;" onclick="document.location='#application.configBean.getContext()#/plugins/mura500/?action=generate'; return false;" />
	<br/><br/>
	<form method="post" id="configedit" name="mura500" action="#application.configBean.getContext()#/plugins/mura500/?action=update">
		<cfloop index="SiteId" array="#StructKeyArray(siteSettings)#">
			<fieldset name="site#SiteId#" id="site#SiteId#">
				<legend>#SiteId#</legend>
				<p><strong>#siteSettings[SiteId].domain#</strong><br />#ArrayToList(siteSettings[SiteId].domainalias, ',')#</p>
				<p><em>Last generated: #DateFormat(siteSettings[SiteId].getLastUpdate(), 'yyyy-mm-dd')# #TimeFormat(siteSettings[SiteId].getLastUpdate(), 'HH:mm')#</em></p>
				<div class="filebox">
					<h3>To copy and paste into your web server, servlet engine and/or cfml engine configuration:</h3>
					<dl><dd>Static 404</dd><dt>
						<input type="text" readonly="readonly" value="#relErrorCache##SiteId#_404.html" />
						</dt>
					</dl>
					<dl><dd>Static 500</dd><dt>
						<input type="text" readonly="readonly" value="#relErrorCache##SiteId#_500.html" />
						</dt>
					</dl>
				</div>
				<dl>
					<dd><label for="#SiteId#_frequency">Update frequency (days)<br />(creating static error pages)<br/><em>Set to 0 to only do manual</em></label></dd>
					<dt><input type="text" name="#SiteId#_frequency" id="#SiteId#_frequency" value="#siteSettings[SiteId].getFrequency()#" placeholder="Update frequency (days)" /></dt>
				</dl>
				<dl>
					<dd><label for="#SiteId#_emailenabled">Email of error reports</label></dd>
					<dt><input type="checkbox" name="#SiteId#_emailenabled" id="#SiteId#_emailenabled" value="1" <cfif siteSettings[SiteId].getEmailEnabled()>checked="checked"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteId#_emailfrequency">Email frequency (hours)<br />(prevents duplicate reports/emails)<br/><em>Set to 0 to send all</em></label></dd>
					<dt><input type="text" name="#SiteId#_emailfrequency" id="#SiteId#_emailfrequency" value="#siteSettings[SiteId].getEmailFrequency()#" placeholder="Email frequency (hours)" <cfif !siteSettings[SiteId].getEmailEnabled()>disabled="disabled"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteId#_email">Email sendlist<br /><em>Comma-separated for multiple addresses</em></label></dd>
					<dt><input type="text" name="#SiteId#_email" id="#SiteId#_email" value="#siteSettings[SiteId].getEmail()#" placeholder="Email sendlist" <cfif !siteSettings[SiteId].getEmailEnabled()>disabled="disabled"</cfif>/></dt>
				</dl>
				<dl>
					<dd><label for="#SiteId#_emailbody">Email body<br /><em>cfml is ok</em><br/>Use ##dumpString(var)## to dump any variable, e.g. ##dumpString($.event('exception')##</label></dd>
					<dt>
						<textarea name="#SiteId#_emailbody" id="#SiteId#_emailbody" placeholder="Email body" <cfif !siteSettings[SiteId].getEmailEnabled()>disabled="disabled"</cfif>>#siteSettings[SiteId].getEmailBody()#</textarea>
					</dt>
				</dl>
				<cfif getSettingsService().getHasGntp()>
					<dl>
						<dd><label for="#SiteID#_gntpenabled">GNTP (growl) notifications</label</dd>
						<dt><input type="checkbox" name="#SiteId#_gntpenabled" id="#SiteId#_gntpenabled" value="1" <cfif siteSettings[SiteId].getGntpEnabled()>checked="checked"</cfif>/></dt>
					</dl>
					<dl>
						<dd><label for="#SiteID#_gntphost">GNTP host</label</dd>
						<dt><input type="text" name="#SiteId#_gntphost" id="#SiteId#_gntphost" value="#siteSettings[SiteId].getGntpHost()#" placeholder="hostname for GNTP" <cfif !siteSettings[SiteId].getGntpEnabled()>disabled="disabled"</cfif>/></dt>
					</dl>
					<dl>
						<dd><label for="#SiteID#_gntpport">GNTP port</label</dd>
						<dt><input type="text" name="#SiteId#_gntpport" id="#SiteId#_gntpport" value="#siteSettings[SiteId].getGntpPort()#" placeholder="network port for GNTP" <cfif !siteSettings[SiteId].getGntpEnabled()>disabled="disabled"</cfif>/></dt>
					</dl>
					<dl>
						<dd><label for="#SiteID#_gntppassword">GNTP password</label</dd>
						<dt><input type="text" name="#SiteId#_gntppassword" id="#SiteId#_gntppassword" value="#siteSettings[SiteId].getGntpPassword()#" placeholder="password for GNTP" <cfif !siteSettings[SiteId].getGntpEnabled()>disabled="disabled"</cfif>/></dt>
					</dl>
					<dl>
						<dd><label for="#SiteID#_gntpicon">Icon for notifications<br /><em>A valid full URL</em></label</dd>
						<dt><input type="text" name="#SiteId#_gntpicon" id="#SiteId#_gntpicon" value="#siteSettings[SiteId].getGntpIcon()#" placeholder="Icon url for GNTP" <cfif !siteSettings[SiteId].getGntpEnabled()>disabled="disabled"</cfif>/></dt>
					</dl>
				<cfelse>
					<input type="hidden" name="#SiteId#_gntpenabled" value="0" />
				</cfif>
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
	<cfloop index="SiteId" array="#StructKeyArray(siteSettings)#">
		$(document).ready(function(){
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
			$('.filebox input').click(function() {
				$(this).select();
			});
		});
	</cfloop>
</script>
</cfoutput>
<!--- }}} --->
