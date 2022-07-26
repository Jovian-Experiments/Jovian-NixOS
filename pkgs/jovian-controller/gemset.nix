{
  ffi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1862ydmclzy1a0cjbvm8dz7847d9rch495ib0zb64y84d3xd4bkg";
      type = "gem";
    };
    version = "1.15.5";
  };
  hexdump = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1787w456yzmy4c13ray228n89a5wz6p6k3ibssjvy955qlr44b7g";
      type = "gem";
    };
    version = "1.0.0";
  };
  libusb = {
    dependencies = ["ffi" "mini_portile2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "005q4f3bi68yapza1vxamgwz2gpix2akci52s4yvr03hsxi137a6";
      type = "gem";
    };
    version = "0.6.4";
  };
  linux_input = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cwbq590hgmpfpwjsjq8cqbqd1j0ygs3ib6ncycsg622xr3fgy85";
      type = "gem";
    };
    version = "1.1.1";
  };
  mini_portile2 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rapl1sfmfi3bfr68da4ca16yhc0pp93vjwkj7y3rdqrzy3b41hy";
      type = "gem";
    };
    version = "2.8.0";
  };
  uinput = {
    dependencies = ["linux_input"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16503hskym9z0yk2wlk055kikfnm3hvmshidx2g5c5jy6nvh931m";
      type = "gem";
    };
    version = "1.2.0";
  };
  uinput-device = {
    dependencies = ["uinput"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18k205fjhd16qwd0wcrkig2z0g39bsxh3k4rhyjrvkm1c1cb42kk";
      type = "gem";
    };
    version = "0.4.0";
  };
}
