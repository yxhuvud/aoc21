require "./priority_queue"

module PairingHeap
  class Heap(K, V)
    property size

    private property root : Node(K, V)?

    def initialize
      @size = 0
      @root = nil
    end

    def find_min
      return nil if empty?
      root
    end

    def insert(key : K, value : V)
      node = Node(K, V).new(key, value)
      @size += 1
      @root = merge(root, node)

      node
    end

    def delete_min
      if r = root
        delete(r)
      end
    end

    def delete(node : Node(K, V))
      key = node.key
      value = node.value
      r = root
      if node == r
        @root = collapse(node.child)
      else
        node.unlink
        @root = merge(root, collapse(node.child))
      end
      
      @size -= 1

      {key, value}
    end

    def merge(a : Node(K, V) | Nil, b : Node(K, V) | Nil)
      return b if a.nil?
      return a if b.nil?
      return a if a == b

      if a.key < b.key
        parent = a
        child = b
      else
        parent = b
        child = a
      end
      parent.prepend_child(child)
      # TODO: Investigate: Tests pass even if these are not cleared?!?
      parent.next = nil
      parent.prev = nil

      parent
    end

    def decrease_key(node : Node(K, V), new_key : K)
      raise "New key must be < old key but wasn't" if node.key < new_key
      node.key = new_key
      return if node == root

      node.unlink
      @root = merge(root, node)
    end

    def clear
      @size = 0
      @root = nil
    end

    def empty?
      @size == 0
    end

    private def collapse(node)
      return nil unless node

      # Collapse uses two phases:
      # First merge every two nodes with each other, and store a
      # reference to the previous pair in prev.
      n = node
      tail = nil
      while n
        a = n
        b = a.next
        if b
          n = b.next
          result = merge(a, b)
          result.prev = tail
          tail = result
        else
          a.prev = tail
          tail = a
          break
        end
      end

      # Then merge all pairs.
      result = nil
      while tail
        n = tail.prev
        result = merge(result, tail)
        tail = n
      end

      result
    end

    class Node(K, V)
      protected property child : Node(K, V) | Nil
      protected property next : Node(K, V) | Nil
      protected property prev : Node(K, V) | Nil

      property key : K
      property value : V

      def initialize(key : K, value : V)
        @key = key
        @value = value
      end

      def prepend_child(new_child)
        new_child.next = child
        if ch = child
          ch.prev = new_child
        end
        # note that the first element on each level have pointer to parent:
        new_child.prev = self
        @child = new_child
      end

      def unlink
        # All nodes but the root has a prev, and the root is never
        # unlinked, just dereferenced.
        prev = self.prev.not_nil!
        if prev.child == self # ie, prev references the parent.
          prev.child = self.next
        else
          prev.next = self.next
        end

        if n = self.next
          n.prev = prev
        end
        self
      end
    end
  end
end
