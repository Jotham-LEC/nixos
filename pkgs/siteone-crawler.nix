{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "siteone-crawler";
  version = "2.5.1";
  src = fetchurl {
    url = "https://github.com/janreges/siteone-crawler/releases/download/v${finalAttrs.version}/siteone-crawler-v${finalAttrs.version}-linux-musl-x64.tar.gz";
    hash = "sha256-vZa5UCVjrqJYH8JIYlhx5ptg1/G7aKSE8ibFUcc3Bv0=";
  };
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 siteone-crawler "$out/bin/siteone-crawler"
    runHook postInstall
  '';
  meta = {
    description = "SiteOne Crawler — SEO/accessibility/security website analyser and report generator";
    homepage = "https://github.com/janreges/siteone-crawler";
    license = lib.licenses.mit;
    mainProgram = "siteone-crawler";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
