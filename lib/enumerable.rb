module Enumerable
  def profile(profile)
    map { |e| e.profile.send(profile) }
  end
end
