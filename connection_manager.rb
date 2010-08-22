require 'sequel'

class ConnectionManager
  class << self
    attr_accessor :db
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    open_connection_if_necessary!
    @app.call(env)
  end

  # need this to connect within rake
  def self.manual_connect!

    # fake rack app for call's sake
    app = Class.new
    def app.call(env)
    end

    ConnectionManager.new(app).call({})
  end

protected

  def open_connection_if_necessary!
    self.class.db ||= begin
      add_finalizer_hook!
      Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://notifyre.db')
    end
  end

  def add_finalizer_hook!
    at_exit do
      begin
        self.class.db.disconnect
      rescue Exception => e
        puts "Error closing Sequel connection. You might have to clean up manually."
      end
    end
  end
end


