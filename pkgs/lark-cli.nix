{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lark-cli";
  version = "1.0.95";
  src = fetchurl {
    url = "https://github.com/larksuite/cli/releases/download/v${finalAttrs.version}/lark-cli-${finalAttrs.version}-linux-amd64.tar.gz";
    hash = "sha256-faktQmt9AAkIx2o2uHp9A1fCcN6/THFJu8YBCyDSVB4=";
  };
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 lark-cli "$out/bin/lark-cli"
    runHook postInstall
  '';
  meta = {
    description = "Lark/Feishu CLI — manage calendar, messaging, docs and Base from the terminal";
    homepage = "https://github.com/larksuite/cli";
    license = lib.licenses.mit;
    mainProgram = "lark-cli";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
