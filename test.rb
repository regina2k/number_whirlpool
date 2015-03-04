
class SpiralMatrix

  def initialize number
    unless validated number
      puts "Wrong input data"
      exit
    end

    @number = number.to_i
    @root = Math.sqrt(@number)
    @result = [[1]]
  end

  def create
    (2..@root).each do |start_num|
      add_block start_num
    end

    @result
  end

  def to_s
    return if @result.nil?

    @result.each do |row|
      puts row.join(", ")
    end
  end

  def validated number
    number?(number) && positive?(number) && square?(number)
  end

  private

  def get_next_blocks num
    block = (((num - 1) ** 2  + 1)..(num ** 2)).to_a
    [block.shift(block.size / 2), block]
  end

  def add_block num
    if num.even?
      add_to_right_and_top num
    else
      add_to_left_and_bottom num
    end
  end

  def add_to_right_and_top num
    first_block, last_block = get_next_blocks num

    @result = @result.transpose << first_block.reverse
    @result = @result.transpose.unshift(last_block.reverse)
  end

  def add_to_left_and_bottom num
    first_block, last_block = get_next_blocks num

    @result = @result.transpose.unshift(first_block)
    @result = @result.transpose << last_block
  end

  def number? num
    num.to_f.to_s == num.to_s || num.to_i.to_s == num.to_s
  end

  def square? num
    sqrt = Math.sqrt(num.to_f)
    num.to_f == sqrt.floor ** 2
  end

  def positive? num
    num.to_i > 0
  end

end


puts "Enter number:"
number = gets.chomp

spiral_matrix = SpiralMatrix.new number
spiral_matrix.create
spiral_matrix.to_s


