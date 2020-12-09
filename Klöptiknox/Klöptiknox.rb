require 'rubygems'
require 'gosu'
include Gosu

Left = 0, Right = 1, Up = 2, Down = 3, Fire = 4

class GameObject
  attr_reader :game
  attr_accessor :x, :y, :w, :h

  def initialize(game); @game = game; @game.objects.push(self); @x = @y = @w = @h = 0; end
  def update(keys); false; end
  def draw; end
  
  def hurts_player?(x, y); false; end
  def hurts_enemy?(x, y); false; end
end

class Bullet < GameObject
  def initialize(game, x, y)
    super(game)
    self.x, self.y = x, y
    self.w, self.h = game.bullet_image.width, game.bullet_image.height
  end
  
  def draw
    self.game.bullet_image.draw_rot(self.x, self.y, 0, 0)
  end
  
  def update(keys)
    (self.x += 10) > 640
  end
  
  def hurts_enemy?(x, y)
    (x - self.x).abs < 30 and (y - self.y).abs < 30
  end
end

class Player < GameObject
  def initialize(game)
    super(game)
    @image = Image.new(game, "Player.bmp", false)
    self.x = 100
    self.y = 240
    self.w = @image.width
    self.h = @image.height
  end

  def can_move?(to_x, to_y)
    to_x - @w / 2 > 0 and to_y - @h / 2 > 0 and to_x + @w / 2 < 450 and to_y + @h / 2 < 480
  end
  
  def fire
     if rand(2) == 0 then Bullet.new(self.game, self.x + self.w / 2, self.y); end
  end

  def move(dx, dy)
    if (dx > 0)
      dx.times { if can_move?(self.x + 1, self.y) then self.x += 1 end }
    else
      (-dx).times { if can_move?(self.x - 1, self.y) then self.x -= 1 end }
    end
    if (dy > 0)
      dy.times { if can_move?(self.x, self.y + 1) then self.y += 1 end }
    else
      (-dy).times { if can_move?(self.x, self.y - 1) then self.y -= 1 end }
    end
  end
  
  def update(keys)
    if (keys.include? Left) then move(-4, 0); end
    if (keys.include? Right) then move(+4, 0); end
    if (keys.include? Up) then move(0, -4); end
    if (keys.include? Down) then move(0, +4); end
    if (keys.include? Fire) then fire end
    self.game.objects.any? { |o| o.hurts_player?(self.x, self.y) }
  end

  def draw
    @image.draw_rot(self.x, self.y, 0, 0)
  end
end

class Enemy < GameObject
  def initialize(game, x, y)
    super(game)
    self.x, self.y = x, y
    self.w, self.h = game.enemy_image.width, game.enemy_image.height
  end
  
  def update(keys)
    self.x -= 3
    if self.game.objects.any? { |o| o.hurts_enemy?(self.x, self.y) } then
      self.game.score += 463453642
      true
    else
      self.x < -100
    end
  end
  
  def draw
    factor_x = 0.8 + Math.sin((self.y + milliseconds) / 100.0) * 0.4
    factor_y = 0.8 + Math.cos((self.y + milliseconds) / 100.0) * 0.4
    a = -90
    self.game.objects.each { |o| if o.kind_of? Player then a = angle(self.x, self.y, o.x, o.y); end }
    game.enemy_image.draw_rot(self.x, self.y, 0,a, 0, 0, factor_x, factor_y)
  end
  
  def hurts_player?(x, y)
    (x - self.x).abs < 50 and (y - self.y).abs < 50
  end
end

class Game < Window
  attr_reader :objects
  attr_reader :bullet_image, :enemy_image
  attr_accessor :score

  def initialize
    super(640, 480, true, 20)
    self.caption = "Klöptiknox"
    @bullet_image = Image.new(self, "Bullet.bmp", false)
    @enemy_image = Image.new(self, "Enemy.bmp", false)
    @font = Font.new(self, "Comic Sans MS", 72)
    @score = 0
    @objects = Array.new
    @objects.push Player.new(self)
  end

  def update
    keys = Array.new
    if button_down? Button::KbSpace or button_down? Button::GpButton0 then keys << Fire end
    if button_down? Button::KbLeft or button_down? Button::GpLeft then keys << Left; end
    if button_down? Button::KbRight or button_down? Button::GpRight then keys << Right; end
    if button_down? Button::KbUp or button_down? Button::GpUp then keys << Up; end
    if button_down? Button::KbDown or button_down? Button::GpDown then keys << Down; end
    @objects.reject! { |o| o.update(keys) }
    
    if rand(100) < 25 then Enemy.new(self, 700, rand(480)); end
   end
  
  def draw
    if rand(2) == 0 then c = 0xffff00ff else c = 0xff00ff00 end
    self.draw_quad(0, 0, c, 640, 0, c, 0, 480, c, 640, 480, c)
    @objects.each { |o| o.draw }  
    if rand(2) == 0 then c = 0xff0000ff else c = 0xffffff00 end
    if not @objects.any? { |o| o.kind_of? Player } then 
      @font.draw_rel("GAME OVEURE.", 320, 240, 0, 0.5, 0.5, 1, 1, c)
    end
    @font.draw_rel("Punkte: " + @score.to_s, 320, 10, 0, 0.5, 0, 1, 1, c)
  end
  
  def button_down(id)
    if id == Button::KbEscape then close end
  end
end

Game.new.show