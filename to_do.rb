require "sinatra"
require "gschool_database_connection"
require "rack-flash"

class ToDo < Sinatra::Application
  def initialize
    super
    GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    "Hello"
  end
end

