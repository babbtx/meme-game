class GameResource < ApplicationResource
  attribute :invitees, :array_of_strings, writable: true, readable: false

  attr_accessor :creator
  after_save :set_private_attributes

  private

  def set_private_attributes(model)
    if creator && !model.players.exists?(id: creator.id)
      model.players << creator
    end
  end
end
