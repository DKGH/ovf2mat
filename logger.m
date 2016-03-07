classdef logger
  properties (SetAccess = private)
    fileName
  end
  methods
    function obj = logger(fileName_)
      obj.fileName = fileName_;
      fclose(fopen(obj.fileName, 'w'));
      obj.logIt('Logging started');
    end
    function logIt(obj, logData)
      fid = fopen(obj.fileName, 'a');
      fprintf(fid, [num2str(clock, '%d %02d %02d %02d %02d %07.4f'), ': ', logData, '\n']);
      fclose(fid);
    end
    function delete(obj)
      obj.logIt('Logging finished');
    end
  end
end