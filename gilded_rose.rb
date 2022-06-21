module Inventory
  class Quality
    attr_reader :amount

    def initialize(amount)
      @amount = amount
    end

    def degrade
      @amount -= 1 if @amount > 0
    end

    def increase
      @amount += 1 if less_than_50?
    end

    def reset
      @amount = 0
    end

    def less_than_50?
      @amount < 50
    end
  end

  class Generic
    attr_reader :sell_in

    def initialize(quality, sell_in)
      @quality, @sell_in = Quality.new(quality), sell_in
    end

    def quality
      @quality.amount
    end

    def update
      @quality.degrade
      @sell_in = @sell_in - 1
      if @sell_in < 0
        @quality.degrade
      end
    end
  end

  class AgedBrie
    attr_reader :sell_in

    def initialize(quality, sell_in)
      @quality, @sell_in = Quality.new(quality), sell_in
    end

    def quality
      @quality.amount
    end

    def update
      @quality.increase
      @sell_in = @sell_in - 1
      if @sell_in < 0
        @quality.increase
      end
    end
  end

  class BackstagePass
    attr_reader :sell_in

    def initialize(quality, sell_in)
      @quality, @sell_in = Quality.new(quality), sell_in
    end

    def quality
      @quality.amount
    end

    def update
      @quality.increase

      if @quality.less_than_50?
        if @sell_in < 11
          @quality.increase
        end
        if @sell_in < 6
          @quality.increase
        end
      end

      @sell_in = @sell_in - 1

      @quality.reset if @sell_in < 0
    end
  end
end

class GildedRose
  class GoodCategory
    def build_for(item)
      if generic?(item)
        Inventory::Generic.new(item.quality, item.sell_in)
      elsif aged_brie?(item)
        Inventory::AgedBrie.new(item.quality, item.sell_in)
      elsif backstage_pass?(item)
        Inventory::BackstagePass.new(item.quality, item.sell_in)
      end
    end

    private

    def generic?(item)
      !(backstage_pass?(item) or aged_brie?(item))
    end

    def backstage_pass?(item)
      item.name == "Backstage passes to a TAFKAL80ETC concert"
    end

    def aged_brie?(item)
      item.name == "Aged Brie"
    end
  end

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      next if sulfuras?(item)

      good = GoodCategory.new.build_for(item)
      item.sell_in -= 1
      good.update
      item.quality = good.quality
      item.sell_in = good.sell_in
    end
  end

  private

  def sulfuras?(item)
    item.name == "Sulfuras, Hand of Ragnaros"
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end

