class Version < PaperTrail::Version
  TABLE_HEADER=[]
  belongs_to :user, optional: true, foreign_key: :whodunnit
  belongs_to :item, polymorphic: true
end
