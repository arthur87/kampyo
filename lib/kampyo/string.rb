# frozen_string_literal: true

class String
  def to_utf8
    force_encoding('UTF-8')
  end
end
