class Channel < OrganisationData
  has_many :slides, :order => "position"
  has_many :displays

  validates_presence_of :name
  validates_inclusion_of :slide_delay, :in => 2..600

end
