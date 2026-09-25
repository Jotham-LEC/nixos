{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "laravel-lsp";
  version = "0.0.31";
  src = fetchurl {
    url = "https://github.com/laravel/lsp/releases/download/v${finalAttrs.version}/server-v${finalAttrs.version}-x64-linux";
    hash = "sha256-z4Ftro0baMSh9yiORiVzKj+H3w3M31oGfn4xW5ZDyII=";
  };
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/laravel-lsp"
    runHook postInstall
  '';
  meta = {
    description = "First-party framework-aware language server for Laravel";
    homepage = "https://github.com/laravel/lsp";
    license = lib.licenses.mit;
    mainProgram = "laravel-lsp";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
