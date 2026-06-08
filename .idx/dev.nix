{ pkgs, ... }: {

  channel = "stable-24.11";

  packages = [
  pkgs.flutter
  pkgs.cmake
  pkgs.clang
  pkgs.ninja
  pkgs.pkg-config
  pkgs.gtk3
  pkgs.pango
  pkgs.glib
  pkgs.cairo
  pkgs.gdk-pixbuf
  pkgs.libGL
  pkgs.mesa
];

  env = {
  PKG_CONFIG_PATH =
    "${pkgs.gtk3.dev}/lib/pkgconfig:"
    + "${pkgs.pango.dev}/lib/pkgconfig:"
    + "${pkgs.glib.dev}/lib/pkgconfig:"
    + "${pkgs.cairo.dev}/lib/pkgconfig:"
    + "${pkgs.gdk-pixbuf.dev}/lib/pkgconfig";
};

}