{ buildDeckyPlugin, lib, stdenv, fetchurl, unzip }:
  {
    "xr_gaming" = buildDeckyPlugin {
      name = "XR Gaming";
      version = "1.0.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/714b7264b0ef6d7f3b663f20601920d365c58d0e514a776955440c6c11361dfb.zip";
      download_hash = "1yqx6q8nq324amlpfjji1s6warfk40cn081zcqxpyvggn1j74jvi";
      meta = with lib;
      {
        description = "Virtual display, VR-Lite, and Follow modes for supported XR glasses";
        decky_tags = [
          "ar"
          "rayneo"
          "rokid"
          "root"
          "tcl"
          "viture"
          "vr"
          "xr"
          "xreal"
        ];
        platforms = platforms.all;
      };
    };
    "css_loader" = buildDeckyPlugin {
      name = "CSS Loader";
      version = "2.1.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/1a1e8f4dded8494febe56df16429ef5bba1e5b8feb3fd989d5808fbef0d71350.zip";
      download_hash = "0l0kszqbx3w0sn4xjgzbixdixfjvxwln9wbdwpmlyjfqvr6qy7hs";
      meta = with lib;
      {
        description = "Dynamically loads themes developed with CSS into the Steam UI. For more information, visit deckthemes.com.";
        decky_tags = [ "style" ];
        platforms = platforms.all;
      };
    };
    "vibrantdeck" = buildDeckyPlugin {
      name = "vibrantDeck";
      version = "2.0.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/272f6f3cd66c5d5c9b50ff46463ad509c8afc014633febd22046ff1aee52ee0f.zip";
      download_hash = "03zfabp1mzs6439fngv32k0azj09slx4cipza2dmqpbcsqy6ybr7";
      meta = with lib;
      {
        description = "Adjust color settings of your Deck";
        decky_tags = [ "saturation" "vibrant" ];
        platforms = platforms.all;
      };
    };
    "fantastic" = buildDeckyPlugin {
      name = "Fantastic";
      version = "0.5.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/a70f291d2ba681fb6757c0c7e139d3fadd9a350cf3f755a9a1f668cae18b8b8a.zip";
      download_hash = "12lbighwls7nl6lmbxzk1hsrmpgsscwy3iy0axkzp0d65cfjj3x7";
      meta = with lib;
      {
        description = "Fan controls";
        decky_tags = [ "fan-control" "root" "utility" ];
        platforms = platforms.all;
      };
    };
    "musiccontrol" = buildDeckyPlugin {
      name = "MusicControl";
      version = "1.1.6";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/246b89fd653c60a735b1cc401d1b0937d5cb969eea9024561661ff741f081d62.zip";
      download_hash = "0qhx10gp9zv12rb2947aksbcpm9p14dish6cn4ssfq1wcpyqjsr4";
      meta = with lib;
      {
        description = "Control running media players using the DBUS interface (MPRIS). Media player has to be started through game mode.";
        decky_tags = [ "media" "mpris" "music" ];
        platforms = platforms.all;
      };
    };
    "pause_games" = buildDeckyPlugin {
      name = "Pause Games";
      version = "1.0.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/b704ef5eb477415eeaab90c7e1d4cda524b061be211e8ec4885a60b995fd5503.zip";
      download_hash = "00smznavjq2si328w7i1prhv0955rpaf3iwhmgm5whbpnigfy15p";
      meta = with lib;
      {
        description = "Pause/Resume games to redirect resources and even play/stop apps that don't natively have an immediate option to do so.";
        decky_tags = [
          "pause"
          "play"
          "quick-resume"
          "resume"
          "sigcont"
          "sigstop"
          "sleep"
          "stop"
          "suspend"
        ];
        platforms = platforms.all;
      };
    };
    "protondb_badges" = buildDeckyPlugin {
      name = "ProtonDB Badges";
      version = "1.1.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/3894048d0d9b35342c85d9f50e9e5e4edc00b65e9dfe61d47ec5cf97bfd28da7.zip";
      download_hash = "19wdsazrgky5gva63zlxbsv01p2fbsg0xxfrhln38dcv1n6h951q";
      meta = with lib;
      {
        description = "Display tappable ProtonDB badges on your game pages";
        decky_tags = [ "protondb" ];
        platforms = platforms.all;
      };
    };
    "audio_loader" = buildDeckyPlugin {
      name = "Audio Loader";
      version = "1.6.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/0c104f697dc99d54601446495964b407d6b61786e0b029117db3a597d63eeb61.zip";
      download_hash = "0qgb7vb9g9dkgl8jkc70hqbvdmh7nij5jja62ih597f9gmlly40c";
      meta = with lib;
      {
        description = "Replaces Steam UI sound effects with custom sounds and adds music to menus.";
        decky_tags = [ "media" "music" "style" ];
        platforms = platforms.all;
      };
    };
    "bluetooth" = buildDeckyPlugin {
      name = "Bluetooth";
      version = "2.3.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/5dfb17176edb7b1699e0d6d336ee0b3b1571d41ee7c7fd3fbbd93c4537d84ef6.zip";
      download_hash = "1xjfv0vlag6rpczzviz73va7259v1gp3dlynw2cicyyvdqbigysx";
      meta = with lib;
      {
        description = "Quickly connect to your already paired bluetooth devices.";
        decky_tags = [ "bluetooth" "utility" ];
        platforms = platforms.all;
      };
    };
    "notebook" = buildDeckyPlugin {
      name = "Notebook";
      version = "0.1.5";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/c35b09de4bba4b4157fbe84cb7b0d20fc3924f78fa3c48ae17686b4314c1cc0c.zip";
      download_hash = "036cq4a46sv82yp4hg7sg17r5hqgsaqbfk78zdbl2jxs9gg0jny3";
      meta = with lib;
      {
        description = "Quickly scribble down important codes or notes during your play sessions.";
        decky_tags = [
          "draw"
          "drawings"
          "notebook"
          "notes"
          "scribble"
          "write"
        ];
        platforms = platforms.all;
      };
    };
    "powertools" = buildDeckyPlugin {
      name = "PowerTools";
      version = "2.0.3";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/47614f53b8c538c4caa15f89a01e4ab106fa328e89f78545bacb3166d104d964.zip";
      download_hash = "0r6r0k8nccfbp92qbxw9iqrgl1mi98ga12azl75c8f65p19lyqa7";
      meta = with lib;
      {
        description = "Power tweaks for power users";
        decky_tags = [ "power-management" "root" "utility" ];
        platforms = platforms.all;
      };
    };
    "memory_deck" = buildDeckyPlugin {
      name = "Memory Deck";
      version = "0.1.8";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/69f4707c2a0580f64df260fbd3de205e068a825b620769038c7bdaec516c104e.zip";
      download_hash = "0khhdi8yrnkvih1nj1v2bf18l1jy43gd7yv0y96zd00559y71x39";
      meta = with lib;
      {
        description = "A simplistic scanmem wrapper for Decky. Enabling scanning for and editing values in memory.";
        decky_tags = [ "cheats" "memory" "scanmem" ];
        platforms = platforms.all;
      };
    };
    "animation_changer" = buildDeckyPlugin {
      name = "Animation Changer";
      version = "1.3.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/f2c62b90ca60d8a80b6d0f75d8027552b1509c7a05842c6f4a24a9072846d133.zip";
      download_hash = "0cyi8ql0ga9499pjr105gaf51cajfl1dhx8gdl5sin30ra82pipj";
      meta = with lib;
      {
        description = "A boot/suspend animation management plugin.";
        decky_tags = [ "boot-animation" "utility" ];
        platforms = platforms.all;
      };
    };
    "radiyo" = buildDeckyPlugin {
      name = "RadiYo!";
      version = "1.3";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/647111578aa7a5ecd16af8d7fe6c068a6d7ea8737c6dce5ac2d52e84a549ec43.zip";
      download_hash = "0hzc96jq8bnmq9dcwvbwffl7wvca0rngxmzqdb8yr9d7i9bi2wb4";
      meta = with lib;
      {
        description = "Search and play music from internet radio stations while gaming";
        decky_tags = [ "media" "music" "radio" ];
        platforms = platforms.all;
      };
    };
    "hltb_for_deck" = buildDeckyPlugin {
      name = "HLTB for Deck";
      version = "2.0.4";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/d9ef0a95bc91c110ed94198464e4968f3eec7e16f6eedab8ed75b4294993a8e9.zip";
      download_hash = "1sd8jd4jkd3mxnwdmvpn2rzfqglgjvj6910rjkni1hcipjahmvyr";
      meta = with lib;
      {
        description = "A plugin to show you game lengths according to How Long To Beat";
        decky_tags = [ "backlog" "how long to beat" "utility" ];
        platforms = platforms.all;
      };
    };
    "autosuspend" = buildDeckyPlugin {
      name = "AutoSuspend";
      version = "2.1.0-1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/1e44054bc201b51e36bb713c786ee339c8fb4c4098479f25a1c7ddd6e6840244.zip";
      download_hash = "0i02hkkddpf7l4jryiwq816gpj1rwdp7hg3ipcv1xd81q95hai0y";
      meta = with lib;
      {
        description = "Automatically suspend on low power.";
        decky_tags = [ "battery" "power-management" "suspend" "utility" ];
        platforms = platforms.all;
      };
    };
    "emuchievements" = buildDeckyPlugin {
      name = "Emuchievements";
      version = "2.0.3";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/d9d43e9d0720615d109746a658fbbfd4b0d69e69b7444310e25ad62e415f7980.zip";
      download_hash = "103rbx0jxmjsw8846i5pd6gddc6lpzxmi9j6jw85sq900yfkxm6r";
      meta = with lib;
      {
        description = "Plugin for viewing RetroAchievements progress. Part of the EmuDeck Project";
        decky_tags = [ "EmuDeck" "retroachievements" ];
        platforms = platforms.all;
      };
    };
    "tunneldeck" = buildDeckyPlugin {
      name = "TunnelDeck";
      version = "1.0.4";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/2698b31e53109b992e16f2e888a371a028a2c2719745261d4379d18bed9ac5c8.zip";
      download_hash = "1j65kbnqplbr8cfjcicpf71a4a50f6iqis7j2qp9k6qhacgb7616";
      meta = with lib;
      {
        description = "Enables VPN support within Gaming Mode and activates OpenVPN support for Network Manager.";
        decky_tags = [ "root" "vpn" ];
        platforms = platforms.all;
      };
    };
    "autoflatpaks" = buildDeckyPlugin {
      name = "AutoFlatpaks";
      version = "1.6.7";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/b2f447ac727a0591527b78e98d9e246dd1a8e0bced7537841fd3f858538288de.zip";
      download_hash = "1pl8h99miy6k3y23fxgdpkhailbd4jg8vsbqgd9921bsfan4gx5j";
      meta = with lib;
      {
        description = "A plugin to manage, notify, and automatically update flatpaks on your steamdeck console";
        decky_tags = [
          "flatpak"
          "package-management"
          "root"
          "update"
          "utility"
        ];
        platforms = platforms.all;
      };
    };
    "moondeck" = buildDeckyPlugin {
      name = "MoonDeck";
      version = "1.9.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/563ef7acb4c72764b5e3a5a620b109e2cb0475ed94d54f8ff5c77e5c77dbedb6.zip";
      download_hash = "1dpdvdvmqzn7yn7lzmclxmsh9jz216qj19m5wfsn89y7njngfgjn";
      meta = with lib;
      {
        description = "MoonDeck lets you play any of your Steam games via Moonlight without needing to add them to Sunshine first, providing a similar experience to GeForce GameStream or Steam Remote Play.";
        decky_tags = [ "gamestream" "moondeck" "moonlight" "streaming" ];
        platforms = platforms.all;
      };
    };
    "steamgriddb" = buildDeckyPlugin {
      name = "SteamGridDB";
      version = "1.5.1-loaderv2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/b84f0a3f83b6e5d7cbc0ba9360bde33cfb400cf5f2a5d5c38f44a488e2c91a57.zip";
      download_hash = "0mqsr7i8i924iz1xb9gjyl641yrwwfyn14xsq35xgrdnhczhlkxq";
      meta = with lib;
      {
        description = "Customize your library with user-submitted images or your local files, and apply other tweaks like changing the shape of the recently played game capsule, making them square, and more!";
        decky_tags = [ "artwork" "sgdb" ];
        platforms = platforms.all;
      };
    };
    "discord_status" = buildDeckyPlugin {
      name = "Discord Status";
      version = "1.4.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/46f2d487ed329185712b2d51e51ada89254b371cbc4b82e051edbcd5bef7c62a.zip";
      download_hash = "0an6yyzdbg7da7h84jxw3hvln9c9v8dfal9d5dqqb49jxn3x9wj6";
      meta = with lib;
      {
        description = "Displays current Steam Deck game in Discord";
        decky_tags = [ "discord" ];
        platforms = platforms.all;
      };
    };
    "volume_mixer" = buildDeckyPlugin {
      name = "Volume Mixer";
      version = "1.2.1-1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/11b259ad234d0e97cfef4e6a2af3f1edfb0908d5482765af56b86b0a4601c5f3.zip";
      download_hash = "1wy50530lsxqaspna9s8sl40kyzdy7rjlsjfxz7rf3jd4fnmkchi";
      meta = with lib;
      {
        description = "Control the volume of applications and connected Bluetooth sources.";
        decky_tags = [ "media" "volume" ];
        platforms = platforms.all;
      };
    };
    "controller_tools" = buildDeckyPlugin {
      name = "Controller Tools";
      version = "2.0.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/9450e54cbf28082d4513838d0dcd42bf04ffc08ae5a6472d0c1f88677782e3ef.zip";
      download_hash = "1vz3h9vng20z1hnlg9p5ib0gy15z8b6hv3c32d2js218px6fal4l";
      meta = with lib;
      {
        description = "The missing game controller menu. Displays the current battery % and charging status. Supports: DualSense, DualShock 4, Nintendo Switch Pro Controller";
        decky_tags = [
          "controller"
          "gamepad"
          "nintendo"
          "playstation"
          "switch"
          "xbox"
        ];
        platforms = platforms.all;
      };
    };
    "tailscale_control" = buildDeckyPlugin {
      name = "Tailscale Control";
      version = "0.1.3";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/06411711b27101d438339000da3d91202d682862710b02ef3ddf2462e642448a.zip";
      download_hash = "12j48bk6496z7pph42vic8l6hb90j4yxl04h6cwd80bin88ifh86";
      meta = with lib;
      {
        description = "A Decky plugin to activate and deactivate Tailscale, while staying in Gaming mode. [Note: Tailscale needs to be installed, this works only like a switch for the same.]";
        decky_tags = [ "tailscale" ];
        platforms = platforms.all;
      };
    };
    "deckmtp" = buildDeckyPlugin {
      name = "DeckMTP";
      version = "1.0.4";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/ad0ec3f3e11bc9daaf5e1645d1c9cb2ca7661728670c45bb51306e9723a2a846.zip";
      download_hash = "0im8l8irfviha6xla33750bnd9rcrg4x2i8nbspxmj8vw7rw63md";
      meta = with lib;
      {
        description = "A plugin that allows your Steam Deck to transfer files to your PC via MTP and USB";
        decky_tags = [ "file-transfer" "media" "root" "utility" ];
        platforms = platforms.all;
      };
    };
    "decky_recorder" = buildDeckyPlugin {
      name = "Decky Recorder";
      version = "0.4.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/299d3c60442b0701db6e8c26b5daa7a88dbd7dd0cfa28012fe734f4def2b5363.zip";
      download_hash = "0qsk5gplskvkzq9818ngs1yvv3d8lzdba9lcdvdh21rb8ih3r799";
      meta = with lib;
      {
        description = "Record your games with Decky Recorder";
        decky_tags = [ "Capture" ];
        platforms = platforms.all;
      };
    };
    "steamback" = buildDeckyPlugin {
      name = "Steamback";
      version = "1.0.0-1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/ed5f2fbb47cdfc3aa9a4349a139ab20c29976117a3be0de7e8a588bb265ee7f3.zip";
      download_hash = "1wz7bqkbp255x3khvgm32xhrfa8cnad176illjlkmz6d8yxjypzd";
      meta = with lib;
      {
        description = "Automatic save game snapshot/restore for Steam";
        decky_tags = [ "backup" "steamback" ];
        platforms = platforms.all;
      };
    };
    "quick_launch" = buildDeckyPlugin {
      name = "Quick Launch";
      version = "1.2.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/150e77907d8891f577ca9ee267cdf7b962087b815b5ecec9c4997e9f32e0af5e.zip";
      download_hash = "0pmgw0r9yzlrqk4wwpjvh5xhhqmryz6ngqlyr9vzb4c8gn87f3hm";
      meta = with lib;
      {
        description = "Quickly Launch Non-Steam-Apps from the Quick Access menu without adding them as Shortcuts, or add them to the Steam Library.";
        decky_tags = [ "utility" ];
        platforms = platforms.all;
      };
    };
    "decky_cloud_save" = buildDeckyPlugin {
      name = "Decky Cloud Save";
      version = "1.4.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/b311d967ddf1b0f0046d36929645855891a40173e3a93f6f0cd8b1576b04b411.zip";
      download_hash = "04dl0immgcfq1ipkzag3fc0s94aqhm2rd4indl2g1c7ivmkxj4dk";
      meta = with lib;
      {
        description = "Manage cloud saves for games that do not support it in [current year].";
        decky_tags = [ "backup" "cloud" "rclone" ];
        platforms = platforms.all;
      };
    };
    "storage_cleaner" = buildDeckyPlugin {
      name = "Storage Cleaner";
      version = "1.4.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/1afa1a6f129c5d419de0e0bf0f6db8d8e50385a5659179346e996031ea372591.zip";
      download_hash = "14956zm32q4rdqs7k4b5ln2h7rfqp1nhzgz0w2fl2pcw29pimyhs";
      meta = with lib;
      {
        description = "Quickly visualize, select and clear shader cache and compatibility data.";
        decky_tags = [
          "cache"
          "cleaner"
          "compatdata"
          "compatibility"
          "data"
          "disk"
          "other"
          "shader"
          "storage"
          "utility"
        ];
        platforms = platforms.all;
      };
    };
    "game_theme_music" = buildDeckyPlugin {
      name = "Game Theme Music";
      version = "1.7.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/2a9fced36b3d34bd4bd4bd7963787b486bf39137f9d444632140ab1fe1872de8.zip";
      download_hash = "1s1dhzhizas045il9m7r6y8z6ss8gdw66ydxsi5vsd1xdg9wx7ra";
      meta = with lib;
      {
        description = "Play theme songs on your game pages";
        decky_tags = [ "audio" ];
        platforms = platforms.all;
      };
    };
    "shotty" = buildDeckyPlugin {
      name = "Shotty";
      version = "0.1.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/ab7f6618b264a0cb766525e788cef6c3e1478c0fef98a701225e5e8af441e2fe.zip";
      download_hash = "1zp287s8lpjy480sg67g1y64gqf3yv78irr5cmvcp834n8c6czxb";
      meta = with lib;
      {
        description = "A plugin for copying over screenshots to the Pictures folder";
        decky_tags = [ "screenshots" ];
        platforms = platforms.all;
      };
    };
    "mangopeel" = buildDeckyPlugin {
      name = "MangoPeel";
      version = "0.0.5-1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/c27d0bb14d803595599d9ad23309feccab827b74cd460ce51fc28a51edb16e44.zip";
      download_hash = "0i3fn7nm32n23zjhqindfixq5ayczq4k7llskmcradc09nqhnzf2";
      meta = with lib;
      {
        description = "A decky plugin for custom performance monitoring style.";
        decky_tags = [ "mangoapp" "mangohud" ];
        platforms = platforms.all;
      };
    };
    "volume_boost" = buildDeckyPlugin {
      name = "Volume Boost";
      version = "0.0.6";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/d408afb057ed5320d2e7436ab9ccea235364f6117c7173df2f66daeb95e06749.zip";
      download_hash = "0jb7w2aypnk65zgp6wbw27v68lr3xb6bjsj3wz920lzdayqay26l";
      meta = with lib;
      {
        description = "A Decky plugin to boost volume.";
        decky_tags = [ "audio" "boost" "booster" "loud" "sound" "volume" ];
        platforms = platforms.all;
      };
    };
    "web_browser" = buildDeckyPlugin {
      name = "Web Browser";
      version = "1.4.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/dce6565123bcde7f43bda7995876c11bb81cc56e38268581c66473b5ec3eb8bd.zip";
      download_hash = "1gdq7vnbawv4qs0qa9iqdv2irf0vq5v5i6d7pm1pzpmw4d8mdrnw";
      meta = with lib;
      {
        description = "A web browser with multiple features including tabs!, limited gamepad support, favorites and a multifunction search/url bar.";
        decky_tags = [ "browser" "internet" "web" ];
        platforms = platforms.all;
      };
    };
    "deckyfileserver" = buildDeckyPlugin {
      name = "DeckyFileServer";
      version = "1.0.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/3044fc8d8901ae048bd1242207e9cdb0c3c0e02696cbe97055e8acd762eab2aa.zip";
      download_hash = "1amjx9idgb78amqfkjwn4vhc1hxhrplhf8i4s65h9bh1i66zqi1h";
      meta = with lib;
      {
        description = "Plugin that lets you turn on a web server to browse and download files from your Steam Deck.";
        decky_tags = [ "root" ];
        platforms = platforms.all;
      };
    };
    "tabmaster" = buildDeckyPlugin {
      name = "TabMaster";
      version = "2.8.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/eb74a08f8aa6f89808740424ce0f12670409ce9c15776cd623d3b4e4c9a8f52b.zip";
      download_hash = "0azmm34y9d6k4gb6qxqmkk70j137287ww904fh49iy56ia7s0x7b";
      meta = with lib;
      {
        description = "Gives you full control over your Steam library! Support for customizing, adding, and hiding Library Tabs.";
        decky_tags = [ "Customization" "Library" "Tabs" ];
        platforms = platforms.all;
      };
    };
    "ts3_quickaccess" = buildDeckyPlugin {
      name = "TS3 QuickAccess";
      version = "1.2.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/04c853f6e0e20373d1262bf9a57a01f4123598797d73c8a52cdcc64cfe44845c.zip";
      download_hash = "0p448kz4rinw5jjwhwvxg6c3a4pl05xaby9b4v8p60z2w3v57j04";
      meta = with lib;
      {
        description = "A TeamSpeak 3 client plugin that integrates TeamSpeak 3 into Steam Deck's quick access menu.";
        decky_tags = [ "teamspeak" ];
        platforms = platforms.all;
      };
    };
    "free_loader" = buildDeckyPlugin {
      name = "Free Loader";
      version = "1.3.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/ce030b03c9638f990cf53657f1fd0ac95d1e1ad70060ac76752f26789d65f639.zip";
      download_hash = "0fgncnfph9igfmvaqq00swd1wpf91byz2mrnyl69k3v3r41hn0yf";
      meta = with lib;
      {
        description = "Notifications for free games on Steam, GOG, and Epic Games!";
        decky_tags = [
          "epic"
          "epic games store"
          "free"
          "game"
          "games"
          "gog"
          "library"
          "loader"
          "notifications"
          "steam"
          "store"
        ];
        platforms = platforms.all;
      };
    };
    "syncthing" = buildDeckyPlugin {
      name = "Syncthing";
      version = "0.2.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/49c59574b51d2b694c42e00ab8c52b770f0d2f7aaca95dd9ba2c736e43f0280b.zip";
      download_hash = "02r8y11nwwrcpbcmvadcg8phs3vp5g2vh2p08966jaqxnms9bia9";
      meta = with lib;
      {
        description = "Plugin for managing Syncthing to synchronize files with other devices. Not officially affiliated with the Syncthing project. The 'Syncthing GTK' flatpak must be installed.";
        decky_tags = [
          "backup"
          "cloud"
          "files"
          "services"
          "synchronization"
          "syncthing"
        ];
        platforms = platforms.all;
      };
    };
    "decky_terminal" = buildDeckyPlugin {
      name = "Decky Terminal";
      version = "0.4.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/2e959bf8593ad684390e2a73c43691fe75cd5f1614f022c3cad4f5109840170b.zip";
      download_hash = "02qp82c11xflrb1j5w0l2rgwsxgyj4vc8wra1qwq9misb7w9p59f";
      meta = with lib;
      {
        description = "A Missing Terminal plugin that turns your Steam Deck into Portable Linux Battlestation.";
        decky_tags = [ "terminal" ];
        platforms = platforms.all;
      };
    };
    "playtime" = buildDeckyPlugin {
      name = "PlayTime";
      version = "2.0.9";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/a1b126a686bdd610fd8dd527592c81dd7f1a3c4da3071733b32cc2f48f74d8f0.zip";
      download_hash = "1w6qfj7z9hicncrif1x39ly1lzyxh4n5j9ymipyi1mmxhsk2dcd1";
      meta = with lib;
      {
        description = "Tracks time for Steam and non-Steam games with reports and charts";
        decky_tags = [ "playtime" "time-tracking" "utility" ];
        platforms = platforms.all;
      };
    };
    "battery_tracker" = buildDeckyPlugin {
      name = "Battery Tracker";
      version = "0.2.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/91c388d3c1b52079314045b79671ad55c767510658b6193f6936ed6cad383b94.zip";
      download_hash = "151v72nnrv9nd4zikdjq0r8ngismmmqrdds580qpj85mq79qihwi";
      meta = with lib;
      {
        description = "Battery tracker plugin";
        decky_tags = [ "root" "template" ];
        platforms = platforms.all;
      };
    };
    "wine_cellar" = buildDeckyPlugin {
      name = "Wine Cellar";
      version = "0.1.6";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/a400c89e853117e32e2fba77ef1b09d8f3e9e9d073b9af38af7c73ed525cac6d.zip";
      download_hash = "0vdcbi9fswvwmwwazfbks3lykwyq14dyyxxs5wpf65rihngch054";
      meta = with lib;
      {
        description = "A decky plugin to manage Steam Play compatibility tools";
        decky_tags = [ "boxtron" "luxtorpeda" "proton" "proton-ge" "wine" ];
        platforms = platforms.all;
      };
    };
    "microsdeck" = buildDeckyPlugin {
      name = "MicroSDeck";
      version = "0.10.11";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/49efe0879df61e65e08b1c51ddb0f8aed81755f72ad25fd0c125ca21d3936a00.zip";
      download_hash = "003ajg9j3ji5q785zliayxaign5fz2qdsl8wigh6a7pnkn3y1vs9";
      meta = with lib;
      {
        description = "A plugin to manage MicroSD cards.";
        decky_tags = [ "manager" "microsd" "sdcard" ];
        platforms = platforms.all;
      };
    };
    "screenshotuploader" = buildDeckyPlugin {
      name = "ScreenshotUploader";
      version = "0.0.3";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/60152ca9a49b3a7c4fe1ac89a2ccb3bada8c84de2c1869591e6e573165d9dd6d.zip";
      download_hash = "0vfxv5jk2mvf3rcnj61cvs28rnmsng6a52dcw57pqflvljljq5b0";
      meta = with lib;
      {
        description = "Screenshot auto uploader because valve don't do it. Upload screenshots to cloud when screenshot is taken.";
        decky_tags = [ "screenshots" "uploader" ];
        platforms = platforms.all;
      };
    };
    "emudecky" = buildDeckyPlugin {
      name = "EmuDecky";
      version = "1.0.2-1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/ff19cac1cab713e7f56bd5b850d5986cef4f2f9933303432e9c66de19868a3ce.zip";
      download_hash = "1km3d2cf2vf6x4r38c1kk4plzvvck3am1f6mdgsyf4xprb0wl6gz";
      meta = with lib;
      {
        description = "Official EmuDeck Decky plugin";
        decky_tags = [ "EmuDeck" ];
        platforms = platforms.all;
      };
    };
    "kde_connect" = buildDeckyPlugin {
      name = "KDE Connect";
      version = "0.1.0-1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/5f7decb4de48290f8eec15937486c9611aec0d25256515c97f98cf7ba30c79a4.zip";
      download_hash = "193r1jippkwqgz4iar954l6yq6k1r63794qmxj70yaa8vssfqzaz";
      meta = with lib;
      {
        description = "A plugin for running KDE Connect in gamemode";
        decky_tags = [ "control" ];
        platforms = platforms.all;
      };
    };
    "reshadeck" = buildDeckyPlugin {
      name = "Reshadeck";
      version = "0.2.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/f7f79c3f5d12d92d14adfdebad62053d6e10982fb7b662b6777cb06945dc4281.zip";
      download_hash = "10a2vi2nkc3wfyv65dmp5yc10vix0miavszxmla2vn8jblzrrxzp";
      meta = with lib;
      {
        description = "A plugin for loading reshade shaders on steam deck";
        decky_tags = [ "control" ];
        platforms = platforms.all;
      };
    };
    "cheatdeck" = buildDeckyPlugin {
      name = "CheatDeck";
      version = "0.4.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/10cef9bfbf87516f614f0b3c6ab5c7bc1c23e011b6ebb81517d33e806e1def8d.zip";
      download_hash = "13gg3mp80gnk2wavisxn27h2675wqysnlg0b9xhnylc7pyzzkkhh";
      meta = with lib;
      {
        description = "Launch games with cheat or trainer and manage your launch options.";
        decky_tags = [ "cheat" "trainer" ];
        platforms = platforms.all;
      };
    };
    "bt_wake_control" = buildDeckyPlugin {
      name = "BT Wake Control";
      version = "1.1.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/a015832b6d476666b09536325be23ae3a9caeaeaa0d130795d190ec91a5ac789.zip";
      download_hash = "12f7b8dcj3hrbmwk1ld0xbmcmag37bi5ncinjnq6crj7dlmq65d0";
      meta = with lib;
      {
        description = "Allows to selectively disable and/or enable Wake-on-Bluetooth capabilities for your Bluetooth devices.";
        decky_tags = [ "bluetooth" "utility" "wake" ];
        platforms = platforms.all;
      };
    };
    "brightness_bar" = buildDeckyPlugin {
      name = "Brightness Bar";
      version = "1.0.3";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/1f3cefe2d4c75e1042170e6500e38f44a0b5668e183abc5490cdd0ec3910500e.zip";
      download_hash = "03jh20wyrl6dj1abqfhqirkbb824izih0r8f2x110pn7skifyg0z";
      meta = with lib;
      {
        description = "Displays a customizable brightness bar when the brightness is changed with 'STEAM/QAM + LS up/down' shortcuts.";
        decky_tags = [ "brightness" "display" ];
        platforms = platforms.all;
      };
    };
    "decky_notifications" = buildDeckyPlugin {
      name = "Decky Notifications";
      version = "1.0.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/285ec32de8f18c4d5e614fc5870038cb9754f2d75cba987e5c966846b0c0aa19.zip";
      download_hash = "06daq2q4cs4nbiz9ifjwszr595yb7008giagc5g4v37ix0nw6pi8";
      meta = with lib;
      {
        description = "Receive notifications from smartphone using KDE Connect Protocol";
        decky_tags = [ "KDE Connect" "Notifications" ];
        platforms = platforms.all;
      };
    };
    "magicblack" = buildDeckyPlugin {
      name = "MagicBlack";
      version = "1.0.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/fcdd8dcce7d07632cd3613f61ad37d4591601f073ebbbaca5eb052c3b40b1d86.zip";
      download_hash = "11hx1fsc6lmhbv5bmfry0wgn14a5gp9imxhk6v6k4xnhwz68vpgw";
      meta = with lib;
      {
        description = "Overlays the screen with black color, emulating the screen being turned off on the Steam Deck OLED.";
        decky_tags = [ "black" "off" "oled" "overlay" "screen" "shortcut" ];
        platforms = platforms.all;
      };
    };
    "isthereanydeal_for_deck" = buildDeckyPlugin {
      name = "IsThereAnyDeal for Deck";
      version = "1.0.3";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/6c0926ae7f1457afe45b1bd4f02599d5d677a5562142d73dc5e5161b859ae9df.zip";
      download_hash = "1pz9ka2in5p5qlyxfhi1asjpgmnmk4jz1m0vbgjaymqlgyp2c2bc";
      meta = with lib;
      {
        description = "Shows IsThereAnyDeal data on a game's store page";
        decky_tags = [ "GameDeals" "IsThereAnyDeal" ];
        platforms = platforms.all;
      };
    };
    "magicpods" = buildDeckyPlugin {
      name = "MagicPods";
      version = "1.0.11";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/cc61ab49ee7f8f3f7b060059bdb8d95154eda06b793e11797ab719d503a3754e.zip";
      download_hash = "0kkmlc1xa6dpg9wi2gkrdfhfsm2iv6wbsn800rxkz3vzxr4snqfc";
      meta = with lib;
      {
        description = "Monitor the battery level of your AirPods and Beats. Easily switch between noise cancellation modes and enjoy the magic.";
        decky_tags = [ "airpods" "battery" "beats" "bluetooth" "headphones" ];
        platforms = platforms.all;
      };
    };
    "junk-store" = buildDeckyPlugin {
      name = "Junk-Store";
      version = "1.1.8";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/596c09481a48d78926ddd8a1b117ed8158c61b3345741327eb18a1079f8a1307.zip";
      download_hash = "01qkiaghg88qxcki6x256cdwcn41xlbv38fqvlk8kms83940jv2r";
      meta = with lib;
      {
        description = "Transform your gaming experience with Junk-Store - the ultimate solution for seamlessly integrating non-Steam games into your Steam Deck library. Say goodbye to clunky work arounds and hello to a world of endless gaming possibilities. Get ready to elevate your gaming to the next level with Junk-Store!";
        decky_tags = [ "88mph" "Epic" "Launcher" ];
        platforms = platforms.all;
      };
    };
    "decky-undervolt" = buildDeckyPlugin {
      name = "Decky-Undervolt";
      version = "1.0.8";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/2df6f8095acf2c6c71724dbbce8ebd34180880a3411f1a236b5b2143863dbc42.zip";
      download_hash = "0hmw7n3468avdciil7s1lf00h61lpn7cxfsdf9qnqb6gb84zixid";
      meta = with lib;
      {
        description = "A simple plugin that is using ryzenadj to apply Curve Optimizer to CPU.";
        decky_tags = [
          "battery-saving"
          "curve optimizer"
          "performance"
          "root"
          "ryzenadj"
          "temperature"
          "undervolt"
        ];
        platforms = platforms.all;
      };
    };
    "screensaver" = buildDeckyPlugin {
      name = "ScreenSaver";
      version = "1.1.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/03dae610f1959b5040907af24155f25fc94c3d6f273a30ecb93fc2bec25a4581.zip";
      download_hash = "10a5bb1bxhizp7n30fi7dwylrjazy9al3wksj10516wmy48fdnh3";
      meta = with lib;
      {
        description = "Inhibit screensaver during video playback.";
        decky_tags = [ "dbus" "screensaver" ];
        platforms = platforms.all;
      };
    };
    "steamdeck-input-disabler" = buildDeckyPlugin {
      name = "steamdeck-input-disabler";
      version = "1.0.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/321426191c123a354d66d5db57dc2a42eb7f3516bab24a294516b606baf94703.zip";
      download_hash = "00s7z6x0ddhn8lllmcms2qspzss25bf5gnymcr6kafhj3hcjc51j";
      meta = with lib;
      {
        description = "A plugin that lets you disable the steamdeck gamepad to prevent bugs with in game controller order and emulators not picking up the right controller.";
        decky_tags = [ "bluetooth" "controller" "fix" "root" "utility" ];
        platforms = platforms.all;
      };
    };
    "deckyspy" = buildDeckyPlugin {
      name = "DeckySpy";
      version = "0.6.7";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/2d431a89826ed5cf3fd37258373eb3b46c841c39795aa8b25f83e59f4eee87c7.zip";
      download_hash = "1iw7xr79zrc3byrahnkr74f88v5lncz3fn3jsczwzmbfha4ilhrd";
      meta = with lib;
      {
        description = "Spy on system information.";
        decky_tags = [ "utility" ];
        platforms = platforms.all;
      };
    };
    "picture_in_picture" = buildDeckyPlugin {
      name = "Picture in Picture";
      version = "1.0.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/e0115148305cd216e50bcfec8851fe3d1c6f3d36ae2f92113c199fc1bb2388e3.zip";
      download_hash = "1qw84fxw37qr7h8r4bxf6qyny71xzr8qiv6g1gjidljw614524g0";
      meta = with lib;
      {
        description = "Watch your favorite stream while you game!";
        decky_tags = [ "movies" "pip" "tv" "video" "web" ];
        platforms = platforms.all;
      };
    };
    "playcount" = buildDeckyPlugin {
      name = "PlayCount";
      version = "1.6";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/4bdc954f68df1d70ddd87f39085d4e7c0f87ee24689536818ec3ca89b0298d0c.zip";
      download_hash = "034d56q8kjn3is0kd5b84kp8f3vw9rfhhfbzv3fp07fzd17rbp2b";
      meta = with lib;
      {
        description = "A Steam Deck plugin that shows current player counts for your steam games.";
        decky_tags = [
          "Currently Playing"
          "Player Count"
          "Steam Charts"
          "SteamDB"
        ];
        platforms = platforms.all;
      };
    };
    "crosshair" = buildDeckyPlugin {
      name = "Crosshair";
      version = "1.0.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/49f3afe815e5527d4ff12e2278a5652c6a2efaa342f468fd0c2bb7b3039d1eb8.zip";
      download_hash = "1f0ykl1v7drb1kynix22lgx2wsiccnjph8ify57pslp52plazws9";
      meta = with lib;
      {
        description = "Repurpose the performance overlay into a customizable crosshair.";
        decky_tags = [ "aim" "crosshair" "HUD" "overlay" ];
        platforms = platforms.all;
      };
    };
    "deck_settings" = buildDeckyPlugin {
      name = "Deck Settings";
      version = "1.1.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/865e094fc4b66465cae73930b64cd2df724e722f072a427e9fb821b5912da234.zip";
      download_hash = "0d525n8va8dqkxz44ah75xr4wwnzs96bcc1rwz56ar5nqi7hjpl6";
      meta = with lib;
      {
        description = "Fetch and display community-driven game compatibility, settings, and configuration reports.";
        decky_tags = [
          "config"
          "deckverified"
          "game"
          "settings"
          "setup"
          "verified"
        ];
        platforms = platforms.all;
      };
    };
    "decky_dot_dns" = buildDeckyPlugin {
      name = "Decky DoT DNS";
      version = "0.0.2";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/0e9ffd3ccc07b12f64541129189fe84184efb9242373d01fbc90395f4d6bfbbc.zip";
      download_hash = "1g7vdd6myfchphgx0wr34jwyz121x2giha8iaij2zc87rhygv7qf";
      meta = with lib;
      {
        description = "A plugin to override the systemd-resolved config from Decky.";
        decky_tags = [ "dns" "networking" "root" ];
        platforms = platforms.all;
      };
    };
    "decky-spoofdpi" = buildDeckyPlugin {
      name = "Decky-SpoofDPI";
      version = "0.12.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/e37d613ffab3096517aeafd176ab04d86e9c97ea42d32b9eacd6ba1d2bf873ab.zip";
      download_hash = "1avkz0mivfnnmjg2pls2xabrqvnq0jmpdldgmqbna2dkz8zn2zg3";
      meta = with lib;
      {
        description = "An anti-censorship plugin for Decky Loader. This plugin is a wrapper around SpoofDPI for Game Mode";
        decky_tags = [ "deep-packet-inspection" "networking" "spoofdpi" ];
        platforms = platforms.all;
      };
    };
    "simple_timer" = buildDeckyPlugin {
      name = "Simple Timer";
      version = "1.0.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/973d927e9d9a1feec04679c564af7e389a729b6735d2a988ffc2cb46ce4eb312.zip";
      download_hash = "04mk9v74djy2zy4aklimcydp56iqgspn9ibr8v0fw7wskmz94gcp";
      meta = with lib;
      {
        description = "Set a timer that will remind you when your session should end.";
        decky_tags = [ "alarm" "decktools" "timer" ];
        platforms = platforms.all;
      };
    };
    "decky-framegen" = buildDeckyPlugin {
      name = "Decky-Framegen";
      version = "0.9.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/163a42f85f95abd7a51350075017ef53e17c02181304375659bf5e7e98bb920e.zip";
      download_hash = "03ljpfc7wpmzb5b3f10k3017rqakxwbm01sh2fjxgawmbzw44fhn";
      meta = with lib;
      {
        description = "Allows using FSR for upscaling and frame generation in games with DLSS support. Uses DLSS Enabler and Optiscaler.";
        decky_tags = [ "DLSS" "Framegen" "FSR" "upscaling" ];
        platforms = platforms.all;
      };
    };
    "decky-lookup" = buildDeckyPlugin {
      name = "Decky-Lookup";
      version = "0.1.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/49309a02fa028d26c77230cc9f70fec9bcce91d59e887bfe8f9d3e42f8a19139.zip";
      download_hash = "0fcil7w44glxizz7p24ysn8wxg69zrq9zk1hfb3jd382z819lc29";
      meta = with lib;
      {
        description = "A plugin to quickly access useful sites for the running game.";
        decky_tags = [ "browser" "Lookup" "search" "website" ];
        platforms = platforms.all;
      };
    };
    "decky_zerotier" = buildDeckyPlugin {
      name = "Decky Zerotier";
      version = "0.3.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/4cacfcf96b11b423af41ec57cea915e26a0dac42fc03432dad1fcded135781a2.zip";
      download_hash = "18l1aw9yvk8zmlnl60zw8an0ssp22nlwwmzc86pj7d0idgwzrb2c";
      meta = with lib;
      {
        description = "A Decky plugin for Zerotier";
        decky_tags = [ "network" "zerotier" ];
        platforms = platforms.all;
      };
    };
    "virtual_surround_sound" = buildDeckyPlugin {
      name = "Virtual Surround Sound";
      version = "0.0.5";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/b6c514d147cc46bad5331ca9da36628eb9c330976e13735687499a4a9f17f6d4.zip";
      download_hash = "1m7n2yglm6j9hxb764vfjwqc7fcfc8vdma8w6gavlinc8z8i9idn";
      meta = with lib;
      {
        description = "Create a virtual surround sound audio sink that converts 7.1 surround audio into immersive binaural output for headphones via HRIR processing with multiple presets (Atmos, DTS, Steam, Razer, etc.).";
        decky_tags = [
          "5.1"
          "7.1"
          "atmos"
          "audio"
          "binaural"
          "dolby"
          "dts"
          "headphones"
          "surround"
        ];
        platforms = platforms.all;
      };
    };
    "xivomega" = buildDeckyPlugin {
      name = "XIVOmega";
      version = "0.2.1";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/dcc1a6b507c99cf299212e8cf919df92e883ddf3b845f24de5942e50cf2492ca.zip";
      download_hash = "1jlj4k7m0bllwm6z4idqygfq7s4jvwczk31f46cz57690yssdhfw";
      meta = with lib;
      {
        description = "Latency Mitigator for the Critically Acclaimed MMORPG Final Fantasy XIV - based on XivMitmLatencyMitigator, XivAlexander and XivMitmDocker.";
        decky_tags = [
          "final-fantasy-xiv"
          "root"
          "XivAlexander"
          "XivMitmLatencyMitigator"
          "XivOmega"
        ];
        platforms = platforms.all;
      };
    };
    "decksp" = buildDeckyPlugin {
      name = "DeckSP";
      version = "1.0.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/a45def7332897a3790ba67f0777c9406e34bdfecdddf8a5b9588c151eb8ec915.zip";
      download_hash = "05f9ivmm3hc8jmdqmpyxxkglpqq6jiy7gw37pa83fyl969ryypd4";
      meta = with lib;
      {
        description = "Full audio effects DSP. EQ, Reverb and much more. Per-game settings possible.";
        decky_tags = [
          "audio"
          "compressor"
          "dsp"
          "effects"
          "eq"
          "equalizer"
          "fx"
          "reverb"
          "sound"
        ];
        platforms = platforms.all;
      };
    };
    "decky_ludusavi" = buildDeckyPlugin {
      name = "Decky Ludusavi";
      version = "1.0.0";
      url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/905caa1d314ee2dd0520da831d611e3aba3a183815ef278d2ba0183938400566.zip";
      download_hash = "0rh580w3j6505f6jgvqm70c3mfis3rhiv0ys402xvqjf64fslp4h";
      meta = with lib;
      {
        description = "Ludusavi for Decky. Backup, restore, and keep multiple versions of your save files with ease! Requires Ludusavi installation on the device.";
        decky_tags = [ "backup" "cloud" "ludusavi" "sync" ];
        platforms = platforms.all;
      };
    };
  }