module Recocar
  class Plate
    include OpenCV
    attr_accessor :image

    def initialize image = nil
      @image = image
    end

    def find_plate img_thresh, max_ratio, min_ratio, max_area, min_area, min_lenght_fo
      min_fill_area = 0.4
      plates = []

      contour = img_thresh.find_contours method: 1, offset: CvPoint.new(0,0)
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
        

        box = contour.bounding_rect
        img_thresh.set_roi box
        plates << img_thresh.copy
        img_thresh.reset_roi
        contour = contour.h_next
      end
      plates
    end

    def recognize
      recognize_plate
      @clean_plates = []
      @plates.each do |plate|
        contours = []
        contour = plate.find_contours method: 1, offset: CvPoint.new(0,0)

        while contour
          b = contour.min_area_rect2
          if b.size.height < 5 || b.size.width < 5 || b.size.width > b.size.height
            contour = contour.h_next
            next
          end
          box = contour.bounding_rect
          plate.set_roi box
          contours << plate.copy
          plate.reset_roi
          contour = contour.h_next
        end
        @clean_plates << contours if contours.count >= 5
      end
      @clean_plates
    end

    def recognize_plate
      img_thresh = @image.clone.adaptive_threshold 255, {
        threshold_type: CV_THRESH_BINARY,
        adaptive_method: CV_ADAPTIVE_THRESH_MEAN_C,
        block_size: 15,
        param1: 0
      }
      @plates = find_plate img_thresh, 0.5, 0.15, 25000, 500, 5
    end
  end
end

