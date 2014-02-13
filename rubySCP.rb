# Starts ruby dicom scp, stores files in C:\pkgs

require 'dicom'
include DICOM
port = 2020


dicomServer = DServer.new(port)
dicomServer.start_scp('C:\pkgs') do |handler|
	handler.timeout = 100
	