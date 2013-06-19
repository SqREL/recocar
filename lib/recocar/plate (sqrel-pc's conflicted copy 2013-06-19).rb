module Recocar
  class Plate
    def initialize image
      @image = image
    end

    def find_plate img_thresh, max_ratio, min_ratio, max_area, min_area, min_lenght_fo, boxes, rects, areas
  min_fill_area = 0.4
  storage = CvMemStorage.new

  #contours = CvSeq.new(CvPoint)
  contour = img_thresh.find_contours method: 1, offset: CvPoint.new(0,0)
  k = 0
  while contour
    b = contour.min_area_rect2
    if b.size.height < min_lenght_fo || b.size.width < min_lenght_fo ||
       (b.size.width*b.size.height) < min_area || (b.size.width*b.size.height) > max_area
      contour = contour.h_next
      next
    end

    if contour.contour_area.abs / (b.size.width*b.size.height) < min_fill_area
      contour = contour.h_next
      next
    end

    ratio = if b.size.width < b.size.height
      b.size.width / b.size.height
    else
      b.size.height / b.size.width
    end

    if ( ratio < min_ratio || ratio > max_ratio )
      contour = contour.h_next
      next
    end
    

    boxes << b
    box = contour.bounding_rect
    i = @img.rectangle box.top_left, box.bottom_right, :color => OpenCV::CvColor::Red
    @img.set_roi box
    w = @img.copy
    @img.reset_roi
    w.save "as/#{k}.png"
    k += 1
    contour = contour.h_next
  end
  @img.save "qwe.png"
end


def recognize
  img_thresh = @image.clone.adaptive_threshold 255, {
    threshold_type: CV_THRESH_BINARY,
    adaptive_method: CV_ADAPTIVE_THRESH_MEAN_C,
    block_size: 15,
    param1: 0
  }

  b = [1000]
  r = CvRect.new
  r.width = 1000
  r.height = 1000
  a = []
  @all = 1000
  find_box img_thresh, 0.5, 0.15, 25000, 500, 5, b, r, a
end
  end
end