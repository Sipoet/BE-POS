class CustomArray < ActiveModel::Type::Value
  # This is required and used if you register the type
  # instead of just passing the class
  def type
    :array
  end

  def initialize(of: :string)
    super()
    @of = of
  end

  def cast(value = [])
    value = *value
    value.map do |row|
      ActiveModel::Type.lookup(@of).cast(row)
    end
  end

  def serialize(value)
    cast(value)
  end

  def deserialize(value)
    cast(value)
  end
end
