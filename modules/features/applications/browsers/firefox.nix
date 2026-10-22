{
  flake.features.firefox.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = lib.mkIf pkgs.stdenv.isDarwin [
        pkgs.firefox-bin-unwrapped
      ];

      home.activation.firefoxLegacyProfiles = lib.mkIf pkgs.stdenv.isDarwin (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run /bin/launchctl setenv MOZ_LEGACY_PROFILES 1
        ''
      );

      programs.firefox = {
        enable = true;
        package = if pkgs.stdenv.isDarwin then null else pkgs.firefox;

        policies = {
          # No AI, ty.
          AIControls = {
            Default = {
              Value = "blocked";
              Locked = true;
            };
          };
          GenerativeAI = {
            Enabled = false;
            Locked = true;
          };

          # Autofill options.
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;

          # Auto-accept opening certain protocols from particular origins.
          AutoLaunchProtocolsFromOrigins = builtins.toJSON [
            # Example below, not sure what I'll use this for for now.
            # {
            #   protocol = "steam";
            #   allowed_origins = [
            #     "https://store.steampowered.com"
            #   ];
            # }
          ];

          # Handled by password manager.
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;

          # TODO: Figure out what https://firefox-admin-docs.mozilla.org/reference/policies/displaymenubar/ does.
          # TODO: Consider https://firefox-admin-docs.mozilla.org/reference/policies/sitepolicies/.
          # TODO: Consider https://firefox-admin-docs.mozilla.org/reference/policies/dnsoverhttps/.
          # TODO: Consider https://firefox-admin-docs.mozilla.org/reference/policies/handlers/.
          # TODO: Consider https://firefox-admin-docs.mozilla.org/reference/policies/preferences/

          # Firefox Suggest settings, which dictate what can be suggested from Mozilla in the search/address bar.
          FirefoxSuggest = {
            WebSuggestions = false;
          };

          # Built-in Search Engine customisation.
          SearchEngines = {
            Remove = [
              "Bing"
              "eBay"
              "Perplexity"
              "Wikipedia (en)"
            ];
          };

          # Fairly self-explanatory annoyances with the default Firefox experience.
          DisableSetDesktopBackground = true;
          DisableAppUpdate = true;
          DisableAccounts = true;
          DisableFirefoxAccounts = true;
          DisableFirefoxScreenshots = true;
          DisableFirefoxStudies = true;
          DontCheckDefaultBrowser = true;
          DefaultBrowserSettingEnabled = false;
          SkipTermsOfUse = true;
          DisableTelemetry = true;
          CrashReportsSubmit = {
            Enabled = false;
          };
        };

        profiles = {
          personal = {
            name = "Personal";
            isDefault = true;
            containersForce = true;
            settings = {
              # Enable extensions without prompting.
              "extensions.autoDisableScopes" = 0;
            };
            extensions = {
              packages = with pkgs.nur.repos.rycee.firefox-addons; [
                ublock-origin
                onepassword-password-manager
                refined-github
                kagi-privacy-pass
                kagi-search
                youtube-recommended-videos
              ];
            };

            bookmarks = {
              force = true;
              settings = [
                {
                  name = "Bookmarks Toolbar";
                  toolbar = true;
                  bookmarks = [
                    {
                      name = "Youtube";
                      url = "https://youtube.com/feed/subscriptions";
                    }
                    {
                      name = "GitHub";
                      url = "https://github.com";
                    }
                    {
                      name = "HackerNews";
                      url = "https://news.ycombinator.com";
                    }
                    {
                      name = "Nix";
                      bookmarks = [
                        {
                          name = "Searchix";
                          url = "https://searchix.ovh/";
                        }
                        {
                          name = "NixOS Search";
                          url = "https://search.nixos.org/packages/";
                        }
                      ];
                    }
                  ];
                }
              ];
            };

            # Decided to use this because I can copy lines from prefs.js rather than have to convert the format.
            extraConfig = ''
              // Don't warn/ask on Quit with Ctrl/Cmd + Q.
              user_pref("browser.warnOnQuitShortcut", false);

              // New tab page (Firefox Home) customisation.
              user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
              user_pref("browser.newtabpage.activity-stream.showSponsored", false);
              user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
              user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
              user_pref("browser.newtabpage.activity-stream.widgets.enabled", false);

              // Bookmark bar visibility and toolbar config.
              user_pref("browser.toolbars.bookmarks.visibility", "always");
              user_pref("browser.uiCustomization.state", "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"privacypass_kagi_com-browser-action\",\"myallychou_gmail_com-browser-action\",\"search_kagi_com-browser-action\",\"_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"customizableui-special-spring2\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"reset-pbm-toolbar-button\",\"_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"unified-extensions-button\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"customizableui-special-spring3\",\"alltabs-button\",\"smartwindow-group-tabs-button\",\"ai-window-toggle\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"myallychou_gmail_com-browser-action\",\"privacypass_kagi_com-browser-action\",\"search_kagi_com-browser-action\",\"_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action\",\"reset-pbm-toolbar-button\",\"developer-button\"],\"dirtyAreaCache\":[\"unified-extensions-area\",\"nav-bar\",\"TabsToolbar\",\"vertical-tabs\",\"PersonalToolbar\"],\"currentVersion\":26,\"newElementCount\":5}");

              // Address bar suggestions.
              user_pref("browser.urlbar.suggest.quickactions", false);
              user_pref("browser.urlbar.suggest.topsites", false);

              // Disable PiP.
              user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);

              // Disable navigation prediction.
              user_pref("network.dns.disablePrefetch", true);
              user_pref("network.prefetch-next", false);
              user_pref("network.http.speculative-parallel-limit", 0);

              // History handling/privacy.
              user_pref("privacy.clearOnShutdown_v2.formdata", true);
              user_pref("privacy.globalprivacycontrol.enabled", true);
              user_pref("privacy.globalprivacycontrol.was_ever_enabled", true);
              user_pref("privacy.sanitize.clearOnShutdown.hasMigratedToNewPrefs3", true);
              user_pref("privacy.userContext.enabled", false);

              // No password breach checks.
              user_pref("signon.management.page.breach-alerts.enabled", false);
            '';
          };
        };
      };
    };
}
