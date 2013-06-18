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
a.image = OpenCV::IplImage.load("/home/sqrel/Dropbox/image.png", OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
a.recognize.each do |plate|
  k = 0
  plate.each do |symbol|
    rez = sym.recognize(symbol)
    symbol.save "#{k}_#{rez.first}.png"
    p sym.recognize(symbol)
    k += 1
  end
end