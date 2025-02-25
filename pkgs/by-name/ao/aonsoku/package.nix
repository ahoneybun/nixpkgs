{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  pkg-config,
  webkitgtk_4_0,
  }:

stdenv.mkDerivation (finalAttrs: {
  pname = "aonsoku";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "victoralvesf";
    repo = "aonsoku";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-A1U1ubprwYJvyqTe5gVYTo8687sfP/76GfA+2EmtoCo=";
  };

  nativeBuildInputs = [
    pnpm.configHook
  ];

  buildInputs = [
    nodejs
    webkitgtk_4_0
  ];

  buildPhase = ''
    runHook preBuild

    pnpm install --ignore-scripts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    #cp ./dist/aonsoku $out/bin

    runHook postInstall
  '';

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-BMEBJRycmOgsI1loTPTNY1dVOJ0HTCnzg0QyNAzZMn4=";
  };

  meta = {
    description = "A modern desktop client for Navidrome/Subsonic servers built with React and Rust.";
    homepage = "https://aonsoku.vercel.app/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "aonsoku";
    maintainers = with lib.maintainers; [ ahoneybun ];
  };
})
