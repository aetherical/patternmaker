load 'pattern_maker.rb'
require 'rubygems'
require 'threach'

(2..4).to_a.each do |n|
(1..5).to_a.repeated_permutation(n).threach(3) do |x|
  puts x.inspect
  [true,false].each do |alt|
  PatternMaker.make_tartan(:pattern => x.clone, :dir => "plaids", :reverse => true,:alt=>alt).make_png
  PatternMaker.make_tartan(:pattern => x.clone, :dir => "plaids", :reverse => false,:alt=>alt).make_png
end
end
end
