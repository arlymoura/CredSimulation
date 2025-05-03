# app/services/application_service.rb
class ApplicationService
  attr_reader :data

  def self.call(...)
    new(...).call
  end

  def call
    raise NotImplementedError, "#{self.class.name} must implement the instance method `call`"
  end

  def success(data = {})
    Result.new(true, data)
  end

  def failure(data = {})
    Result.new(false, data)
  end

  class Result
    attr_reader :data

    def initialize(success, data = {})
      @success = success
      @data = data
    end

    def success?
      @success
    end

    def failure?
      !@success
    end
  end
end
