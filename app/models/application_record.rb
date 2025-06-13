class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def identifier_code
    id
  end
end
