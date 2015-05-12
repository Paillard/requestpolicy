pref("extensions.rpcontinued@requestpolicy.org.description",
    "chrome://rpcontinued/locale/requestpolicy.properties");

pref("extensions.rpcontinued.log", false);
pref("extensions.rpcontinued.log.level", 0);
pref("extensions.rpcontinued.log.types", 1023);

pref("extensions.rpcontinued.autoReload", true);

pref("extensions.rpcontinued.defaultPolicy.allow", true);
pref("extensions.rpcontinued.defaultPolicy.allowSameDomain", true);

pref("extensions.rpcontinued.welcomeWindowShown", false);

pref("extensions.rpcontinued.indicateBlockedObjects", true);
pref("extensions.rpcontinued.indicateBlacklistedObjects", false);
pref("extensions.rpcontinued.startWithAllowAllEnabled", false);
pref("extensions.rpcontinued.privateBrowsingPermanentWhitelisting", false);

pref("extensions.rpcontinued.prefetch.link.disableOnStartup", true);
pref("extensions.rpcontinued.prefetch.link.restoreDefaultOnUninstall", true);
pref("extensions.rpcontinued.prefetch.dns.disableOnStartup", false);
pref("extensions.rpcontinued.prefetch.dns.restoreDefaultOnUninstall", true);

pref("extensions.rpcontinued.menu.sorting", "numRequests");
pref("extensions.rpcontinued.menu.info.showNumRequests", true);

pref("extensions.rpcontinued.lastVersion", "0.0");
pref("extensions.rpcontinued.lastAppVersion", "0.0");

// #ifdef UNIT_TESTING
pref("extensions.rpcontinued.unitTesting.errorCount", 0);
// #endif
