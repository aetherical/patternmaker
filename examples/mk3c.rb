load 'pattern_maker.rb'
require 'rubygems'
require 'threach'

#(2..5).to_a.each do |n|
(1..5).to_a.repeated_permutation(3).threach(3) do |x|
  puts x.inspect
  PatternMaker.new(:pattern => x, :dir => "3colors", :reverse => true,:colors => {"1"=>"0,0,128", "2" => "128,128,128", "3"=>"0,0,0"}).make.make_png
  PatternMaker.new(:pattern => x, :dir => "3colors", :reverse => false,:colors => {"1"=>"0,0,128", "2" => "128,128,128", "3"=>"0,0,0"}).make.make_png
end
#end
