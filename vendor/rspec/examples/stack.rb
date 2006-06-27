class StackUnderflowError < RuntimeError
end

class StackOverflowError < RuntimeError
end

class Stack
  
  def initialize
    @items = []
  end
  
  def push object
    raise StackOverflowError if @items.length == 10
    @items.push object
  end
  
  def pop
    raise StackUnderflowError if @items.empty?
    @items.delete @items.last
  end
  
  def top
    raise StackUnderflowError if @items.empty?
    @items.last
  end
  
  def empty?
    @items.empty?
  end
  
  def size
    @items.length
  end
  
end