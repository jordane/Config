#!/usr/bin/ruby -w

if __FILE__ == $0
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
    :dne => "#{home}/.dne" # Does not exist, test case
  }

  files.each_pair do |k,v|
    File.unlink(v) if File.exists?(v) and File.ftype(v) == 'link'
    File.symlink("#{cwd}/#{k}",v) if !File.exists?(v)
  end
end
