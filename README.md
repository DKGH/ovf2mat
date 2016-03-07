# ovf2mat
Processes OOMMF vector format 2.0 data into 7.3 MATLAB format binary
Usage:
  ovf2mat(configFileName)
  
Parameter:
  config: Name of the config file which contains details like:
      version: Config file version. This should be 1 in order for the config file to work with this version of the uploaded ovf2mat tool.
      path: Path where the OVF 2.0 files are stored.
      logger: Path where the conversion details will be logged.
      extension: Extension of the OVF 2.0 files.
      xNodes, yNodes, zNodes: Number of nodes along the x, y, and z axes.
      bin: 1 if the data is binary. 0 otherwise.
      doI, doJ, doK: Which of the three components of the vector field to extract.
  
Remarks:
  Alphabetical order should match simulation chronological order of 'ext' files for compatibility with processing tools.
