class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :cards
  has_many :wants
  has_many :trades
  has_many :messages
  has_many :chatrooms, through: :messages
end

