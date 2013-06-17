load 'pattern_maker.rb'

(2..5).to_a.each do |n|
(1..5).to_a.repeated_permutation(n).each do |x|
  puts x.inspect
  PatternMaker.new(:pattern => x, :dir => "permutations", :reverse => true).make.make_png
  PatternMaker.new(:pattern => x, :dir => "permutations", :reverse => false).make.make_png
end
end
