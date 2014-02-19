# Starts ruby dicom scp, stores files in C:\pkgs

require 'dicom'
include DICOM
port = 2020

class FileHandler
    def self.receive_files(path, objects, transfer_syntaxes)
      all_success = true
      successful, too_short, parse_fail, handle_fail = 0, 0, 0, 0
      total = objects.length
      message = nil
      messages = Array.new
      # Process each DICOM object:
      objects.each_index do |i|
        if objects[i].length > 8
          # Temporarily increase the log threshold to suppress messages from the DObject class:
          server_level = DICOM.logger.level
          DICOM.logger.level = Logger::FATAL
          # Parse the received data string and load it to a DICOM object:
          dcm = DObject.parse(objects[i], :no_meta => true, :syntax => transfer_syntaxes[i])
          # Reset the logg threshold:
          DICOM.logger.level = server_level
          if dcm.read?
            begin
			messages << [:info, "METHOD OVERRIDDEN"]
              message = self.save_file(path, dcm, transfer_syntaxes[i])
              successful += 1
            rescue
              handle_fail += 1
              all_success = false
              messages << [:error, "Saving file failed!"]
            end
          else
            parse_fail += 1
            all_success = false
            messages << [:error, "Invalid DICOM data encountered: The received string was not parsed successfully."]
          end
        else
          too_short += 1
          all_success = false
          messages << [:error, "Invalid data encountered: The received string was too small to contain any DICOM data."]
        end
      end
      # Create a summary status message, when multiple files have been received:
      if total > 1
        if successful == total
          messages << [:info, "All #{total} DICOM files received successfully."]
        else
          if successful == 0
            messages << [:warn, "All #{total} received DICOM files failed!"]
          else
            messages << [:warn, "Only #{successful} of #{total} DICOM files received successfully!"]
          end
        end
      else
        messages = [message] if all_success
      end
      return all_success, messages
    end
end


dicomServer = DServer.new(port)
dicomServer.start_scp('C:\pkgs')
$end


