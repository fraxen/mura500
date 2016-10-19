# Mura500 - Mura CMS plugin for handling _500 Internal Server Error_ pages
A plugin for [Mura CMS 6.2](http://www.getmura.com/) - a CFML (Adobe ColdFusion/Lucee) content management system.

<p align="center"><strong><a href="https://github.com/fraxen/mura500/releases">Download latest release</a></strong></p>

This is a simple plugin to (periodically) generate static pages for 404 (Not found) and 500 (Internal server error) messages. Mura has good handling of 404 errors for requests to pages that go through the CMS, but that might not include e.g. css/js resources. For a 500 page, the plugin tries to download the page _/500_ on the site in question. If those pages do not exist, they will be created with sensible defaults, that you can further customize.

There are multiple places where you can add these as settings: in the webserver (Apache/Nginx/IIS etc), in the servlet engine (Jetty/Tomcat etc) and in the coldfusion/cfml engine (Lucee/ACF). Instructions on how to specify that is outside the scope of this plugin, please refer to the documentation for the piece of software in question.

For optional Growl notifications (GNTP) install the _libgrowl.jar_ library in your servlet/coldfusion engine. You can get that here: https://github.com/feilimb/libgrowl.
ad the application to make sure that the settings are loaded.

## Status
This projects is released as is. It has not been extensively tested, so you might want to test it on development/staging server first.
[Please report any bugs/issues that you might find!](https://github.com/fraxen/mura500/issues)

## Requirements
A Mura CMS 6.2 install, so far tested on Lucee 4.5 and Adobe Coldfusion 10 with MySql, but should work with other cfml engines, and should probably work on Mura 7 too - but have not tested this yet.

## Instructions
* [Download the latest release](https://github.com/fraxen/mura500/releases), or clone the repository
* Install as a Mura CMS plugin
* Go to the _modules/plugin_ page in the administrator and review the settings
* You might want to test that the plugin can download the templates properly, so that it doesn't repeatedly try every onSiteMonitor cycle.

## License
[Apache license](LICENSE)

## Future
Any help with expanding the plugin is very welcome!
* [Review and test with Mura 7](https://github.com/fraxen/mura500/issues/2)
* [Pushbullet notifications, on error](https://github.com/fraxen/mura500/issues/3)
* [RSS feed for errors](https://github.com/fraxen/mura500/issues/4)

## Contributions
Any help, bug fixes, comments or input is very welcome. 
