function [config] = getKvpConfig(configFile)

file = fopen(configFile);
T = textscan(file, '%q %q', 'CommentStyle', '%', 'Delimiter', ' ', ...
  'MultipleDelimsAsOne', 1);
fclose(file);

try
  for i = 1 : length(T{1})
    fieldName = T{1}{i}(T{1}{i} ~= ':');
    fieldValue = T{2}{i};
    if (isempty(fieldValue))
      continue;
    end
    try
      eval([fieldName, ' = ', fieldValue, ';']);
    catch
      fieldValue = ['''', fieldValue, ''''];
      eval([fieldName, ' = ', fieldValue, ';']);
    end
  end
catch
  error('DotMag:BadConfig', ['Bad config: ', fieldName, ' = ', ...
    fieldValue]);
end

config = genConfig;