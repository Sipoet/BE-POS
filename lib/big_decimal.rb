class BigDecimal
  def to_json(*_args)
    to_f
  end

  def inspect
    to_s('F')
  end
end
