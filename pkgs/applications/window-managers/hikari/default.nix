{ lib, stdenv, fetchzip, fetchpatch,
  pkg-config, bmake,
  cairo, glib, libevdev, libinput, libxkbcommon, linux-pam, pango, pixman,
  libucl, wayland, wayland-protocols, wlroots, mesa,
  features ? {
    gammacontrol = true;
    layershell   = true;
    screencopy   = true;
    xwayland     = true;
  }
}:

let
  pname = "hikari";
  version = "2.3.0";
in

stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://hikari.acmelabs.space/releases/${pname}-${version}.tar.gz";
    sha256 = "0vxwma2r9mb2h0c3dkpvf8dbrc2x2ykhc5bb0vd72sl9pwj4jxmy";
  };

  patches = [
    # To fix the build with wlroots 0.14.0:
    (fetchpatch {
      url = "https://cgit.freebsd.org/ports/plain/x11-wm/hikari/files/patch-wlroots-0.14?id=f2820b6cc2170feef17989c422f2cf46644a5b57";
      sha256 = "1kpbcmgdm4clmf2ryrs5pv3ghycnq4glvs3d3ll6zr244ks5yf43";
      extraPrefix = "";
    })
  ];

  nativeBuildInputs = [ pkg-config bmake ];

  buildInputs = [
    cairo
    glib
    libevdev
    libinput
    libxkbcommon
    linux-pam
    pango
    pixman
    libucl
    mesa # for libEGL
    wayland
    wayland-protocols
    wlroots
  ];

  enableParallelBuilding = true;

  makeFlags = with lib; [ "PREFIX=$(out)" ]
    ++ optional stdenv.isLinux "WITH_POSIX_C_SOURCE=YES"
    ++ mapAttrsToList (feat: enabled:
         optionalString enabled "WITH_${toUpper feat}=YES"
       ) features;

  postPatch = ''
    # Can't suid in nix store
    # Run hikari as root (it will drop privileges as early as possible), or create
    # a systemd unit to give it the necessary permissions/capabilities.
    substituteInPlace Makefile --replace '4555' '555'

    sed -i 's@<drm_fourcc.h>@<libdrm/drm_fourcc.h>@' src/*.c
  '';

  meta = with lib; {
    description = "Stacking Wayland compositor which is actively developed on FreeBSD but also supports Linux";
    homepage    = "https://hikari.acmelabs.space";
    license     = licenses.bsd2;
    platforms   = platforms.linux ++ platforms.freebsd;
    maintainers = with maintainers; [ jpotier ];
  };
}
