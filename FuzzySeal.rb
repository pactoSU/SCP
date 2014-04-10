require 'dicom'
require 'mongo'
require 'json'
include DICOM
include Mongo


class MongoIX
	def initialize(host, port, db_name, db_table_name)
		@db = MongoClient.new(host, port).db(db_name)
		@table = db[db_table_name]
	end
	
	def insert_dcm(dcm)
		hash = dcm.to_hash
		json = hash.to_json
		
		cereal = Marshal::dump(dcm)
		binDat = BSON::Binary.new(cereal)
		
		@table.insert("name" => "dicom1", "raw" => binDat)
	end
	
	def print()
		@table.find.each { |row| puts row }
	end
end

class FileHandler
	def self.receive_files(db, objects, transfer_syntaxes)
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
							puts "adding to mongo"
							db.insert_dcm(dcm)
							db.print()
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

MONGO_SERVER = "localhost"
MONGO_PORT = 27017
DB_NAME = "dicom"
DICOM_TABLE_NAME = "dicomCollection"

db = MongoIX.new(MONGO_SERVER, MONGO_PORT, DB_NAME, DB_TABLE_NAME)

class Stream
	def write(binary)
		dicomTable.insert("name" => "dicom1", "dcm" => BSON::Binary.new(binary))
		dicomTable.each {|row| puts row}
	end
end

SCP_PORT = 10000
dicomServer = DServer.new(SCP_PORT)
dicomServer.start_scp()
