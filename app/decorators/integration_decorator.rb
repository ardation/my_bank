class IntegrationDecorator < ApplicationDecorator
  def service
    Integration::TYPES.invert[type]
  end
end
