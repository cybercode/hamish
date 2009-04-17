require 'haml'
require 'sass'
require 'maruku'
%w[site page].each do |f| 
  require File.join(File.dirname(__FILE__), f)
end
Dir.glob('./lib/*.rb') do |f|
  require f
end

def html_with_layout files, destdir, cachedir
  task :html => SITE
  task clean_task_for(:html) => 
    dest_files_for(files, SITE, 'html').existing

  desc 'Generate html with templates ([force] will regenerate all files)'
  task :html, :force, :needs => files do |t, args|
    site=Site.new(load_yaml(files, destdir))
    force = args.force||!check_menu(site, cachedir)
    if force
      STDERR.puts "Generating menu"
      File.open(File.join(CACHE, '_menu.yaml'), 'w') do |out|
        out.write YAML.dump(site.menu)
      end
    end
    site.render :force => force
  end
end
def clean destdir

  desc 'Remove all output file'
  task :clean

  desc 'Remove entire output directory'
  task :clobber do
    rm_rf destdir
  end
end

def copy task, srcpat, destdir
  task_init task, destdir, "Copy #{task.to_s} files to #{destdir}", 
  :dependent => true
  
  srclist = FileList[srcpat]
  srclist.zip(dest_files_for srclist, destdir).each do |src, dest|
    add_dependent task, dest
    
    file dest => src do cp src, dest; end
  end
end

def transform task, srcpat, destdir, options={ }, &block
  ext = task.to_s
  task_init task, destdir, "Generate #{ext}", options
    
  srclist  = FileList[srcpat]
  destlist = dest_files_for srclist, destdir, ext
  srclist.zip(destlist).each do |src, dest|
    add_dependent task, dest
    
    file dest => src do
      Site::prompt src, dest
      File.open(dest, 'w') do |out|
        out.write(yield src, dest)
      end
    end
  end
  
  return destlist
end

def add_dependent task, dep
  task task => dep
  task(clean_name_for(task) => dep) if File.exist? dep
end

def task_init task, destdir, desc, options={ }
  directory destdir
  desc desc
  task task => destdir
  task(:default => task) if options[:dependent]

  clean_task_for task
end

def clean_name_for task
  "clean_#{task.to_s}".to_sym
end

def clean_task_for task
  clean_task = clean_name_for task
  
  desc "Remove generated #{task.to_sym} files"
  task clean_task do |t| 
    rm(t.prerequisites) if t.prerequisites.size > 0
  end

  task(:clean => clean_task)
  
  return clean_task
end

def check_menu site, cachedir
  begin
    current = YAML::load(File.read(File.join(cachedir, '_menu.yaml')))
  rescue Errno::ENOENT
    return false
  end
  new = site.menu
  return current == new 
end

def load_yaml files, destination
  pages = { }
  files.each do |f| 
    p = YAML::load(File.read f)
    p.destination = File.join(destination, p.name + '.html') 
    p.attributes[:file] = f
    pages[p.name] = p
  end
  return pages
end

def dest_files_for files, destination, ext=nil
  pat="%{.*,#{destination}}p%s"
  pat << (ext ? "%n.#{ext}" : '%f')
  
  files.pathmap(pat)
end