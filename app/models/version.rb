class Version < PaperTrail::Version

  belongs_to :user, optional: true, foreign_key: :whodunnit
end
