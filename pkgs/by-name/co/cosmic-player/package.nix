{ lib
, alsa-lib
, cosmic-icons
, fetchFromGitHub
, ffmpeg_5-full
, fontconfig
, freetype
, just
, llvmPackages_15
, libglvnd
, libinput
, libxkbcommon
, makeBinaryWrapper
, mesa
, pkg-config
, rustPlatform
, stdenv
, vulkan-loader
, wayland
, xorg
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-player";
  version = "0-unstable-2024-01-25";
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = pname;
    rev = "4650e1434d875235cbb5350cb1b99e1eabf0b46f";
    hash = "sha256-CflLeu2od5k5RD6tg4UiXtjkQurFAJ9LKN2+yBx8ZQg=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "accesskit-0.11.0" = "sha256-xVhe6adUb8VmwIKKjHxwCwOo5Y1p3Or3ylcJJdLDrrE=";
      "atomicwrites-0.4.2" = "sha256-QZSuGPrJXh+svMeFWqAXoqZQxLq/WfIiamqvjJNVhxA=";
      "cosmic-config-0.1.0" = "sha256-MyEevxY7U1kLO6nDahPiz8wUjT2en9Ld3Qt6Xv2ycRg=";
      "cosmic-text-0.10.0" = "sha256-wrz6fYlWiVDUDvLWxnd5BG+zw8R+1oniN8hJoZDDd7Q=";
      "glyphon-0.4.1" = "sha256-mwJXi63LTBIVFrFcywr/NeOJKfMjQaQkNl3CSdEgrZc=";
      "sctk-adwaita-0.5.4" = "sha256-yK0F2w/0nxyKrSiHZbx7+aPNY2vlFs7s8nu/COp2KqQ=";
      "smithay-client-toolkit-0.16.1" = "sha256-z7EZThbh7YmKzAACv181zaEZmWxTrMkFRzP0nfsHK6c=";
      "softbuffer-0.3.3" = "sha256-eKYFVr6C1+X6ulidHIu9SP591rJxStxwL9uMiqnXx4k=";
      "taffy-0.3.11" = "sha256-SCx9GEIJjWdoNVyq+RZAGn0N71qraKZxf9ZWhvyzLaI=";
      "winit-0.28.6" = "sha256-FhW6d2XnXCGJUMoT9EMQew9/OPXiehy/JraeCiVd76M=";
    };
  };

  postPatch = ''
    substituteInPlace justfile --replace '#!/usr/bin/env' "#!$(command -v env)"
  '';

  nativeBuildInputs = [
    just
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = [
    alsa-lib
    ffmpeg_5-full
    fontconfig
    freetype
    llvmPackages_15.llvm
    llvmPackages_15.clang
    llvmPackages_15.libclang
    libglvnd
    libinput
    libxkbcommon
    vulkan-loader
    wayland
    xorg.libX11
  ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-player"
  ];

  # Force linking to libEGL, which is always dlopen()ed, and to
  # libwayland-client, which is always dlopen()ed except by the
  # obscure winit backend.
  RUSTFLAGS = map (a: "-C link-arg=${a}") [
    "-Wl,--push-state,--no-as-needed"
    "-lEGL"
    "-lwayland-client"
    "-Wl,--pop-state"
  ];

  # LD_LIBRARY_PATH can be removed once tiny-xlib is bumped above 0.2.2
  postInstall = ''
    wrapProgram "$out/bin/${pname}" \
      --suffix XDG_DATA_DIRS : "${cosmic-icons}/share" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        libxkbcommon
        mesa.drivers
        vulkan-loader
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
      ]} \
      --prefix LIBCLANG_PATH = "${llvmPackages_15.libclang.lib}/lib";
  '';

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-player";
    description = "Media Player for the COSMIC Desktop Environment";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ahoneybun nyanbinary ];
    platforms = platforms.linux;
    mainProgram = "cosmic-player";
  };
}
