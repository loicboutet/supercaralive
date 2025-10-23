class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Simple role check methods - always return false for now
  def client?
    false
  end

  def professional?
    false
  end

  def admin?
    false
  end
end
