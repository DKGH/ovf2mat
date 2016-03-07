function [] = ovf2Mat(configFile)

omhConfig = getKvpConfig(configFile);

%% Check project configuration version support
supportedDotMagProjVersions = {'1'};
checkVersion(omhConfig, supportedDotMagProjVersions)

%% Obtaining essential variables
path = omhConfig.path;
extension = omhConfig.extension;
xNodes = omhConfig.xNodes;
yNodes = omhConfig.yNodes;
zNodes = omhConfig.zNodes;
l = logger(omhConfig.logger);
cl = onCleanup(@() delete(l));

%% Getting hold of the files
cd(path);
if (extension(1) == '*')
  ovfFiles = dir(extension);
else
  ovfFiles = dir((['*.', extension]));
end
tNodes = size(ovfFiles, 1);
if (tNodes == 0)
  return;
end

%% Computing memory and size parameters
% Hack for NUS HPC. There is a 200 GB quota and I wish 80 such variables
% to be fitting comfortably in there.
roughSize = 80*8*xNodes*yNodes*zNodes;
N = floor(200*1024*1024*1024/roughSize);
clear roughSize;
% memory function can be used for platforms where it is supported
% unit = zeros(xNodes, yNodes, zNodes);
% whosUnit = whos('unit');
% unitBytes = whosUnit.bytes;
% m = memory;
% N = ceil((m.MaxPossibleArrayBytes/80)/unitBytes);

%% Converting
partsCount = floor(tNodes/N);
for i = 1 : partsCount
  convert(ovfFiles((i - 1)*N + 1:i*N), i, xNodes, yNodes, zNodes, l, ...
    omhConfig);
end
if (mod(tNodes, N) ~= 0)
  convert(ovfFiles(partsCount*N + 1:tNodes), partsCount + 1, xNodes, ...
    yNodes, zNodes, l, omhConfig);
end


%% Conversion subfunction
function [] = convert(ovfFiles, partCount, xNodes, yNodes, ...
  zNodes, l, omhConfig)

%% Obtaining essential variables
bin = logical(omhConfig.bin);
doI = logical(omhConfig.doI);
doJ = logical(omhConfig.doJ);
doK = logical(omhConfig.doK);

%% Preparing components
tNodesLocal = length(ovfFiles);
if (doI)
  I = zeros(tNodesLocal, xNodes, yNodes, zNodes);
end
if (doJ)
  J = zeros(tNodesLocal, xNodes, yNodes, zNodes);
end
if (doK)
  K = zeros(tNodesLocal, xNodes, yNodes, zNodes);
end
%%

%% Reading
for i = 1 : tNodesLocal
  l.logIt(['Reading ', ovfFiles(i).name]);
  if (bin)
    itHasBegun8 = [];
    itHasBegun4 = [];
    file = fopen(ovfFiles(i).name);
    while (isempty(itHasBegun8) && isempty(itHasBegun4))
      line = fgetl(file);
      itHasBegun8 = strfind(line, 'Data Binary 8');
      itHasBegun4 = strfind(line, 'Data Binary 4');
    end
    if (isempty(itHasBegun8))
      typeStr = '*single';
    else
      typeStr = '*double';
    end
    binData = fread(file, 3*xNodes*yNodes*zNodes + 1, typeStr);
    fclose(file);
    ijkData = reshape(binData(2:end), [3 xNodes*yNodes*zNodes]);
    if (doI)
      I(i, :, :, :) = reshape(ijkData(1, :), xNodes, yNodes, zNodes);
    end
    if (doJ)
      J(i, :, :, :) = reshape(ijkData(2, :), xNodes, yNodes, zNodes);
    end
    if (doK)
      K(i, :, :, :) = reshape(ijkData(3, :), xNodes, yNodes, zNodes);
    end
  else
    file = fopen(ovfFiles(i).name);
    T = textscan(file, '%f %f %f', 'MultipleDelimsAsOne', 1, ...
      'CommentStyle', '#');
    fclose(file);
    if (doI)
      I(i, :, :, :) = reshape(T{1}, xNodes, yNodes, zNodes);
    end
    if (doJ)
      J(i, :, :, :) = reshape(T{2}, xNodes, yNodes, zNodes);
    end
    if (doK)
      K(i, :, :, :) = reshape(T{3}, xNodes, yNodes, zNodes);
    end
  end
end

%% Making names
if (doI)
  iFileName = ['iPart', num2str(partCount, '%05g'), '.mat'];
end
if (doJ)
  jFileName = ['jPart', num2str(partCount, '%05g'), '.mat'];
end
if (doK)
  kFileName = ['kPart', num2str(partCount, '%05g'), '.mat'];
end

%% Saving
if (doI)
  l.logIt(['Writing ', iFileName,'...']);
  save(iFileName, 'I', '-v7.3');
  clear I;
end
if (doJ)
  l.logIt(['Writing ', jFileName,'...']);
  save(jFileName, 'J', '-v7.3');
  clear J;
end
if (doK)
  l.logIt(['Writing ', kFileName,'...']);
  save(kFileName, 'K', '-v7.3');
  clear K;
end