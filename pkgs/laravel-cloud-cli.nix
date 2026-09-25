{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  php,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "laravel-cloud-cli";
  version = "0.5.2";
  src = fetchFromGitHub {
    owner = "laravel";
    repo = "cloud-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-exgfm/ACtL6evvsCkNE3Yafpi9Hlk27L1ebwOrw0f/w=";
  };
  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm644 builds/cloud "$out/share/laravel-cloud-cli/cloud.phar"
    makeWrapper ${lib.getExe php} "$out/bin/cloud" \
      --add-flags "$out/share/laravel-cloud-cli/cloud.phar"
    runHook postInstall
  '';
  meta = {
    description = "Laravel Cloud CLI — deploy and manage Laravel Cloud apps from the terminal";
    homepage = "https://cloud.laravel.com/docs/api/cli";
    license = lib.licenses.mit;
    mainProgram = "cloud";
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.linux;
  };
})
