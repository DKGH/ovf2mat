function [] = checkVersion(projConfig, supportedDotMagProjVersions)

if(~ismember(supportedDotMagProjVersions, projConfig.version))
  error('DotMag:badProjVer', 'Version %s is not supported', ...
    projConfig.version);
end
  