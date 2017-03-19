module AssertEmbulkNothingRaised
  # NOTE: assert_raise(TypecastError) do ... end can't detect correctly
  def assert_embulk_nothing_raised(&block)
    begin
      yield
      assert true
    rescue => e
      assert_equal(nil, e)
    end
  end
end