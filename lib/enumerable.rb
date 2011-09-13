module Enumerable
  def profile(profile)
    map { |e| e.profile.send(profile).to_h }
  end
end
