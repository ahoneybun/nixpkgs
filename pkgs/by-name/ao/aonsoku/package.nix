{
  lib,
  cargo-tauri,
  dbus,
  fetchFromGitHub,
  freetype,
  gsettings-desktop-schemas,
  glib,
  nodejs,
  pnpm,
  typescript,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  libayatana-appindicator,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage rec {
  pname = "aonsoku";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "victoralvesf";
    repo = "aonsoku";
    rev = "refs/tags/v${version}";
    hash = "sha256-A1U1ubprwYJvyqTe5gVYTo8687sfP/76GfA+2EmtoCo=";
    fetchLFS = true;
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-yuKaf05bQFah3MTC0eF82pMmTJrllWfUKX3SdIWbPjM=";

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-BMEBJRycmOgsI1loTPTNY1dVOJ0HTCnzg0QyNAzZMn4=";
  };

#  postPatch = ''
#    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
#      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
#  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpm
    typescript
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    dbus
    openssl
    freetype
    webkitgtk_4_1
    libayatana-appindicator
    gsettings-desktop-schemas
  ];

  buildPhase = ''
    runHook preBuild
    ln -s ${pnpmDeps}/node_modules .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mv src-tauri/target/release/aonsoku $out/bin/  # Ensure this matches the correct binary name

    mkdir -p $out/share/aonsoku
    cp -r dist $out/share/aonsoku/
     runHook postInstall
  '';

  cargoRoot = "src-tauri";
  buildAndTestSubdir = cargoRoot;

  # WEBKIT_DISABLE_COMPOSITING_MODE essential in NVIDIA + compositor https://github.com/NixOS/nixpkgs/issues/212064#issuecomment-1400202079
#  postFixup = ''
#    wrapProgram "$out/bin/treedome" \
#      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
#  '';

  meta = with lib; {
    description = "Local-first, encrypted, note taking application organized in tree-like structures";
    homepage = " https://codeberg.org/solver-orgz/treedome";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ahoneybun ];
  };
}
