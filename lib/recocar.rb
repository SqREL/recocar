require 'opencv'
require 'pry-debugger'
require 'fftw3'
require 'rainbow'

module Recocar
  include OpenCV
end


require "recocar/version"
require "opencv/iplimage"
require "recocar/plate"
require "recocar/symbol"

a = Recocar::Plate.new
sym = Recocar::Symbol.new
a.image = OpenCV::IplImage.load("../spec/fixtures/5.jpg", OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
a.recognize.each do |plate|
  result = ""
  k = 0
  plate = plate.reverse
  plate.each_with_index do |symbol, i|
    rez = sym.recognize(symbol)
    #symbol.save "#{k}_#{rez.first}.png"
    re = sym.recognize(symbol, i)
    if re.last > 0.4
      result += re.first
    end
    k += 1
  end
  p result
end
