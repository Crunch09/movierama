class VoteCounter < BaseModel
  include Ohm::Timestamps

  attribute :type

  reference :user, :User
  reference :movie, :Movie
end
