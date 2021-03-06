require 'yaml'
require 'maruku'
require 'haml'
require 'fileutils'
require File.dirname(__FILE__) + '/helpers.rb'

module Hamish
  class Page
    attr_reader :attributes
    attr_reader :name
    attr_reader :source
    attr_accessor :destination

    def initialize(file, attrs = { })
      @source = file
      @name, type = basename file
      @data = File.read(file)
      @attributes=attrs
      @attributes.merge!(send(type, @data))
    end

    def to_yaml
      YAML.dump(attributes)
    end

    def method_missing(meth, *args)
      if meth.to_s =~ /=$/
        attributes[meth.to_s[0...-2].to_sym] = args.length < 2 ? args[0] : args
      else
        attributes[meth]
      end
    end

    private
    def markdown(string)
      string.gsub!(/\{\{\{([^}]+)\}\}\}/) do |v|
        str = $1
        args = str =~ /,/ ? str.split(/, */) : str.split(/ +/)
        send(args[0].to_sym, *args[1..-1])
      end
      engine = Maruku.new(string)
      attributes = engine.attributes
      attributes[:content]=engine.to_html

      return attributes
    end

    def haml(string)
      engine=Haml::Engine.new(string)
      helper = Helpers.new(attributes)

      attributes={ :content => engine.render(helper) }

      helper.instance_variables.each do |v|
        next if v =~ /^@(_|haml)/
        sym = v.to_s[1..-1].intern
        attributes[sym] = helper.instance_variable_get(v)
      end
      return attributes
    end

    def yaml(string)
      return YAML.load(string)
    end

    def basename(file)
      ext = File.extname(file)
      base = File.basename(file, ext)

      return [base, ext[1..-1]]
    end

    def include(partial, div_class=nil)
      path, base = File.split(partial)
      base = "_#{base}" if path == '.'

      data=File.read(File.join(
                      (path =~ %r[^/] ? '' : File.dirname(source)),
                      path, base + File.extname(source)
                    ))
      return data unless div_class
      return "+--- {.#{div_class}}\n#{data}\n=---"
    end

  end
end
