require 'dicom'
require 'mongo'
require 'json'
include DICOM
include Mongo

MONGO_SERVER = "localhost"
MONGO_PORT = 27017
DB_NAME = "dicom"
DICOM_TABLE_NAME = "dicomCollection"

db = MongoClient.new(MONGO_SERVER, MONGO_PORT).db(DB_NAME)
dicomTable = db[DICOM_TABLE_NAME]
dicomTable.remove

class Stream
	def write(binary)
		dicomTable.insert("name" => "dicom1", "dcm" => BSON::Binary.new(binary))
		dicomTable.each {|row| puts row}
	end
end

SCP_PORT = 10000
dicomServer = DServer.new(SCP_PORT)
dicomServer.start_scp()