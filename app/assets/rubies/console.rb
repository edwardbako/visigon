require_relative "./line.rb"
require_relative "./point.rb"
require_relative "./polygon.rb"
require_relative "./polygon/visibility_polygon.rb"
require_relative "./drawer.rb"

d = Drawer.new

d.elements += [
  Polygon.new([[240,240],[260,240],[260,260],[240,260]]),
  Polygon.new([[240,260],[260,260],[260,280],[240,280]]),
  Polygon.new([[260,240],[280,240],[280,260],[260,260]]),
  Polygon.new([[440,240],[460,240],[460,260],[440,260]]),
  Polygon.new([[250,100],[260,140],[240,140]]),
  Polygon.new([[280,100],[290,60],[270,60]]),
  Polygon.new([[310,100],[320,140],[300,140]]),
  Polygon.new([[50,450],[60,370],[70,450]]),
  Polygon.new([[450,450],[460,370],[470,450]]),
  Polygon.new([[50,50],[60,30],[70,50]]),
  Polygon.new([[450,50],[460,30],[470,50]]),
  Polygon.new([[140,340],[160,240],[180,340],[360,340],[360,360],[250,390],[140,360]]),
  Polygon.new([[140,140],[150,130],[150,145],[165,150],[160,160],[140,160],[140,140]]),
  Line.new([100, 150],[100, 100]),
  Line.new([50, 125],[100, 125]), # intersects
  Line.new([450, 100],[400, 150]),
  Line.new([450, 150],[400, 100]), # intersects
  Line.new([50, 250],[100, 250]),
  Line.new([50, 250],[100, 250]), # duplicate
  Line.new([140,40],[140,60]),
  Line.new([140,60],[160,60]),
  Line.new([160,60],[160,40]),
  Line.new([160,40],[140,40]),
  Line.new([160,40],[140,40]),
  Line.new([430,470], [480, 420])
]

20.times do |i|
  d.elements << Polygon.new([[240,410+i*4],[245,410+i*4],[245,411+i*4],[240,411+i*4]])
end

d.update