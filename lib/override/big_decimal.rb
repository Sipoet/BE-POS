class BigDecimal

  def to_json
    self.to_f
  end

  def inspect
    self.to_s('F')
  end
end
