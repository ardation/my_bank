class Integration < ApplicationRecord
  belongs_to :user
  serialize :info, Hash
  serialize :credentials, Hash
  serialize :extra, Hash

  def pull
    "#{self.class.name}::PullService".classify.constantize.pull(self)
  rescue NameError
    raise NoMethodError 'Integration base class does not implement pull'
  end
end
