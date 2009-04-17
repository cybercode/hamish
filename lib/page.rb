require 'maruku'
require 'haml'
require 'fileutils'
require File.dirname(__FILE__) + '/helpers.rb'

class Page
  attr_reader :content
  attr_reader :attributes
  attr_reader :name
  attr_reader :source
  attr_accessor :destination
  
  def initialize file
    @source = file
    @name, type = basename file
    begin
      @content, @attributes = send(type, file)
    rescue NoMethodError
      raise "Unknown  type #{type} for #{file}"
    end
  end

  def method_missing(meth, *args)
     if meth.to_s =~ /=$/
       attributes[meth.to_s[0...-2].to_sym] = args.length < 2 ? args[0] : args
     else
       attributes[meth]
     end
  end
  
  private
  def markdown file
    engine = Maruku.new(File.read(file))

    return engine.to_html, engine.attributes
  end

  def haml file
    engine=Haml::Engine.new(File.read(file))
    helper = Helpers.new
    content = engine.render(helper)

    attributes={ }
    helper.instance_variables.each do |v|
      next if v =~ /^@(_|haml)/
      sym = v.to_s[1..-1].intern
      attributes[sym] = helper.instance_variable_get(v)
    end
    return content, attributes
  end

  def basename file
    ext = File.extname(file)
    base = File.basename(file, ext)

    return [base, ext[1..-1]]
  end
end
