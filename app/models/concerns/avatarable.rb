module Avatarable
  extend ActiveSupport::Concern

  included do
    unless ENV["SECRET_KEY_BASE_DUMMY"].present?
      has_one_attached :avatar

      # TODO:  move these validation strings to a locale file
      validates :avatar, content_type: {in: ["image/png", "image/jpeg"],
        message: "must be PNG or JPEG"},
        size: {between: 10.kilobyte..1.megabytes,
          message: "size must be between 10kb and 1Mb"}
    end
  end
end
