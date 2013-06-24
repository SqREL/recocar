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
        box = contour.bounding_rect
        @non_clear.rectangle! box.top_left, box.bottom_right, :color => OpenCV::CvColor::Red

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
        @cont_rect.rectangle! box.top_left, box.bottom_right, :color => OpenCV::CvColor::Red
        img_thresh.set_roi box
        plates << img_thresh.copy
        img_thresh.reset_roi
        contour = contour.h_next
      end
      #@cont_rect.save "clear_cont.png"
      #@non_clear.save "dirty_cont.png"
      plates
    end

    def recognize
      recognize_plate
      @clean_plates = []
      k = 0
      z = 0
      @plates.each do |plate|
        contours = []
        contour = plate.find_contours mode: 1, method: 1, offset: CvPoint.new(0,0)
        plate_copy = plate.copy
        while contour
          box = contour.bounding_rect
          b = contour.min_area_rect2
          if box.height < 18 || box.width < 11 || box.height / box.width < 0.9 ||
             contour.contour_area.abs > 800 || contour.contour_area.abs < 100 ||
             box.width*box.height > 1500
            contour = contour.h_next
            next
          end

          box.x = box.x + 1
          box.y = box.y + 1
          box.width = box.width - 1
          box.height = box.height - 1
          plate.set_roi box
          #plate.save "#{z}.png"
          z += 1
          contours << plate.copy
          plate.reset_roi
          contour = contour.h_next
        end
        k += 1
        @clean_plates << contours if contours.count >= 5
      end
      @clean_plates
    end

    def recognize_plate
      @image.smoothness 0.5
      @cont_rect = @image.copy
      @non_clear = @image.copy
      img_thresh = @image.clone.adaptive_threshold 255, {
        threshold_type: CV_THRESH_BINARY,
        adaptive_method: CV_ADAPTIVE_THRESH_MEAN_C,
        block_size: 15,
        param1: 0
      }
      #img_thresh.save "thr.png"
      @plates = find_plate img_thresh, 0.5, 0.15, 25000, 500, 5
      z = 0
      #@plates.each { |i| i.save "#{z}.png"; z+=1 }
    end
  end
end

