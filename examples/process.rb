
require 'fileutils'

cwd=Dir.pwd

collection = Hash.new{|h,k| h[k] = []}

Dir.glob("images/*.png").map do |f|
  (f =~ /^images\/\d-/) ? f.split(/\//)[1].sub(/-reversed/,"").sub(/.png/,"") : nil
end.uniq.compact.each do |pattern|
  collection[(pattern.split(/-/).size)] << pattern
end

collection.keys.each do |key|
  a = collection[key].sort.map{|s| [s, "#{s}-reversed"]}.flatten
  a << "" while ((a.size % 3) != 0)

  dat = a.each_slice(3).map do |x|
    "| #{x.map{|s| "![#{s}](images/#{s}.png)"}.join(" | ")} |\n| #{x.join(" | ")} |"
  end

  File.open("#{key}grp.txt","w") do |f|
    f.write "# #{key} Thread Group Patterns\n\n"
    f.write "|:----------------------------------------:|:----------------------------------------:|:----------------------------------------:|\n"
    f.write dat.join("\n")
    f.write "\n\n"
  end
end
