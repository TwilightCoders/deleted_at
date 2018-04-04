require 'thread'

Thread.class_eval do
  def self.reverb(verb, value)
    __reverb_previous__, Thread.current[verb] = Thread.current[verb], value
    yield if block_given?
  ensure
    Thread.current[verb] = __reverb_previous__
  end
end
