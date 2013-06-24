module Recocar
  class Symbol
    include OpenCV

    SIZE = 32
    DIVIDE_IMAGE = 64
    BLOCK_SIZE = 16

    def initialize
      @symbols = %w{
         0 1 2 3 4 5 6 7 8 9 a
         b c d e f h k m o p
         s t u x
      }
      data = File.join(File.dirname(__FILE__), 'db')
      @images = {}
      @symbols.each do |symbol|
        @images[symbol] = binarize(symbol, resize(IplImage.load(File.join("db", "#{symbol}.png"), CV_LOAD_IMAGE_GRAYSCALE)))
      end
    end

    def recognize symb, i = 0
      results = {}
      symb = binarize("asdfff", resize(symb))

      s = []
      @symbols.each do |symbol|
        k = 0
        @images[symbol].each_with_index do |e,n|
          if e == symb[n] &&  e != 0
            k += 1
          end
        end
        s << { k: k / 992.0, sym: symbol }
        results[symbol] = correlate @images[symbol], symb
      end
      results = results.sort_by {|_key, value| value}
      if results.last.first == "i" && results.last.last <= 0.9
        results.pop
      end
      if (2..5).include?(i) 
        if results.last.first == "o"
          results.push ["0", 0.9]
        elsif results.last.first == "x"
          results.push ["7", 0.9]
        end
      end
      results.last
    end

    private
      def binarize a, img
        q = img.threshold(128, 255, CV_THRESH_BINARY_INV)
        q = q.to_binarized_a.flatten
        q
      end

      def resize img
        img.resize(OpenCV::CvSize.new(SIZE, SIZE))
      end

      def mean(x)
        sum=0
        x.each { |v| sum += v}
        sum/x.size
      end

      def variance(x)
        m = mean(x)
        sum = 0.0
        x.each { |v| sum += (v-m)**2 }
        sum/x.size
      end

      def sigma(x)
        Math.sqrt(variance(x))
      end

      def correlate(x,y)
        sum = 0.0
        x.each_index do |i|
          sum += x[i]*y[i]
        end
        xymean = sum/x.size.to_f
        xmean = mean(x)
        ymean = mean(y)
        sx = sigma(x)
        sy = sigma(y)
        (xymean-(xmean*ymean))/(sx*sy)
      end

      def print_matr matr
        (0...matr.count).each do |el|
          if el % 32 == 0 && el != 0 
            print "\n"
          end
          print(matr[el] == 0 ? matr[el] : matr[el].to_s.color(:black))
        end
      end
  end
end
