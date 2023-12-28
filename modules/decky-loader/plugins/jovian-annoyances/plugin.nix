{ configuration
, lib
, writeTextDir
, symlinkJoin
}:

let
  inherit (configuration)
    features
  ;
  inherit (lib)
    optionalString
  ;
in
symlinkJoin rec {
  name = "jovian-annoyances-plugin-${version}";
  version = "0.1";
  paths = [
    (writeTextDir "plugin.json" (builtins.toJSON {
      name = "Jovian Annoyances";
      author = "Jovian NixOS contributors";
      flags = [];
    }))
    (writeTextDir "package.json" (builtins.toJSON {
      name = "Jovian Annoyiances";
      version = version;
      description = "Fixes misc. annoyances on Jovian NixOS";
      author = "Jovian NixOS contributors";
      license = "MIT";
    }))
    (writeTextDir "dist/index.js" ''
      (function (deckyFrontendLib, React) {
        "use strict";
        console.log("Jovian Annoyances plugin loading...");

        ${optionalString features.timeZone.enable ''
          (async () => {
            console.log("Jovian Annoyances: Overriding Timezone...");
            var forced_timezone = {
              "utcOffset": ${features.timeZone.utcOffset},
              "timezoneID": await SteamClient.Settings.GetTimeZone(),
              "timezoneLocalizationToken": ${builtins.toJSON features.timeZone.timeZoneName},
              "regionsLocalizationToken": ${builtins.toJSON features.timeZone.regionName}
            }
            SteamClient.Settings.GetAvailableTimeZones = async () => { return [forced_timezone]; }
            SteamClient.Settings.GetTimeZone = async () => { return forced_timezone.timezoneID; }
          })()
        ''}

        return deckyFrontendLib.definePlugin((serverApi) => {
          return {
            title: window.SP_REACT.createElement("div", { className: deckyFrontendLib.staticClasses.Title }, "Jovian Annoyances"),
          };
        });
      })(DFL, SP_REACT);
    '')
    # Those previous globals are the interface used for plugins.
    # See: https://github.com/SteamDeckHomebrew/decky-plugin-template/blob/8f6c61207f4afe623d9f00b2cca3681434d9d4de/rollup.config.js#L30-L34
  ];
}

