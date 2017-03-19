module AssertEmbulkRaise
  # NOTE: assert_raise(TypecastError) do ... end can't detect correctly
  def assert_embulk_raise(klass, &block)
    begin
      yield
      assert false
    rescue => e
      assert e.is_a?(klass), "expect: #{klass.name}, actual: #{e.class.name}, message: #{e}"
    end
  end
end