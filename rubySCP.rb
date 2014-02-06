# Starts ruby dicom scp, stores files in C:\pkgs

require 'dicom'
include DICOM

s = DServer.new
s.start_scp('C:\pkgs')