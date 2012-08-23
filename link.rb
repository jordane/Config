#!/usr/bin/ruby -w

home = ENV['HOME']
cwd = Dir.pwd

files = {
  :Xmodmap => "#{home}/.Xmodmap",
  :config  => "#{home}/.config",
  :screenrc => "#{home}/.screenrc",
  :ssh_config => "#{home}/.ssh/config",
  :xinitrc => "#{home}/.xinitrc",
  :xmodmap_modkeys => "#{home}/.xmodmap-modkeys",
  :zshrc => "#{home}/.zshrc",
  :zshrc_d => "#{home}/.zshrc.d",
}

files.each_pair do |k,v|
#  puts "ln -s #{k} #{v}"
  `ln -sf #{cwd}/#{k} #{v}`
end
