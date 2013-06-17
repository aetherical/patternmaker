load 'pattern_maker.rb'
require 'rubygems'
require 'threach'

(2..5).to_a.each do |n|
(1..6).to_a.repeated_combination(n).threach(3) do |x|
  puts x.inspect
  PatternMaker.new(:pattern => x, :dir => "combinations", :reverse => true).make.make_png
  PatternMaker.new(:pattern => x, :dir => "combinations", :reverse => false).make.make_png
end
end
