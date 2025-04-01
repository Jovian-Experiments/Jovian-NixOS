{ writeShellApplication
, lib
, drm_info
, imagemagick

}:

writeShellApplication {
  name = "jovian-updater-logo-helper";

  runtimeInputs = [
    drm_info
    imagemagick
  ];

  text = builtins.readFile ./jovian-updater-logo-helper.sh;

  meta = {
    # Same license as the repo.
    license = lib.licenses.mit;
  };
}
