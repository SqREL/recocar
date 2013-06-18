OpenCV::IplImage.class_eval do
  def to_binarized_a
    result = []
    tmp = []
    (0...size.height * size.width).each do |el|
      if el % 32 == 0 && el != 0 
        result << tmp
        tmp = []
      end
      tmp << (self[el][0] == 0 ? 0 : 1)
    end
    result
  end
end