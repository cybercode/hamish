class Helpers
  def initialize(attrs={ })
    attrs.each_pair do |k,v|
      instance_variable_set("@#{k.to_s}",v)
    end
  end
  
  def render file, attrs
    Page.new(file, attrs).content
  end
  
  def sidebar_menu
    out = '<ul>'
    @menu.each do |m|
      out << '<li>'+(m[:name] == @current.name ? m[:title] : 
        "<a href='%s.html'>%s</a>" % [m[:name], m[:title]]) + '</li>'
    end
    out << '</ul>'
  end
  
  def prev_link
    @previous ? span(
      :previous, page_link(@previous, "Previous (#{@previous[:title]})")
      ) : ''
  end
  
  def next_link
    @next ? span(:next, page_link(@next, "Next (#{@next[:title]})")) : ''
  end

  def rel_links
    out = ''
    out << rel_link('next', @next) if @next
    out << rel_link('prev', @previous) if @previous
    out << rel_link('start', @home) if @home && @current.name != @home[:name]
    out
  end

  def rel_link(type, page)
    "<link rel='#{type}' href='#{page[:name]}.html' title='#{page[:title]}'/>"
  end

  def span(klass, text)
    "<span class='#{klass}'>#{text}</span>"
  end
  
  def page_link(p, text=nil)
    "<a href='%s.html'>%s</a>" % [p[:name], text || p[:title]]
  end
end
