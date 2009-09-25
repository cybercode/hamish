require 'haml'
require File.dirname(__FILE__) + '/page.rb'

class Site
  attr_reader :pages
  attr_reader :menu
  
  def initialize pages, options={ }
    @pages = pages
    @home = options[:home]||'index'
    @layout_dir = options[:layout]||'layout'
    @layouts = { 'none'=>{:file=>__FILE__, :data=>'=yield'} }
    build_menu
  end

  def render args
    pages.values.select do |p| 
      # FileUtils.uptodate? returns false if the
      # new and old file times are equal and the yaml files
      # get rendered twice if the src changes.
      # So don't use it.
      if args[:force] || ! File.exist?(p.destination)
        true
      else
        desttime = File.mtime(p.destination)
        File.mtime(p.file) > desttime || 
          File.mtime(layout_for(p)[:file]) > desttime
      end
    end.each do |p|
      render_page(p)
    end
  end
  
  def self.prompt src, dest
    STDERR.printf "%-30.30s -> %-44.44s\n", src, dest
  end
  
  private
  def build_menu
    @menu = []
    current = @home
    previous = nil
    while pages[current]
      p = pages[current]
      @menu << { 
        :name     => current,
        :title    => p.title,
        :next     => p.next,
        :previous => previous
      }
      previous = current
      current = p.next
    end
    @menu
  end

  def render_page page
    helpers = Helpers.new
    item = menu.select { |i| i[:name] == page.name}[0]

    page.attributes.merge(
      :menu     => menu,
      :home     => menu.select { |i| i[:name] == @home}[0],
      :current  => page,
      :previous => item_or_nil(menu, item, :previous),
      :next     => item_or_nil(menu, item, :next)
      ).each do |name, value|
      helpers.instance_variable_set("@#{name}", value)
    end
    self.class.prompt page.file, page.destination

    File.open(page.destination, "w") do |f|
      f.write(
        Haml::Engine.new(layout_for(page)[:data]).render(helpers) do
          page.content 
        end
        )
    end
  end

  def item_or_nil menu, item, value
    return nil unless item && v = item[value]
    menu.select { |i| i[:name] == v }[0]
  end

  def layout_for page
    name = page.layout || 'default'
    return @layouts[name] if @layouts[name]
    file = File.join(Dir.pwd, @layout_dir, name + '.haml')
    @layouts[name]={ :file=>file, :data=>File.read(file) }
  end

end
