class Version < PaperTrail::Version
  belongs_to :user, optional: true, foreign_key: :whodunnit
  belongs_to :item, polymorphic: true
end
