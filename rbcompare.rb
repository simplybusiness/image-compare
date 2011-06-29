#!/usr/bin/env ruby

require 'rubygems'
require 'rmagick'

EXTS = ['jpg', 'jpeg', 'JPG', 'JPEG', 'gif', 'GIF', 'png', 'PNG'].map {|e| "*."+e}

def avhash(im)
  im = Magick::Image::read(im).first unless im.instance_of?(Magick::Image)
  im = im.scale(8,8)
  pixels = im.get_pixels(0,0,8,8)
  avg = pixels.inject(0){|sum,pix| sum + pix.red + pix.blue + pix.green } / 64.0
  black_and_white = pixels.map {|pix| pix.red + pix.blue + pix.green < avg ? 0 : 1}
  hash = 0
  black_and_white.each_with_index {|val, i| hash += val << i }
  hash
end

def hamming(hash1, hash2)
  h, d = 0, hash1 ^ hash2
  while d != 0
    h += 1
    d &= d - 1
  end
  h
end

unless (1..2) === ARGV.size
  puts "Usage: %s image.jpg [dir]" % $0
  exit 
end

im = ARGV[0]
wd = ARGV.size < 2 ? '.' : ARGV[1]

h = avhash(im)

Dir.chdir(wd)

images = Dir.glob(EXTS)

result = images.map do |image|
  [image, hamming(avhash(image), h)]
end
result.sort! {|a,b| a[1] <=> b[1]}
result.each {|r| puts "#{r[1]}\t#{r[0]}"}